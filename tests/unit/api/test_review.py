import unittest
from unittest import mock
from parameterized import parameterized

from salsa.api import reviews as reviews_api
from salsa import permission

from tests.unit.api import ApiUnitTestCase, PermissionsTestCase
from tests import SalsaTestCase
from tests.factories import (UserAccountFactory,
                             UserRoleFactory,
                             ListingFactory,
                             ProductFactory,
                             PurchaseFactory,
                             ReviewFactory)


class TestReviewsController(ApiUnitTestCase, SalsaTestCase):
    def setUp(self):
        super(TestReviewsController, self).setUp()
        self.api = reviews_api
        self.factory = ReviewFactory

    def test_post(self):
        # Someone else's product and listing
        listing = ListingFactory()

        user_role = UserRoleFactory(title=permission.ADMIN_PERM_TITLE)
        user_account = UserAccountFactory(user_role_id=user_role.id)
        purchase = PurchaseFactory(listing=listing,
                                   user_account=user_account)
        body = {
            'name': 'test review name',
            'description': 'test description',
            'numstars': 5,
            'product_id': str(listing.product.id),
            'purchase_id': str(purchase.id),
        }
        expected = body.copy()

        self._post_valid(body,
                         expected=expected,
                         use_expected_for_body=True,
                         user_id_in_body=str(user_account.id))

    def test_post_invalid_purchase_id(self):
        listing = ListingFactory()

        user_role = UserRoleFactory(title=permission.ADMIN_PERM_TITLE)
        user_account = UserAccountFactory(user_role_id=user_role.id)

        # somone else's purchase
        purchase = PurchaseFactory(listing=listing)
        purchase_id = str(purchase.id)
        body = {
            'name': 'test review name',
            'description': 'test description',
            'numstars': 5,
            'product_id': str(listing.product.id),
            'purchase_id': purchase_id,
        }
        expected = body.copy()

        self._post_invalid(body,
                           err=f'Purchase with id {purchase_id} not found',
                           error_code=404,
                           user_id_in_body=str(user_account.id))

    def test_post_invalid_product_id(self):
        invalid_product = ProductFactory()

        user_role = UserRoleFactory(title=permission.ADMIN_PERM_TITLE)
        user_account = UserAccountFactory(user_role_id=user_role.id)

        # somone else's purchase
        purchase = PurchaseFactory(user_account=user_account)
        purchase_id = str(purchase.id)
        body = {
            'name': 'test review name',
            'description': 'test description',
            'numstars': 5,
            'product_id': str(invalid_product.id),
            'purchase_id': purchase_id,
        }
        expected = body.copy()

        self._post_invalid(
            body,
            err=f'Product associated with purchase_id {purchase_id} was not found',
            error_code=404,
            user_id_in_body=str(user_account.id))

    def test_post_invalid_duplicate_review(self):
        # Someone else's product and listing
        listing = ListingFactory()

        user_role = UserRoleFactory(title=permission.ADMIN_PERM_TITLE)
        user_account = UserAccountFactory(user_role_id=user_role.id)
        purchase = PurchaseFactory(listing=listing,
                                   user_account=user_account)
        # existing review
        existing = ReviewFactory(product=listing.product,
                                 user_account=user_account,
                                 purchase=purchase)

        body = {
            'name': 'duplicate review name',
            'description': 'duplicate review description',
            'numstars': 5,
            'product_id': str(listing.product.id),
            'purchase_id': str(purchase.id),
        }
        expected = body.copy()

        self._post_invalid(
            body,
            err='Review already exists',
            error_code=400,
            user_id_in_body=str(user_account.id))

    def test_put(self):
        body = {
            'description': 'new description',
        }
        self._put_valid(body)

    def test_put_not_found(self):
        self._put_not_found({'description': 'new description'})


