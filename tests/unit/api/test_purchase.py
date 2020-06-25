import unittest
from unittest import mock
from parameterized import parameterized

from salsa.api import purchases as purchases_api
from salsa import permission

from tests.unit.api import ApiUnitTestCase, PermissionsTestCase
from tests import SalsaTestCase
from tests.factories import (UserAccountFactory,
                             UserRoleFactory,
                             ListingFactory,
                             ProductFactory,
                             PurchaseFactory)


class TestPurchasesController(ApiUnitTestCase, SalsaTestCase):
    def setUp(self):
        super(TestPurchasesController, self).setUp()
        self.api = purchases_api
        self.factory = PurchaseFactory

    def test_list_with_listing_id(self):
        for _ in range(3):
            PurchaseFactory()

        listing = ListingFactory()
        matched = PurchaseFactory(listing=listing)
        
        res = self.api.retrieve_list(listing_id=listing.id, token_info=self.user)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 200)
        self.assertEqual(len(res.json), 1)
        self.assertEqual(res.json[0]['id'], str(matched.id))

    def test_post(self):
        user_role = UserRoleFactory(title=permission.ADMIN_PERM_TITLE)
        user_account = UserAccountFactory(user_role_id=user_role.id)
        product = ProductFactory(user_account=user_account)
        listing = ListingFactory(product=product)
        body = {
            'amount': 10,
            'notes': 'note for purchase',
            'listing_id': str(listing.id)
        }
        expected = body.copy()

        self._post_valid(body,
                         expected=expected,
                         use_expected_for_body=True,
                         user_id_in_body=str(user_account.id))

    def test_put(self):
        body = {
            'amount': 10,
        }
        self._put_valid(body)

        body = {
            'notes': 'note for purchase',
        }
        self._put_valid(body)

    def test_put_not_found(self):
        self._put_not_found({'amount': 5})


