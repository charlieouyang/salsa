import unittest
from unittest import mock

from salsa.api import user_roles as user_roles_api

from tests.unit.api import ApiUnitTestCase, PermissionsTestCase
from tests import SalsaTestCase
from tests.factories import UserRoleFactory


class TestUserRolesController(ApiUnitTestCase, SalsaTestCase):
    def setUp(self):
        super(TestUserRolesController, self).setUp()
        self.api = user_roles_api
        self.factory = UserRoleFactory

    def test_list_with_name(self):
        for _ in range(3):
            UserRoleFactory()

        matched = UserRoleFactory(title='test_title')
        res = self.api.retrieve_list(title=matched.title)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 200)
        self.assertEqual(len(res.json), 1)
        self.assertEqual(res.json[0]['id'], str(matched.id))

    def test_list_with_filter(self):
        self._list_with_filter(title='test_title_1')

    def test_post(self):
        user_role = UserRoleFactory()
        body = {
            'title': 'test_title',
            'description': 'test_description',
        }

        self._post_valid(body)

    def test_post_invalid(self):
        user_role = UserRoleFactory()

        body = {
            'title': user_role.title,
            'description': 'test_description',
        }
        self._post_invalid(body, err='{} already exists')

    def test_put(self):
        user_role = UserRoleFactory()
        body = {
            'description': 'test_description'
        }
        self._put_valid(body)

    def test_put_invalid(self):
        user_role = UserRoleFactory()
        body = {
            'title': user_role.title
        }
        self._put_invalid(body, err='{} already exists')

    def test_put_not_found(self):
        self._put_not_found({'title': 'test_title'})


class TestUserRolesPermissions(PermissionsTestCase, SalsaTestCase):
    def setUp(self):
        super(TestUserRolesPermissions, self).setUp()
        self.api = user_roles_api
        self.factory = UserRoleFactory

    def tearDown(self):
        super(TestUserRolesPermissions, self).tearDown()

    def test_list_with_name(self):
        for _ in range(3):
            UserRoleFactory()

        matched = UserRoleFactory(title='test_title')
        res = self.api.retrieve_list(title=matched.title)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 200)
        self.assertEqual(len(res.json), 1)
        self.assertEqual(res.json[0]['id'], str(matched.id))

    # Basic user should not be able to create a user_role
    def test_post_invalid(self):
        user_role = UserRoleFactory()
        body = {
            'title': 'test_title',
            'description': 'test_description',
        }

        self._post_invalid(body, err='Insufficient permissions', error_code=403)

    # Basic user should not be able to update a user_role
    def test_put_invalid(self):
        user_role = UserRoleFactory()
        body = {
            'title': user_role.title
        }
        self._put_invalid(body, err='Insufficient permissions', error_code=403)

    # Basic user should not be able to delete a user_role
    def test_delete_invalid(self):
        self._delete_invalid(err='Insufficient permissions', error_code=403)


if __name__ == '__main__':
    unittest.main()
