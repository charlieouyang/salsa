import unittest
import uuid
from unittest import mock
from parameterized import parameterized

from salsa import permission
from salsa.db import db
from salsa.api import product_categories as product_categories_api

from tests.unit.api import ApiUnitTestCase, PermissionsTestCase
from tests import SalsaTestCase
from tests.factories import (ProductFactory,
                             CategoryFactory,
                             ProductCategoryFactory,
                             UserAccountFactory,
                             UserRoleFactory)


class TestProductCategoryController(ApiUnitTestCase, SalsaTestCase):
    def setUp(self):
        super(TestProductCategoryController, self).setUp()
        self.api = product_categories_api
        self.factory = ProductCategoryFactory

    def test_get(self):
        pass

    def test_get_not_found(self):
        pass

    def test_list_with_product_id(self):
        for _ in range(3):
            ProductCategoryFactory()

        matched_product = ProductFactory()
        matched_category = CategoryFactory()
        matched_pc = ProductCategoryFactory(product=matched_product,
                                            category=matched_category)

        res = self.api.retrieve(str(matched_product.id), token_info=self.user)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 200)
        self.assertEqual(len(res.json), 1)
        self.assertEqual(res.json[0]['id'], str(matched_pc.id))
        self.assertEqual(res.json[0]['product_id'], str(matched_product.id))
        self.assertEqual(res.json[0]['category_id'], str(matched_category.id))

    def test_list_with_product_id_a_lot_of_categories(self):
        for _ in range(3):
            ProductCategoryFactory()

        matched_product = ProductFactory()
        categories = [CategoryFactory() for _ in range(5)]
        matched_pcs = [ProductCategoryFactory(product=matched_product,
                                              category=categories[0]),
                       ProductCategoryFactory(product=matched_product,
                                              category=categories[1]),
                       ProductCategoryFactory(product=matched_product,
                                              category=categories[2]),
                       ProductCategoryFactory(product=matched_product,
                                              category=categories[3]),
                       ProductCategoryFactory(product=matched_product,
                                              category=categories[4])]

        res = self.api.retrieve(str(matched_product.id), token_info=self.user)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 200)
        self.assertEqual(len(res.json), 5)

        for idx in range(5):
            self.assertEqual(res.json[idx]['id'],
                             str(matched_pcs[idx].id))
            self.assertEqual(res.json[idx]['product_id'],
                             str(matched_pcs[idx].product.id))
            self.assertEqual(res.json[idx]['category_id'],
                             str(matched_pcs[idx].category.id))

    def test_list_with_invalid_product_id(self):
        for _ in range(3):
            ProductCategoryFactory()

        matched_pc = ProductCategoryFactory()
        invalid_product_id = str(uuid.uuid4())

        res = self.api.retrieve(invalid_product_id, token_info=self.user)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 404)
        self.assertEqual(res.json['detail'],
                         f'Product with id {invalid_product_id} not found')

    def test_create_product_categories_simple(self):
        product = ProductFactory()
        category = CategoryFactory()

        body = {
            'product_id': str(product.id),
            'category_ids': [str(category.id)]
        }

        self.api.create(body=body, token_info=self.user)

        instances = db.session.query(self.api.model).all()

        self.assertEqual(len(instances), 1)
        self.assertEqual(instances[0].product_id, product.id)
        self.assertEqual(instances[0].category_id, category.id)

    def test_create_product_categories_many(self):
        product = ProductFactory()
        categories = [CategoryFactory() for _ in range(3)]

        body = {
            'product_id': str(product.id),
            'category_ids': [str(cat.id) for cat in categories]
        }

        self.api.create(body=body, token_info=self.user)

        instances = db.session.query(self.api.model).all()

        self.assertEqual(len(instances), 3)
        for idx in range(3):
            self.assertEqual(instances[idx].product_id, product.id)
            self.assertEqual(instances[idx].category_id, categories[idx].id)

    def test_create_product_categories_missing_product_id(self):
        invalid_product_id = str(uuid.uuid4())
        category = CategoryFactory()

        body = {
            'product_id': invalid_product_id,
            'category_ids': [str(category.id)]
        }

        res = self.api.create(body=body, token_info=self.user)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 404)
        self.assertEqual(res.json['detail'],
                         f'Product with id {invalid_product_id} not found')

        instances = db.session.query(self.api.model).all()
        self.assertEqual(len(instances), 0)

    def test_create_product_categories_missing_category_id(self):
        product = ProductFactory()
        invalid_category_id = str(uuid.uuid4())

        body = {
            'product_id': str(product.id),
            'category_ids': [invalid_category_id]
        }

        res = self.api.create(body=body, token_info=self.user)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 404)
        self.assertEqual(res.json['detail'],
                         f'Category with id {invalid_category_id} not found')

        instances = db.session.query(self.api.model).all()
        self.assertEqual(len(instances), 0)