class TestPurchasesPermissions(PermissionsTestCase, SalsaTestCase):
    def setUp(self):
        super(TestPurchasesPermissions, self).setUp()
        self.api = purchases_api
        self.factory = PurchaseFactory

    def tearDown(self):
        super(TestPurchasesPermissions, self).tearDown()

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

    # purchase created by himself.. get purchase success
    # purchase created by another normal user.. get purchase fail
    # purchase created by another admin user.. get purchase fail
    @parameterized.expand([
        (True, None, True),
        (False, 'normal', False),
        (False, 'admin', False),
    ])
    def test_get(self, his_own_purchase, other_user_type, is_successful):
        self._setup_user_himself_and_roles()

        if his_own_purchase:
            listing = ListingFactory()
            purchase_to_fetch = PurchaseFactory(
                listing=listing,
                user_account=self.user_himself_inst)

        else:
            if other_user_type == 'normal':
                listing = ListingFactory()
                another_user = UserAccountFactory(
                    user_role=self.normal_role)
                purchase_to_fetch = PurchaseFactory(
                    listing=listing,
                    user_account=another_user)

            elif other_user_type == 'admin':
                listing = ListingFactory()
                another_user = UserAccountFactory(
                    user_role=self.admin_role)
                purchase_to_fetch = PurchaseFactory(
                    listing=listing,
                    user_account=another_user)

        res = self.api.retrieve(purchase_to_fetch.id, token_info=self.user_himself)

        if is_successful:
            self.assertIsNotNone(res.data)
            self.assertEqual(res.status_code, 200)
            self.assertEqual(res.json['id'], str(purchase_to_fetch.id))
        else:
            self.assertIsNotNone(res.data)
            self.assertEqual(res.status_code, 404)
            self.assertEqual(
                res.json['detail'], f'Purchase with id {str(purchase_to_fetch.id)} not found')

    def test_list_fail_no_user_as_passed(self):
        self._setup_user_himself_and_roles()

        res = self.api.retrieve_list(token_info=self.user_himself)

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 400)

    def test_list(self):
        self._setup_user_himself_and_roles()

        res = self.api.retrieve_list(token_info=self.user_himself,
                                     user_as='buyer')

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 200)
        self.assertEqual(res.json, [])

    # purchase created by himself.. get purchase success
    # purchase created by another normal user.. get purchase fail
    # purchase created by another admin user.. get purchase fail
    @parameterized.expand([
        (True, None, 'buyer', True),
        (False, 'normal', 'buyer', False),
        (False, 'admin', 'buyer', False),
        (True, None, 'seller', True),
        (False, 'normal', 'seller', False),
        (False, 'admin', 'seller', False),
    ])
    def test_list_with_listing_id(self,
                                  his_own_purchase,
                                  other_user_type,
                                  user_as,
                                  is_successful):
        self._setup_user_himself_and_roles()
        
        if his_own_purchase:
            listing = ListingFactory()
            purchase_to_fetch = PurchaseFactory(
                listing=listing,
                user_account=self.user_himself_inst)
        else:
            if other_user_type == 'normal':
                listing = ListingFactory()
                another_user = UserAccountFactory(
                    user_role=self.normal_role)
                purchase_to_fetch = PurchaseFactory(
                    listing=listing,
                    user_account=another_user)

            elif other_user_type == 'admin':
                listing = ListingFactory()
                another_user = UserAccountFactory(
                    user_role=self.admin_role)
                purchase_to_fetch = PurchaseFactory(
                    listing=listing,
                    user_account=another_user)

        res = self.api.retrieve_list(listing_id=listing.id,
                                     token_info=self.user_himself,
                                     user_as='buyer')

        if is_successful:
            self.assertIsNotNone(res.data)
            self.assertEqual(res.status_code, 200)
            self.assertEqual(len(res.json), 1)
            self.assertEqual(res.json[0]['id'], str(purchase_to_fetch.id))
        else:
            self.assertIsNotNone(res.data)
            self.assertEqual(res.status_code, 200)
            self.assertEqual(res.json, [])

    def test_list_with_as_user_buyer(self):
        self._setup_user_himself_and_roles()

        listings = [ListingFactory() for _ in range(5)]

        # Purchases that this user made on listings
        purchases_to_fetch = []
        for listing_ in listings:
            purchases_to_fetch.append(
                PurchaseFactory(
                    listing=listing_,
                    user_account=self.user_himself_inst))

        # Purchases other ppl made on this user's listings.. Should
        # not be returned
        his_listing = ListingFactory(user_account=self.user_himself_inst)
        PurchaseFactory(listing=his_listing)

        res = self.api.retrieve_list(token_info=self.user_himself,
                                     user_as='buyer')

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 200)
        self.assertEqual(len(res.json), 5)

        for idx in range(5):
            self.assertEqual(res.json[idx]['id'],
                             str(purchases_to_fetch[idx].id))

    def test_list_with_as_user_seller(self):
        self._setup_user_himself_and_roles()

        # Purchases other ppl made on this user's listings
        his_listing = ListingFactory(user_account=self.user_himself_inst)
        purchases_to_fetch = [PurchaseFactory(listing=his_listing)
                              for _ in range(5)]

        # Purchases that this user made on other listings.. Should
        # not be returned
        other_listings = [ListingFactory(), ListingFactory()]
        PurchaseFactory(listing=other_listings[0])
        PurchaseFactory(listing=other_listings[1])

        res = self.api.retrieve_list(token_info=self.user_himself,
                                     user_as='seller')

        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 200)
        self.assertEqual(len(res.json), 5)

        for idx in range(5):
            self.assertEqual(res.json[idx]['id'],
                             str(purchases_to_fetch[idx].id))

    def test_list_empty(self):
        pass

    def test_create(self):
        self._setup_user_himself_and_roles()

        listing = ListingFactory()
        body = {
            'amount': 10,
            'notes': 'note for purchase',
            'listing_id': str(listing.id)
        }

        res = self.api.create(body=body, token_info=self.user_himself)
        self.assertIsNotNone(res.data)
        self.assertEqual(res.status_code, 201)
        self.assertEqual(res.json['amount'], body['amount'])
        self.assertEqual(res.json['notes'], body['notes'])

    # purchase created by himself.. update purchase success
    # purchase created by another normal user.. update purchase fail
    # purchase created by another admin user.. update purchase fail
    @parameterized.expand([
        (True, None, True),
        (False, 'normal', False),
        (False, 'admin', False),
    ])
    def test_update(self, his_own_purchase, other_user_type, is_successful):
        self._setup_user_himself_and_roles()

        if his_own_purchase:
            listing = ListingFactory()
            purchase_to_update = PurchaseFactory(
                listing=listing,
                user_account=self.user_himself_inst)

        else:
            if other_user_type == 'normal':
                listing = ListingFactory()
                another_user = UserAccountFactory(
                    user_role=self.normal_role)
                purchase_to_update = PurchaseFactory(
                    listing=listing,
                    user_account=another_user)

            elif other_user_type == 'admin':
                listing = ListingFactory()
                another_user = UserAccountFactory(
                    user_role=self.admin_role)
                purchase_to_update = PurchaseFactory(
                    listing=listing,
                    user_account=another_user)

        res = self.api.update(purchase_to_update.id,
                              body={'amount': 50,
                                    'notes': 'note for purchase'},
                              token_info=self.user_himself)
        if his_own_purchase:
            self.assertIsNotNone(res.data)
            self.assertEqual(res.status_code, 200)
            self.assertEqual(res.json['id'], str(purchase_to_update.id))
            self.assertEqual(res.json['amount'], 50)
            self.assertEqual(res.json['notes'], 'note for purchase')
        else:
            self.assertIsNotNone(res.data)
            self.assertEqual(res.status_code, 404)
            self.assertEqual(
                res.json['detail'], f'Purchase with id {str(purchase_to_update.id)} not found')


if __name__ == '__main__':
    unittest.main()
