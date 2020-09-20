import unittest
from parameterized import parameterized

from sqlalchemy.exc import IntegrityError

from salsa import permission
from salsa.db import db
from salsa.models import UserRole
from salsa.exc import ForbiddenAction
from tests import SalsaTestCase
from tests import admin_user, basic_user
from tests.factories import UserRoleFactory


class UserRoleTest(SalsaTestCase):
    def test_valid_user_role(self):
        user_role = UserRoleFactory(title='test_title')

        self.assertEqual([user_role], db.session.query(UserRole).all())
        self.assertEqual(user_role.title, 'test_title')

    def test_duplicate_error(self):
        UserRoleFactory(title='test_title')

        with self.assertRaises(IntegrityError):
            UserRoleFactory(title='test_title')

    def test_find_by_id_success(self):
        user_role = UserRoleFactory()
        es = UserRole.find_by_id(user_role.id)
        self.assertEqual(user_role, es)

    # Read it like... Admin_user trying to create a user_account
    # with a user_role of admin_title, etc.
    @parameterized.expand([
        (admin_user(), permission.ADMIN_PERM_TITLE),
        (admin_user(), permission.USER_PERM_TITLE),
        (basic_user(), permission.USER_PERM_TITLE),
    ])
    def test_can_create_user_account_with_role_ids_success(self, user, permission_title):
        # There exists a user_role with permission_title, and the user is going
        # to try and create a user_account with that title
        user_role = UserRoleFactory(title=permission_title)
        res = UserRole.can_create_user_account_with_role_ids([user_role.id], user)
        self.assertEqual([user_role], res)

    def test_can_create_user_account_with_role_ids_failure(self):
        # There exists an admin user_role, and the non admin user is going
        # to try and create a user_account with an admin role...
        user_role = UserRoleFactory(title=permission.ADMIN_PERM_TITLE)
        user = basic_user()

        with self.assertRaises(ForbiddenAction):
            UserRole.can_create_user_account_with_role_ids([user_role.id], user)


if __name__ == '__main__':
    unittest.main()
