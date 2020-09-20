import unittest
from unittest import mock
from parameterized import parameterized

from salsa.api import products as products_api
from salsa import permission

from tests.unit.api import ApiUnitTestCase, PermissionsTestCase
from tests import SalsaTestCase
from tests.factories import UserAccountFactory, UserRoleFactory, ProductFactory


class TestProductsController(ApiUnitTestCase, SalsaTestCase):
    def setUp(self):
        super(TestProductsController, self).setUp()
        self.api = products_api
        self.factory = ProductFactory

    def test_list_with_name(self):
        for _ in range(3):
            ProductFactory()

        matched = ProductFactory(name='test_name')
        res = self.api.retrieve_list(name=matched.name, token_info=self.user)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 200)
        self.assertEqual(len(res.json), 1)
        self.assertEqual(res.json[0]['id'], str(matched.id))

    def test_list_with_user_id(self):
        for _ in range(3):
            ProductFactory()

        user = UserAccountFactory()
        for _ in range(2):
            ProductFactory(user_account=user)
        res = self.api.retrieve_list(user_id=user.id, token_info=self.user)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 200)
        self.assertEqual(len(res.json), 2)

    def test_list_with_active(self):
        for _ in range(3):
            ProductFactory(active=True)
        for _ in range(2):
            ProductFactory(active=False)

        res = self.api.retrieve_list(active=True, token_info=self.user)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 200)
        self.assertEqual(len(res.json), 3)

    def test_list_with_filter(self):
        self._list_with_filter(name='test_product_name_1')

    def test_post(self):
        user_role = UserRoleFactory(title=permission.ADMIN_PERM_TITLE)
        user_account = UserAccountFactory(user_role_id=user_role.id)
        body = {
            'active': True,
            'name': 'test_product',
            'description': 'test description',
            'image_urls': ['a', 'b'],
        }
        expected = body.copy()

        self._post_valid(body,
                         expected=expected,
                         use_expected_for_body=True,
                         user_id_in_body=str(user_account.id))

    def test_put(self):
        body = {
            'name': 'test_name',
            'description': 'test_description'
        }
        self._put_valid(body)

    def test_put_not_found(self):
        self._put_not_found({'name': 'name1'})


class TestProductsPermissions(PermissionsTestCase, SalsaTestCase):
    def setUp(self):
        super(TestProductsPermissions, self).setUp()
        self.api = products_api
        self.factory = ProductFactory

    def tearDown(self):
        super(TestProductsPermissions, self).tearDown()

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

    # product created by himself.. get product success
    # product created by another normal user.. get product success
    # product created by another admin user.. get product success
    @parameterized.expand([
        (True, None),
        (False, 'normal'),
        (False, 'admin'),
    ])
    def test_get(self, his_own_product, other_user_type):
        self._setup_user_himself_and_roles()

        if his_own_product:
            product_to_fetch = ProductFactory(
                user_account=self.user_himself_inst)
        else:
            if other_user_type == 'normal':
                another_user = UserAccountFactory(
                    user_role=self.normal_role)
                product_to_fetch = ProductFactory(
                    user_id=str(another_user.id))
            elif other_user_type == 'admin':
                another_user = UserAccountFactory(
                    user_role=self.admin_role)
                product_to_fetch = ProductFactory(
                    user_id=str(another_user.id))

        res = self.api.retrieve(product_to_fetch.id, token_info=self.user_himself)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 200)
        self.assertEqual(res.json['id'], str(product_to_fetch.id))

    def test_list(self):
        self._setup_user_himself_and_roles()

        res = self.api.retrieve_list(token_info=self.user_himself)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 200)
        self.assertEqual(res.json, [])

    @parameterized.expand([
        (True, 'normal'),
        (True, 'admin'),
    ])
    def test_list_with_user_id(self, successful, listing_created_by_role):
        self._setup_user_himself_and_roles()
        for _ in range(3):
            ProductFactory()

        if listing_created_by_role == 'normal':
            user = UserAccountFactory(user_role=self.normal_role)
        elif listing_created_by_role == 'admin':
            user = UserAccountFactory(user_role=self.admin_role)
        else:
            raise ValueError()

        for _ in range(2):
            ProductFactory(user_account=user)
        res = self.api.retrieve_list(user_id=user.id, token_info=self.user)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 200)
        self.assertEqual(len(res.json), 2)

    @parameterized.expand([
        (True, 'normal'),
        (True, 'admin'),
    ])
    def test_list_with_active(self, successful, listing_created_by_role):
        self._setup_user_himself_and_roles()
        if listing_created_by_role == 'normal':
            user = UserAccountFactory(user_role=self.normal_role)
        elif listing_created_by_role == 'admin':
            user = UserAccountFactory(user_role=self.admin_role)
        else:
            raise ValueError()

        for _ in range(3):
            ProductFactory(user_account=user, active=True)
        for _ in range(2):
            ProductFactory(user_account=user, active=False)

        res = self.api.retrieve_list(active=True, token_info=self.user)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 200)
        self.assertEqual(len(res.json), 3)

    # Only reserved for admins.. Same as test_list
    def test_list_empty(self):
        pass

    def test_create(self):
        self._setup_user_himself_and_roles()
        body = {
            'active': True,
            'name': 'test_product',
            'description': 'test description',
            'image_urls': ['a', 'b'],
        }

        res = self.api.create(body=body, token_info=self.user_himself)
        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 201)
        self.assertEqual(res.json['name'], body['name'])

    # product created by himself.. update product success
    # product created by another normal user.. update product failure
    # product created by another admin user.. update product failure
    @parameterized.expand([
        (True, None),
        (False, 'normal'),
        (False, 'admin'),
    ])
    def test_update(self, his_own_product, other_user_type):
        self._setup_user_himself_and_roles()

        if his_own_product:
            product_to_update = ProductFactory(
                user_account=self.user_himself_inst)
        else:
            if other_user_type == 'normal':
                another_user = UserAccountFactory(
                    user_role=self.normal_role)
                product_to_update = ProductFactory(
                    user_id=str(another_user.id))
            elif other_user_type == 'admin':
                another_user = UserAccountFactory(
                    user_role=self.admin_role)
                product_to_update = ProductFactory(
                    user_id=str(another_user.id))

        res = self.api.update(product_to_update.id,
                              body={'name': 'new name'},
                              token_info=self.user_himself)
        if his_own_product:
            self.assertIsNotNone(res.data)
            self.assertEqual(res.status_code, 200)
            self.assertEqual(res.json['id'], str(product_to_update.id))
            self.assertEqual(res.json['name'], 'new name')
        else:
            self.assertIsNotNone(res.data)
            self.assertEqual(res.status_code, 404)
            self.assertEqual(
                res.json['detail'], f'Product with id {str(product_to_update.id)} not found')


if __name__ == '__main__':
    unittest.main()
