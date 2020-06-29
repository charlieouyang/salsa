import unittest
from parameterized import parameterized

from sqlalchemy.exc import IntegrityError

from salsa.db import db
from salsa.models import UserAccount, Purchase, Listing
from salsa.exc import ResourceNotFoundError
from tests import SalsaTestCase
from tests import admin_user, basic_user
from tests.factories import (UserAccountFactory,
                             ListingFactory,
                             PurchaseFactory,
                             ProductFactory)


class PurchaseTest(SalsaTestCase):
    def test_valid_listing(self):
        purchase = PurchaseFactory()

        self.assertEqual(purchase.buyer_complete, False)
        self.assertEqual(purchase.seller_complete, False)
        self.assertEqual([purchase], db.session.query(Purchase).all())

    def test_find_by_id_success(self):
        purchase = PurchaseFactory()
        es = Purchase.find_by_id(purchase.id)
        self.assertEqual(purchase, es)

    def test_check_purchase_made_on_product_valid(self):
        purchase = PurchaseFactory()
        Purchase.check_purchase_made_on_product(
            purchase.id, purchase.listing.product.id)

    def test_check_purchase_made_on_product_invalid(self):
        mismatched_product = ProductFactory()
        purchase = PurchaseFactory()

        with self.assertRaises(ResourceNotFoundError):
            Purchase.check_purchase_made_on_product(
                purchase.id, mismatched_product.id)

    def test_belongs_to_user_valid(self):
        for user in [admin_user(), basic_user()]:
            purchase = PurchaseFactory()
            user['usr']['id'] = str(purchase.user_id)
            Purchase.belongs_to_user(purchase.id, user)

    def test_belongs_to_user_invalid(self):
        for user in [admin_user(), basic_user()]:
            purchase = PurchaseFactory()

            another_account = UserAccountFactory()
            user['usr']['id'] = str(another_account.id)

            with self.assertRaises(ResourceNotFoundError):
                Purchase.belongs_to_user(purchase.id, user)

    @parameterized.expand([
        (admin_user(), True, False),
        (admin_user(), False, False),
        (basic_user(), True, False),
        (basic_user(), False, True)
    ])
    def test_can_update_by_ids_for_user_success(self,
            user, use_same_user, listing_created_by_user):
        if use_same_user:
            purchase = PurchaseFactory()
            user['usr']['id'] = str(purchase.user_id)
        else:
            purchase = PurchaseFactory()
            user['usr']['id'] = str(purchase.listing.user_id)

        res = Purchase.can_update_ids_by_user([purchase.id], user)
        self.assertEqual([purchase], res)

    def test_can_update_by_ids_for_user_failure(self):
        purchase = PurchaseFactory()

        user = basic_user()
        another_account = UserAccountFactory()
        user['usr']['id'] = str(another_account.id)

        with self.assertRaises(ResourceNotFoundError):
            Purchase.can_update_ids_by_user([purchase.id], user)


if __name__ == '__main__':
    unittest.main()
