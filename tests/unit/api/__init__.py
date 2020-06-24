import copy

from collections import Iterable
from functools import wraps
from uuid import uuid4
from unittest import mock

from salsa.db import db
from tests import admin_user
from salsa import permission

from . import *  # noqa


def skip_if_not_defined(method):
    def skip_if_not_defined_inner(f):
        @wraps(f)
        def wrapper(obj, *args, **kwargs):
            if method not in obj.api.__class__.__dict__.keys():
                obj.skipTest('{} has no {} action'
                             .format(obj.api.__class__.__name__, method))

            return f(obj, *args, **kwargs)

        return wrapper

    return skip_if_not_defined_inner


class ApiUnitTestCase:
    def setUp(self):
        self.api = None
        self.factory = None
        self.user = {
            'prm': {
                'title': permission.ADMIN_PERM_TITLE
            }
        }

    @skip_if_not_defined('retrieve')
    def test_get(self):
        instance = self.factory()

        res = self.api.retrieve(instance.id, token_info=self.user)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 200)
        self.assertEqual(res.json['id'], str(instance.id))

    def _get_not_found(self, id_):
        res = self.api.retrieve(id_, token_info=self.user)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 404)
        self.assertEqual(res.json['detail'], '{} with id {} not found'
                         .format(self.api.model.humanized_tablename(), id_))

    @skip_if_not_defined('retrieve')
    def test_get_not_found(self):
        id_ = uuid4()
        self._get_not_found(id_)

    @skip_if_not_defined('retrieve')
    def test_get_invalid_id(self):
        id_ = 'foo'
        res = self.api.retrieve(id_, token_info=self.user)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 400)
        self.assertEqual(res.json['detail'], 'Not a valid {} ID'
                         .format(self.api.model.__name__))

    @skip_if_not_defined('retrieve_list')
    def test_list(self):
        instance = self.factory()

        self.assertEqual([instance], db.session.query(self.api.model).all())

        res = self.api.retrieve_list(token_info=self.user)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 200)
        self.assertEqual(len(res.json), 1)
        self.assertEqual(res.json[0]['id'], str(instance.id))

    @skip_if_not_defined('retrieve_list')
    def test_list_empty(self):
        self.assertEqual([], db.session.query(self.api.model).all())

        res = self.api.retrieve_list(token_info=self.user)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 200)
        self.assertEqual(res.json, [])

    def _list_with_embed(self, make_instance, embed, **kwargs):
        for _ in range(5):
            instance = make_instance()

        res = self.api.retrieve_list(embed=embed, token_info=self.user, **kwargs)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 200)
        self.assertEqual(len(res.json), 5)

        for resource in res.json:
            for rel in embed:
                id_ = resource['id']
                instance = db.session.query(self.api.model).get(id_)
                self.assertIsNotNone(instance)
                self.assertIn(rel, resource)

                if isinstance(resource[rel], dict):
                    self.assertIsInstance(resource[rel]['id'], str)
                else:
                    for e in resource[rel]:
                        self.assertIsInstance(e['id'], str)

    def _list_with_filter(self, match=None, **filter):
        if match is None:
            match = self.factory(**filter)

        instances = [
            match,
            self.factory(),
        ]

        self.assertEqual(instances, db.session.query(self.api.model).all())

        res = self.api.retrieve_list(token_info=self.user, **filter)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 200)
        self.assertEqual(len(res.json), 1)
        self.assertEqual(res.json[0]['id'], str(match.id))

        return res

    def _list_with_query(self, match_query, match=None):
        if match is None:
            match = self.factory(name=match_query)

        instances = [
            match,
            self.factory(),
        ]

        self.assertEqual(instances, db.session.query(self.api.model).all())

        query_map = {
            '': [True, True],
            match_query: [True, False],
            'No results': [False, False],
        }

        for query, result in query_map.items():
            res = self.api.retrieve_list(query=query, token_info=self.user)

            self.assertIsNotNone(res.data)
            self.assertEqual(res.status_code, 200)
            for is_there, instance in zip(result, instances):
                self.assertEqual(
                    is_there,
                    (str(instance.id) in [o['id'] for o in res.json]))

    def _post_valid(self, body, expected=None,
                                use_expected_for_body=False,
                                user_id_in_body=None):

        if user_id_in_body:
            user = copy.deepcopy(self.user)
            user['usr'] = {'id': user_id_in_body}
        else:
            user = self.user

        res = self.api.create(body=body, token_info=user)

        # if expected is not given, expected should be body
        if expected is None:
            expected = body

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 201)

        if use_expected_for_body:
            body = expected

        for attr in body.keys():
            if isinstance(body[attr], list) or isinstance(body[attr], dict):
                # list relationships won't be returned unless explicitly
                # requested that they are embeded in response
                continue
            self.assertEqual(res.json[attr], expected[attr])

        instance = db.session.query(self.api.model).get(res.json['id'])
        self.assertIsNotNone(instance)
        return instance

    def _post_invalid(self, body,
                      err='{} validation error',
                      detail=None,
                      error_code=400,
                      user_id_in_body=None):

        if user_id_in_body:
            user = copy.deepcopy(self.user)
            user['usr'] = {'id': user_id_in_body}
        else:
            user = self.user

        res = self.api.create(body=body, token_info=user)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, error_code)
        self.assertEqual(res.json['detail'], err
                         .format(self.api.model.__name__))

    def _put_invalid(self, body,
                     err='{} validation error',
                     id_=None,
                     error_code=400):
        if id_ is None:
            instance = self.factory()
            id_ = instance.id

        res = self.api.update(id_, body=body, token_info=self.user)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, error_code)
        self.assertEqual(res.json['detail'], err
                         .format(self.api.model.__name__))

    def _put_valid(self, body, id_=None, expected=None):
        if id_ is None:
            instance = self.factory()
            id_ = instance.id

        res = self.api.update(id_, body=body, token_info=self.user)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 200)

        # if expected is not given, expected should be body
        if expected is None:
            expected = body

        for attr in body.keys():
            self.assertEqual(res.json[attr], expected[attr])

    def _post_valid_list(self, bodies):
        res = self.api.create_list(bodies, token_info=self.user)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 201)

        for idx, body in enumerate(bodies):
            for attr in body.keys():
                if isinstance(body[attr], Iterable):
                    # list relationships won't be returned unless explicitly
                    # requested that they are embeded in response
                    continue
                self.assertEqual(res.json[idx][attr], body[attr])

        instances = db.session.query(self.api.model).all()
        self.assertEqual(len(instances), len(bodies))
        return instances

    def _put_not_found(self, body, id_=None, err_msg=None):
        if id_ is None:
            id_ = uuid4()
        res = self.api.update(id_, body=body, token_info=self.user)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 404)
        if err_msg is None:
            self.assertEqual(
                res.json['detail'],
                '{} with id {} not found'.format(
                    self.api.model.humanized_tablename(), id_))
        else:
            self.assertEqual(res.json['detail'], err_msg)


class PermissionsTestCase(ApiUnitTestCase):
    def setUp(self):
        self.api = None
        self.factory = None
        self.user = {
            'prm': {
                'title': permission.USER_PERM_TITLE
            }
        }
