import unittest
from unittest import mock
from parameterized import parameterized

from salsa.api import listings as listings_api
from salsa import permission

from tests.unit.api import ApiUnitTestCase, PermissionsTestCase
from tests import SalsaTestCase
from tests.factories import (UserAccountFactory,
                             UserRoleFactory,
                             ListingFactory,
                             ProductFactory,
                             CategoryFactory,
                             ProductCategoryFactory)


class TestListingsController(ApiUnitTestCase, SalsaTestCase):
    def setUp(self):
        super(TestListingsController, self).setUp()
        self.api = listings_api
        self.factory = ListingFactory

    def test_list_with_name_search_only_listing(self):
        # Test search functionality accross listings and its products
        # 1. result is in listing but not product
        for _ in range(3):
            ListingFactory()

        matches = [ListingFactory(name='This is a beef steak'),
                   ListingFactory(description='Beef steaks are delicious'),]
        listing_ids = [str(mt.id) for mt in matches]

        res = self.api.retrieve_list(name='beef', token_info=self.user)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 200)
        self.assertEqual(len(res.json), 2)

        res_listing_ids = [res_['id'] for res_ in res.json]
        self.assertEqual(res_listing_ids, listing_ids)

    def test_list_with_name_search_only_product(self):
        # Test search functionality accross listings and its products
        # 2. result is in product but not listing
        for _ in range(3):
            ListingFactory()

        matched_products = [ProductFactory(name='This is a beef steak'),
                            ProductFactory(description='Beef steaks are delicious'),]
        matches = [ListingFactory(product=matched_products[0]),
                   ListingFactory(product=matched_products[1]),]
        listing_ids = [str(mt.id) for mt in matches]

        res = self.api.retrieve_list(name='beef', token_info=self.user)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 200)
        self.assertEqual(len(res.json), 2)

        res_listing_ids = [res_['id'] for res_ in res.json]
        self.assertEqual(res_listing_ids, listing_ids)

    def test_list_with_name_search_both_listing_and_product(self):
        # Test search functionality accross listings and its products
        # 3. result is in both listing AND product
        for _ in range(3):
            ListingFactory()

        matched_products = [ProductFactory(name='This is a beef steak'),
                            ProductFactory(description='Beef steaks are delicious'),]
        matches = [ListingFactory(product=matched_products[0],
                                  description='Beef steak for sale!'),
                   ListingFactory(product=matched_products[1],
                                  name='Get your BEEF STEAKS here!'),]
        listing_ids = [str(mt.id) for mt in matches]

        res = self.api.retrieve_list(name='beef', token_info=self.user)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 200)
        self.assertEqual(len(res.json), 2)

        res_listing_ids = [res_['id'] for res_ in res.json]
        self.assertEqual(res_listing_ids, listing_ids)

    def test_list_with_name_and_category_search_simple(self):
        # Test search functionality accross listings
        # and its products and its product_categories
        # 4. result is in product_categories
        for _ in range(3):
            ListingFactory()

        beef_category = CategoryFactory(name="Beef")

        matched_products = [ProductFactory(name='Beef steak',
                                           description='Beef steaks are delicious'),
                            ProductFactory(name='Beef rib',
                                           description='Beef short ribs so good'),]

        ProductCategoryFactory(product=matched_products[0],
                               category=beef_category)
        ProductCategoryFactory(product=matched_products[1],
                               category=beef_category)

        matches = [ListingFactory(product=matched_products[0],
                                  description='Beef steak for sale!'),
                   ListingFactory(product=matched_products[1],
                                  name='Get your ribs here!'),]

        listing_ids = [str(mt.id) for mt in matches]

        res = self.api.retrieve_list(category_ids=[str(beef_category.id)],
                                     token_info=self.user)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 200)
        self.assertEqual(len(res.json), 2)

        res_listing_ids = [res_['id'] for res_ in res.json]
        self.assertEqual(res_listing_ids, listing_ids)

    def test_list_with_name_and_category_search_complicated(self):
        # Test search functionality accross listings
        # and its products and its product_categories
        # 5. result is in both listing AND product AND product_categories
        for _ in range(3):
            ListingFactory()

        meat_category = CategoryFactory(name="Meat")
        beef_category = CategoryFactory(name="Beef")

        matched_products = [ProductFactory(name='Beef steak',
                                           description='Beef steaks are delicious'),
                            ProductFactory(name='Beef rib',
                                           description='Beef short ribs so good'),]
        not_matched_product = ProductFactory(name='Chicken',
                                             description='Chicken breasts are so good')

        ProductCategoryFactory(product=matched_products[0],
                               category=meat_category)
        ProductCategoryFactory(product=matched_products[0],
                               category=beef_category)
        ProductCategoryFactory(product=matched_products[1],
                               category=meat_category)
        ProductCategoryFactory(product=matched_products[1],
                               category=beef_category)
        ProductCategoryFactory(product=not_matched_product,
                               category=meat_category)

        matches = [ListingFactory(product=matched_products[0],
                                  description='Beef steak for sale!'),
                   ListingFactory(product=matched_products[1],
                                  name='Get your ribs here!'),]
        not_matched = ListingFactory(product=not_matched_product,
                                     name='Get your CHICKEN here!')

        listing_ids = [str(mt.id) for mt in matches]

        res = self.api.retrieve_list(name='beef',
                                     category_ids=[str(beef_category.id)],
                                     token_info=self.user)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 200)
        self.assertEqual(len(res.json), 2)

        res_listing_ids = [res_['id'] for res_ in res.json]
        self.assertEqual(res_listing_ids, listing_ids)

    def test_list_with_name_search_no_matches(self):
        # Test search functionality accross listings and its products
        # 5. no results
        for _ in range(3):
            ListingFactory()

        res = self.api.retrieve_list(name='beef', token_info=self.user)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 200)
        self.assertEqual(len(res.json), 0)
        self.assertEqual(res.json, [])

    def test_list_with_user_id(self):
        for _ in range(3):
            ListingFactory()

        user = UserAccountFactory()
        for _ in range(2):
            ListingFactory(user_account=user)
        res = self.api.retrieve_list(user_id=user.id, token_info=self.user)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 200)
        self.assertEqual(len(res.json), 2)

    def test_list_with_active(self):
        for _ in range(3):
            ListingFactory(active=True)
        for _ in range(2):
            ListingFactory(active=False)

        res = self.api.retrieve_list(active=True, token_info=self.user)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 200)
        self.assertEqual(len(res.json), 3)

    def test_list_with_product_id(self):
        product = ProductFactory()
        for _ in range(2):
            ListingFactory(product=product)

        res = self.api.retrieve_list(product_id=product.id, token_info=self.user)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 200)
        self.assertEqual(len(res.json), 2)

    def test_list_with_filter(self):
        self._list_with_filter(name='test_name_1')

    def test_post(self):
        user_role = UserRoleFactory(title=permission.ADMIN_PERM_TITLE)
        user_account = UserAccountFactory(user_role_id=user_role.id)
        product = ProductFactory(user_account=user_account)
        body = {
            'active': True,
            'name': 'test_product',
            'description': 'test description',
            'price': 69.99,
            'amount_available': 100,
            'product_id': str(product.id)
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


class TestListingsPermissions(PermissionsTestCase, SalsaTestCase):
    def setUp(self):
        super(TestListingsPermissions, self).setUp()
        self.api = listings_api
        self.factory = ListingFactory

    def tearDown(self):
        super(TestListingsPermissions, self).tearDown()

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

    # listing created by himself.. get listing success
    # listing created by another normal user.. get listing success
    # listing created by another admin user.. get listing success
    @parameterized.expand([
        (True, None),
        (False, 'normal'),
        (False, 'admin'),
    ])
    def test_get(self, his_own_listing, other_user_type):
        self._setup_user_himself_and_roles()

        if his_own_listing:
            product = ProductFactory(
                user_account=self.user_himself_inst)
            listing_to_fetch = ListingFactory(
                product=product,
                user_account=self.user_himself_inst)

        else:
            if other_user_type == 'normal':
                another_user = UserAccountFactory(
                    user_role=self.normal_role)
                product = ProductFactory(
                    user_account=another_user)
                listing_to_fetch = ListingFactory(
                    product=product,
                    user_account=another_user)
            elif other_user_type == 'admin':
                another_user = UserAccountFactory(
                    user_role=self.admin_role)
                product = ProductFactory(
                    user_account=another_user)
                listing_to_fetch = ListingFactory(
                    product=product,
                    user_account=another_user)

        res = self.api.retrieve(listing_to_fetch.id, token_info=self.user_himself)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 200)
        self.assertEqual(res.json['id'], str(listing_to_fetch.id))

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
            ListingFactory()

        if listing_created_by_role == 'normal':
            user = UserAccountFactory(user_role=self.normal_role)
        elif listing_created_by_role == 'admin':
            user = UserAccountFactory(user_role=self.admin_role)
        else:
            raise ValueError()

        for _ in range(2):
            ListingFactory(user_account=user)

        res = self.api.retrieve_list(user_id=user.id, token_info=self.user_himself)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 200)
        self.assertEqual(len(res.json), 2)

    @parameterized.expand([
        (True, 'normal'),
        (True, 'admin'),
    ])
    def test_list_with_name_different_matches(self, successful, listing_created_by_role):
        self._setup_user_himself_and_roles()
        for _ in range(3):
            ListingFactory()

        if listing_created_by_role == 'normal':
            user = UserAccountFactory(user_role=self.normal_role)
        elif listing_created_by_role == 'admin':
            user = UserAccountFactory(user_role=self.admin_role)
        else:
            raise ValueError()

        matched_products = [ProductFactory(name='This is a beef steak',
                                           user_account=user),
                            ProductFactory(user_account=user),]
        matches = [ListingFactory(product=matched_products[0],
                                  user_account=user),
                   ListingFactory(product=matched_products[1],
                                  name='Get your BEEF STEAKS here!',
                                  user_account=user),]
        listing_ids = [str(mt.id) for mt in matches]

        res = self.api.retrieve_list(name='beef', token_info=self.user)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 200)
        self.assertEqual(len(res.json), 2)

        res_listing_ids = [res_['id'] for res_ in res.json]
        self.assertEqual(res_listing_ids, listing_ids)

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
            ListingFactory(user_account=user, active=True)
        for _ in range(2):
            ListingFactory(user_account=user, active=False)

        res = self.api.retrieve_list(active=True, token_info=self.user_himself)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 200)
        self.assertEqual(len(res.json), 3)

    @parameterized.expand([
        (True, 'normal'),
        (True, 'admin'),
    ])
    def test_list_with_product_id(self, successful, listing_created_by_role):
        self._setup_user_himself_and_roles()
        if listing_created_by_role == 'normal':
            user = UserAccountFactory(user_role=self.normal_role)
        elif listing_created_by_role == 'admin':
            user = UserAccountFactory(user_role=self.admin_role)
        else:
            raise ValueError()

        product = ProductFactory(user_account=user)
        for _ in range(2):
            ListingFactory(user_account=user, product=product)

        res = self.api.retrieve_list(product_id=product.id, token_info=self.user_himself)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 200)
        self.assertEqual(len(res.json), 2)

    def test_list_empty(self):
        pass

    def test_create(self):
        self._setup_user_himself_and_roles()

        product = ProductFactory(user_account=self.user_himself_inst)
        body = {
            'active': True,
            'name': 'test_product',
            'description': 'test description',
            'price': 69.99,
            'amount_available': 100,
            'product_id': str(product.id)
        }

        res = self.api.create(body=body, token_info=self.user_himself)
        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 201)
        self.assertEqual(res.json['name'], body['name'])

    def test_create_with_someone_else_product_failure(self):
        self._setup_user_himself_and_roles()

        another_user = UserAccountFactory()
        product = ProductFactory(user_account=another_user)
        body = {
            'active': True,
            'name': 'test_product',
            'description': 'test description',
            'price': 69.99,
            'amount_available': 100,
            'product_id': str(product.id)
        }

        res = self.api.create(body=body, token_info=self.user_himself)
        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 404)
        self.assertEqual(res.json['detail'], f'Product with id {str(product.id)} not found')

    # listing created by himself.. update listing success
    # listing created by another normal user.. update listing failure
    # listing created by another admin user.. update listing failure
    @parameterized.expand([
        (True, None),
        (False, 'normal'),
        (False, 'admin'),
    ])
    def test_update(self, his_own_listing, other_user_type):
        self._setup_user_himself_and_roles()

        if his_own_listing:
            product = ProductFactory(
                user_account=self.user_himself_inst)
            listing_to_update = ListingFactory(
                product=product,
                user_account=self.user_himself_inst)

        else:
            if other_user_type == 'normal':
                another_user = UserAccountFactory(
                    user_role=self.normal_role)
                product = ProductFactory(
                    user_account=another_user)
                listing_to_update = ListingFactory(
                    product=product,
                    user_account=another_user)
            elif other_user_type == 'admin':
                another_user = UserAccountFactory(
                    user_role=self.admin_role)
                product = ProductFactory(
                    user_account=another_user)
                listing_to_update = ListingFactory(
                    product=product,
                    user_account=another_user)

        res = self.api.update(listing_to_update.id,
                              body={'name': 'new name'},
                              token_info=self.user_himself)
        if his_own_listing:
            self.assertIsNotNone(res.data)
            self.assertEqual(res.status_code, 200)
            self.assertEqual(res.json['id'], str(listing_to_update.id))
            self.assertEqual(res.json['name'], 'new name')
        else:
            self.assertIsNotNone(res.data)
            self.assertEqual(res.status_code, 404)
            self.assertEqual(
                res.json['detail'], f'Listing with id {str(listing_to_update.id)} not found')


if __name__ == '__main__':
    unittest.main()
