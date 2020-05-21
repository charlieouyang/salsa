from unittest import mock
from parameterized import parameterized
from werkzeug.exceptions import Forbidden

from salsa.permission import is_user_admin, only_admin
from tests import SalsaTestCase
from tests import admin_user, basic_user


class TestPermission(SalsaTestCase):
    def test_get_user(self):
        pass

    @parameterized.expand([
        (admin_user, True),
        (basic_user, False)])
    def test_is_user_admin(self, user, expected):
        self.assertEqual(is_user_admin(user()), expected)


    @parameterized.expand([
        (admin_user, True),
        (basic_user, False)])
    def test_only_admin(self, user, will_succeed):
        _get_user = mock.patch(
            'salsa.permission.get_user').start()
        _get_user.return_value = user()

        def a(o, *args, **kwargs):
            return True

        f = only_admin(a)

        if not will_succeed:
            with self.assertRaises(Forbidden):
                f(None)
        else:
            f(None)