class TestProductCategoryPermissions(PermissionsTestCase, SalsaTestCase):
    def setUp(self):
        super(TestProductCategoryPermissions, self).setUp()
        self.api = product_categories_api
        self.factory = ProductCategoryFactory

    def tearDown(self):
        super(TestProductCategoryPermissions, self).tearDown()

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

    def test_get(self):
        pass

    def test_get_not_found(self):
        pass

    # product_category created by himself.. get product_category success
    # product_category created by another normal user.. get product_category success
    # product_category created by another admin user.. get product_category success
    @parameterized.expand([
        (True, None, True),
        (False, 'normal', True),
        (False, 'admin', True),
    ])
    def test_list_with_product_id(self, his_own_prod_cat, other_user_type, is_successful):
        for _ in range(3):
            ProductCategoryFactory()

        self._setup_user_himself_and_roles()

        if his_own_prod_cat:
            matched_product = ProductFactory(
                user_account=self.user_himself_inst)
            matched_category = CategoryFactory()
            matched_pc = ProductCategoryFactory(
                product=matched_product,
                category=matched_category)

        else:
            if other_user_type == 'normal':
                another_user = UserAccountFactory(
                    user_role=self.normal_role)
                matched_product = ProductFactory(
                    user_account=another_user)
                matched_category = CategoryFactory()
                matched_pc = ProductCategoryFactory(
                    product=matched_product,
                    category=matched_category)

            elif other_user_type == 'admin':
                another_user = UserAccountFactory(
                    user_role=self.admin_role)
                matched_product = ProductFactory(
                    user_account=another_user)
                matched_category = CategoryFactory()
                matched_pc = ProductCategoryFactory(
                    product=matched_product,
                    category=matched_category)

        res = self.api.retrieve(str(matched_product.id), token_info=self.user_himself)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 200)
        self.assertEqual(len(res.json), 1)
        self.assertEqual(res.json[0]['id'], str(matched_pc.id))
        self.assertEqual(res.json[0]['product_id'], str(matched_product.id))
        self.assertEqual(res.json[0]['category_id'], str(matched_category.id))

    # product created by himself.. create product_category success
    # product created by another normal user.. create product_category failure
    # product created by another admin user.. create product_category failure
    @parameterized.expand([
        (True, None, True),
        (False, 'normal', False),
        (False, 'admin', False),
    ])
    def test_create_product_categories(self,
                                       his_own_product,
                                       other_user_type,
                                       is_successful):
        product = ProductFactory()
        category = CategoryFactory()

        self._setup_user_himself_and_roles()

        if his_own_product:
            product = ProductFactory(
                user_account=self.user_himself_inst)
        else:
            if other_user_type == 'normal':
                another_user = UserAccountFactory(
                    user_role=self.normal_role)
                product = ProductFactory(
                    user_account=another_user)

            elif other_user_type == 'admin':
                another_user = UserAccountFactory(
                    user_role=self.admin_role)
                product = ProductFactory(
                    user_account=another_user)

        body = {
            'product_id': str(product.id),
            'category_ids': [str(category.id)]
        }

        res = self.api.create(body=body, token_info=self.user_himself)

        if is_successful:
            self.assertIsNotNone(res.data)
            self.assertEqual(res.status_code, 201)

            instances = db.session.query(self.api.model).all()

            self.assertEqual(len(instances), 1)
            self.assertEqual(instances[0].product_id, product.id)
            self.assertEqual(instances[0].category_id, category.id)
        else:
            instances = db.session.query(self.api.model).all()
            self.assertIsNotNone(res.data)
            self.assertEqual(res.status_code, 404)
            self.assertEqual(
                res.json['detail'], f'Product with id {str(product.id)} not found')


if __name__ == '__main__':
    unittest.main()