class TestReviewsPermissions(PermissionsTestCase, SalsaTestCase):
    def setUp(self):
        super(TestReviewsPermissions, self).setUp()
        self.api = reviews_api
        self.factory = ReviewFactory

    def tearDown(self):
        super(TestReviewsPermissions, self).tearDown()

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

    # review created by himself.. get review success
    # review created by another normal user.. get review success
    # review created by another admin user.. get review success
    @parameterized.expand([
        (True, None),
        (False, 'normal'),
        (False, 'admin'),
    ])
    def test_get(self, his_own_review, other_user_type):
        self._setup_user_himself_and_roles()

        if his_own_review:
            review_to_fetch = ReviewFactory(
                user_account=self.user_himself_inst)
        else:
            if other_user_type == 'normal':
                another_user = UserAccountFactory(
                    user_role=self.normal_role)
                review_to_fetch = ReviewFactory(
                    user_account=another_user)

            elif other_user_type == 'admin':
                another_user = UserAccountFactory(
                    user_role=self.admin_role)
                review_to_fetch = ReviewFactory(
                    user_account=another_user)

        res = self.api.retrieve(review_to_fetch.id, token_info=self.user_himself)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 200)
        self.assertEqual(res.json['id'], str(review_to_fetch.id))

    def test_list(self):
        self._setup_user_himself_and_roles()

        res = self.api.retrieve_list(token_info=self.user_himself)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 200)
        self.assertEqual(res.json, [])

    def test_list_empty(self):
        pass

    def test_create(self):
        self._setup_user_himself_and_roles()

        # Someone else's product and listing
        listing = ListingFactory()

        purchase = PurchaseFactory(listing=listing,
                                   user_account=self.user_himself_inst)
        body = {
            'name': 'test review name',
            'description': 'test description',
            'numstars': 5,
            'product_id': str(listing.product.id),
            'purchase_id': str(purchase.id),
        }

        res = self.api.create(body=body, token_info=self.user_himself)
        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 201)
        self.assertEqual(res.json['numstars'], body['numstars'])

    def test_create_invalid_purchase_id(self):
        self._setup_user_himself_and_roles()

        # Someone else's product and listing
        listing = ListingFactory()

        # somone else's purchase
        purchase = PurchaseFactory(listing=listing)
        purchase_id = str(purchase.id)
        body = {
            'name': 'test review name',
            'description': 'test description',
            'numstars': 5,
            'product_id': str(listing.product.id),
            'purchase_id': purchase_id,
        }
        expected = body.copy()

        res = self.api.create(body=body, token_info=self.user_himself)
        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 404)
        self.assertEqual(
            res.json['detail'], f'Purchase with id {purchase_id} not found')

    def test_create_invalid_product_id(self):
        self._setup_user_himself_and_roles()

        # Someone else's product and listing
        invalid_product = ProductFactory()

        # somone else's purchase
        purchase = PurchaseFactory(user_account=self.user_himself_inst)
        purchase_id = str(purchase.id)
        body = {
            'name': 'test review name',
            'description': 'test description',
            'numstars': 5,
            'product_id': str(invalid_product.id),
            'purchase_id': purchase_id,
        }
        expected = body.copy()

        res = self.api.create(body=body, token_info=self.user_himself)
        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 404)
        self.assertEqual(
            res.json['detail'], f'Product associated with purchase_id {purchase_id} was not found')

    def test_create_invalid_duplicate_review(self):
        self._setup_user_himself_and_roles()

        # Someone else's product and listing
        listing = ListingFactory()

        purchase = PurchaseFactory(listing=listing,
                                   user_account=self.user_himself_inst)
        # existing review
        existing = ReviewFactory(product=listing.product,
                                 user_account=self.user_himself_inst,
                                 purchase=purchase)

        body = {
            'name': 'duplicate review name',
            'description': 'duplicate review description',
            'numstars': 5,
            'product_id': str(listing.product.id),
            'purchase_id': str(purchase.id),
        }
        expected = body.copy()

        res = self.api.create(body=body, token_info=self.user_himself)
        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 400)
        self.assertEqual(res.json['detail'], 'Review already exists')

    # review created by himself.. update review success
    # review created by another normal user.. update review fail
    # review created by another admin user.. update review fail
    @parameterized.expand([
        (True, None, True),
        (False, 'normal', False),
        (False, 'admin', False),
    ])
    def test_update(self, his_own_review, other_user_type, is_successful):
        self._setup_user_himself_and_roles()

        if his_own_review:
            review_to_update = ReviewFactory(
                user_account=self.user_himself_inst)

        else:
            if other_user_type == 'normal':
                another_user = UserAccountFactory(
                    user_role=self.normal_role)
                review_to_update = ReviewFactory(
                    user_account=another_user)

            elif other_user_type == 'admin':
                another_user = UserAccountFactory(
                    user_role=self.admin_role)
                review_to_update = ReviewFactory(
                    user_account=another_user)

        res = self.api.update(review_to_update.id,
                              body={'description': 'new description'},
                              token_info=self.user_himself)
        if his_own_review:
            self.assertIsNotNone(res.data)
            self.assertEqual(res.status_code, 200)
            self.assertEqual(res.json['id'], str(review_to_update.id))
            self.assertEqual(res.json['description'], 'new description')
        else:
            self.assertIsNotNone(res.data)
            self.assertEqual(res.status_code, 404)
            self.assertEqual(
                res.json['detail'], f'Review with id {str(review_to_update.id)} not found')


if __name__ == '__main__':
    unittest.main()
