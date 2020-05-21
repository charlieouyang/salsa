import unittest
from parameterized import parameterized

from sqlalchemy.exc import IntegrityError

from salsa.db import db
from salsa.models import UserAccount
from salsa.exc import ResourceNotFoundError
from tests import SalsaTestCase
from tests import admin_user, basic_user
from tests.factories import UserAccountFactory


class UserAccountTest(SalsaTestCase):
    def test_valid_user_account(self):
        user_account = UserAccountFactory(user_name='user_name')

        self.assertEqual([user_account], db.session.query(UserAccount).all())
        self.assertEqual(user_account.user_name, 'user_name')

    def test_duplicate_error(self):
        UserAccountFactory(user_name='user_name')

        with self.assertRaises(IntegrityError):
            UserAccountFactory(user_name='user_name')

    def test_find_by_id_success(self):
        user_account = UserAccountFactory()
        es = UserAccount.find_by_id(user_account.id)
        self.assertEqual(user_account, es)

    @parameterized.expand([
        (admin_user(), True),
        (admin_user(), False),
        (basic_user(), True),
    ])
    def test_find_by_ids_for_user_success(self, user, use_same_user):
        user_account = UserAccountFactory()

        if use_same_user:
            user['usr']['id'] = str(user_account.id)
        else:
            another_account = UserAccountFactory()
            user['usr']['id'] = str(another_account.id)

        res = UserAccount.find_by_ids_for_user([user_account.id], user)
        self.assertEqual([user_account], res)

    def test_find_by_ids_for_user_failure(self):
        # basic_user with different user_account.id won't be able to find this
        user_account = UserAccountFactory()

        user = basic_user()
        another_account = UserAccountFactory()
        user['usr']['id'] = str(another_account.id)

        with self.assertRaises(ResourceNotFoundError):
            UserAccount.find_by_ids_for_user([user_account.id], user)


if __name__ == '__main__':
    unittest.main()
