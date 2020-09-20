import unittest
from unittest import mock

from salsa.api import categories as categories_api

from tests.unit.api import ApiUnitTestCase, PermissionsTestCase
from tests import SalsaTestCase
from tests.factories import CategoryFactory


class TestCategoriesController(ApiUnitTestCase, SalsaTestCase):
    def setUp(self):
        super(TestCategoriesController, self).setUp()
        self.api = categories_api
        self.factory = CategoryFactory

    def test_list_with_name(self):
        for _ in range(3):
            CategoryFactory()

        matched = CategoryFactory(name='test_name')
        res = self.api.retrieve_list(name=matched.name)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 200)
        self.assertEqual(len(res.json), 1)
        self.assertEqual(res.json[0]['id'], str(matched.id))

    def test_list_with_filter(self):
        self._list_with_filter(name='test_name_1')

    def test_post(self):
        body = {
            'name': 'test_name',
        }

        self._post_valid(body)

    def test_post_invalid(self):
        category = CategoryFactory()

        body = {
            'name': category.name
        }
        self._post_invalid(body, err='{} already exists')

    def test_put(self):
        category = CategoryFactory()
        body = {
            'name': 'test_name'
        }
        self._put_valid(body)

    def test_put_invalid(self):
        category = CategoryFactory()
        body = {
            'name': category.name
        }
        self._put_invalid(body, err='{} already exists')

    def test_put_not_found(self):
        self._put_not_found({'name': 'test_name'})


class TestCategoriesPermissions(PermissionsTestCase, SalsaTestCase):
    def setUp(self):
        super(TestCategoriesPermissions, self).setUp()
        self.api = categories_api
        self.factory = CategoryFactory

    def tearDown(self):
        super(TestCategoriesPermissions, self).tearDown()

    def test_list_with_name(self):
        for _ in range(3):
            CategoryFactory()

        matched = CategoryFactory(name='test_title')
        res = self.api.retrieve_list(name=matched.name)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 200)
        self.assertEqual(len(res.json), 1)
        self.assertEqual(res.json[0]['id'], str(matched.id))

    # Basic user should not be able to create a user_role
    def test_post_invalid(self):
        body = {
            'name': 'test_name',
        }

        self._post_invalid(body, err='Insufficient permissions', error_code=403)

    # Basic user should not be able to update a user_role
    def test_put_invalid(self):
        body = {
            'name': 'test_name',
        }
        self._put_invalid(body, err='Insufficient permissions', error_code=403)


if __name__ == '__main__':
    unittest.main()
