import unittest
from werkzeug.exceptions import BadRequest
from unittest import mock
from parameterized import parameterized

from salsa.api import user_accounts as user_accounts_api
from salsa import permission

from tests.unit.api import ApiUnitTestCase, PermissionsTestCase
from tests import SalsaTestCase
from tests.factories import UserAccountFactory, UserRoleFactory


class TestUserAccountsController(ApiUnitTestCase, SalsaTestCase):
    def setUp(self):
        super(TestUserAccountsController, self).setUp()
        self.api = user_accounts_api
        self.factory = UserAccountFactory

    def test_list_with_name(self):
        for _ in range(3):
            UserAccountFactory()

        matched = UserAccountFactory(name='test_name')
        res = self.api.retrieve_list(name=matched.name, token_info=self.user)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 200)
        self.assertEqual(len(res.json), 1)
        self.assertEqual(res.json[0]['id'], str(matched.id))

    def test_list_with_filter(self):
        self._list_with_filter(email='test_user_email_1')

    def test_post(self):
        user_role = UserRoleFactory()
        body = {
            'name': 'test_name',
            'email': 'test_email@email.com',
            'password': 'test_pass',
            'extradata': '{"data": "me"}',
            'user_role_id': str(user_role.id)
        }
        expected = body.copy()
        expected.pop('password')

        self._post_valid(body, expected=expected, use_expected_for_body=True)

    def test_post_invalid_duplicate(self):
        user_role = UserRoleFactory()
        UserAccountFactory(email='test_email@email.com')

        body = {
            'name': 'test_name',
            'email': 'test_email@email.com',
            'extradata': '{"data": "me"}',
            'password': 'test_pass',
            'user_role_id': str(user_role.id)
        }
        self._post_invalid(body, err='{} already exists')

    def test_post_invalid_email(self):
        user_role = UserRoleFactory()
        body = {
            'name': 'test_name',
            'email': 'invalid_email',
            'extradata': '{"data": "me"}',
            'password': 'test_pass',
            'user_role_id': str(user_role.id)
        }
        with self.assertRaises(BadRequest):
            self._post_invalid(body, err='Email is invalid')

    def test_put(self):
        body = {
            'name': 'test_name',
            'email': 'test_email@email.com'
        }
        self._put_valid(body)

    def test_put_not_found(self):
        self._put_not_found({'name': 'name1'})

    def test_put_invalid_email(self):
        body = {
            'name': 'test_name',
            'email': 'invalid_email'
        }
        with self.assertRaises(BadRequest):
            self._put_valid(body)


class TestUserAccountsPermissions(PermissionsTestCase, SalsaTestCase):
    def setUp(self):
        super(TestUserAccountsPermissions, self).setUp()
        self.api = user_accounts_api
        self.factory = UserAccountFactory

    def tearDown(self):
        super(TestUserAccountsPermissions, self).tearDown()

    def _setup_user_himself_and_roles(self):
        self.admin_role = UserRoleFactory(title=permission.ADMIN_PERM_TITLE)
        self.normal_role = UserRoleFactory(title=permission.USER_PERM_TITLE)
        self.user_himself_inst = UserAccountFactory(user_role=self.normal_role)
        self.user_himself = {
            'prm': {
                'title': permission.USER_PERM_TITLE
            },
            'usr': {
                'id': str(self.user_himself_inst.id)
            }
        }

    # Normal user.. get himself success
    # Normal user.. get someone else normal success
    # Normal user.. get someone else admin success
    @parameterized.expand([
        ('normal', True),
        ('admin', True),
        ('normal', True),
    ])
    def test_get(self, user_type, retrieve_himself):
        self._setup_user_himself_and_roles()

        if retrieve_himself:
            user_try_to_fetch = self.user_himself_inst
        else:
            if user_type == 'normal':
                user_try_to_fetch = UserAccountFactory(user_role=self.normal_role)
            elif user_type == 'admin':
                user_try_to_fetch = UserAccountFactory(user_role=self.admin_role)

        res = self.api.retrieve(user_try_to_fetch.id, token_info=self.user_himself)
        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 200)
        self.assertEqual(res.json['id'], str(user_try_to_fetch.id))

    def test_list(self):
        self._setup_user_himself_and_roles()

        res = self.api.retrieve_list(token_info=self.user_himself)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 403)
        self.assertEqual(res.json['detail'], 'Insufficient permissions')

    # Only reserved for admins.. Same as test_list
    def test_list_empty(self):
        pass

    # No auth user.. create normal success
    # No auth user.. create admin fail
    @parameterized.expand([
        ('normal', True),
        ('admin', False),
    ])
    def test_create_no_auth(self, user_type, is_successful):
        self._setup_user_himself_and_roles()
        body = {
            'name': 'name_test',
            'email': 'test_email@email.com',
            'extradata': '{"data": "me"}',
            'password': 'pass_test'
        }

        if user_type == 'normal':
            body['user_role_id'] = str(self.normal_role.id)
        elif user_type == 'admin':
            body['user_role_id'] = str(self.admin_role.id)

        res = self.api.create_no_auth(body=body, token_info={})
        if is_successful:
            self.assertIsNotNone(res.data)
            self.assertEqual(res.status_code, 201)
            self.assertEqual(res.json['email'], body['email'])
        else:
            self.assertIsNotNone(res.data)
            self.assertEqual(res.status_code, 403)
            self.assertEqual(
                res.json['detail'], f'Using this role id <{str(self.admin_role.id)}> is not allowed.')

    # Normal user.. update himself success
    # Normal user.. update someone else normal fail
    # Normal user.. update someone else admin fail
    @parameterized.expand([
        ('normal', True),
        ('admin', False),
        ('normal', False),
    ])
    def test_update(self, user_type, update_himself):
        self._setup_user_himself_and_roles()

        if update_himself:
            user_try_to_update = self.user_himself_inst
        else:
            if user_type == 'normal':
                user_try_to_update = UserAccountFactory(user_role=self.normal_role)
            elif user_type == 'admin':
                user_try_to_update = UserAccountFactory(user_role=self.admin_role)

        res = self.api.update(user_try_to_update.id,
                              body={'name': 'new name'},
                              token_info=self.user_himself)
        if update_himself:
            self.assertIsNotNone(res.data)
            self.assertEqual(res.status_code, 200)
            self.assertEqual(res.json['id'], str(user_try_to_update.id))
            self.assertEqual(res.json['name'], 'new name')
        else:
            self.assertIsNotNone(res.data)
            self.assertEqual(res.status_code, 404)
            self.assertEqual(
                res.json['detail'], f'User account with id {str(user_try_to_update.id)} not found')


if __name__ == '__main__':
    unittest.main()
