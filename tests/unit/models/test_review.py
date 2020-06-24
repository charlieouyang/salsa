import unittest
from parameterized import parameterized

from sqlalchemy.exc import IntegrityError

from salsa.db import db
from salsa.models import UserAccount, Purchase, Product, Review
from salsa.exc import ResourceNotFoundError
from tests import SalsaTestCase
from tests import admin_user, basic_user
from tests.factories import (UserAccountFactory,
                             ProductFactory,
                             PurchaseFactory,
                             ReviewFactory)


class ReviewTest(SalsaTestCase):
    def test_valid_listing(self):
        review = ReviewFactory()

        self.assertEqual([review], db.session.query(Review).all())

    def test_find_by_id_success(self):
        review = ReviewFactory()
        es = Review.find_by_id(review.id)
        self.assertEqual(review, es)

    @parameterized.expand([
        (admin_user(), True),
        (admin_user(), False),
        (basic_user(), True),
    ])
    def test_can_update_by_ids_for_user_success(self, user, use_same_user):
        if use_same_user:
            review = ReviewFactory()
            user['usr']['id'] = str(review.user_id)
        else:
            review = ReviewFactory()

        res = Review.can_update_ids_by_user([review.id], user)
        self.assertEqual([review], res)

    def test_can_update_by_ids_for_user_failure(self):
        review = ReviewFactory()

        user = basic_user()
        another_account = UserAccountFactory()
        user['usr']['id'] = str(another_account.id)

        with self.assertRaises(ResourceNotFoundError):
            Review.can_update_ids_by_user([review.id], user)


if __name__ == '__main__':
    unittest.main()
