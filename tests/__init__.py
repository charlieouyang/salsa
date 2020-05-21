from unittest import mock
from flask_testing import TestCase

from salsa.app import app
from salsa.db import db
from salsa import permission


def admin_user(user_id=''):
    return {
        'prm': {
            'title': permission.ADMIN_PERM_TITLE
        },
        'usr': {
            'id': user_id
        }
    }


def basic_user(user_id=''):
    return {
        'prm': {
            'title': permission.USER_PERM_TITLE
        },
        'usr': {
            'id': user_id
        }
    }


class SalsaTestCase(TestCase):
    @classmethod
    def setUpClass(cls):
        """On inherited classes, run our `setUp` method"""
        if cls is not SalsaTestCase\
                and cls.setUp is not SalsaTestCase.setUp:
            orig_setUp = cls.setUp

            def setUpOverride(self, *args, **kwargs):
                SalsaTestCase.setUp(self)
                return orig_setUp(self, *args, **kwargs)

            cls.setUp = setUpOverride

    def create_app(self):
        return app

    def setUp(self):
        db.create_all()
        self.client = self.app.test_client()

    def tearDown(self):
        db.session.close()
        db.drop_all()

    def _get_user_mock(self, user):
        return mock.patch('aboutface.permission.get_user', return_value=user)

    def assertNotRaises(self, err, func, *args, **kwargs):
        try:
            func(*args, **kwargs)
        except Exception as ex:
            if isinstance(ex, err):
                raise AssertionError(
                    f'Exception raised when not expected: {err}')
