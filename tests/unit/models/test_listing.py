import unittest
from parameterized import parameterized

from sqlalchemy.exc import IntegrityError

from salsa.db import db
from salsa.models import UserAccount, Product, Listing
from salsa.exc import ResourceNotFoundError
from tests import SalsaTestCase
from tests import admin_user, basic_user
from tests.factories import UserAccountFactory, ProductFactory, ListingFactory


class ListingTest(SalsaTestCase):
    def test_valid_listing(self):
        listing = ListingFactory(name='listing_name')

        self.assertEqual([listing], db.session.query(Listing).all())
        self.assertEqual(listing.name, 'listing_name')

    def test_find_by_id_success(self):
        listing = ListingFactory(name='listing_name')
        es = Listing.find_by_id(listing.id)
        self.assertEqual(listing, es)

    @parameterized.expand([
        (admin_user(), True),
        (admin_user(), False),
        (basic_user(), True),
    ])
    def test_can_update_by_ids_for_user_success(self, user, use_same_user):
        if use_same_user:
            listing = ListingFactory()
            user['usr']['id'] = str(listing.user_id)
        else:
            listing = ListingFactory()

        res = Listing.can_update_ids_by_user([listing.id], user)
        self.assertEqual([listing], res)

    def test_can_update_by_ids_for_user_failure(self):
        listing = ListingFactory()

        user = basic_user()
        another_account = UserAccountFactory()
        user['usr']['id'] = str(another_account.id)

        with self.assertRaises(ResourceNotFoundError):
            Listing.can_update_ids_by_user([listing.id], user)


if __name__ == '__main__':
    unittest.main()
