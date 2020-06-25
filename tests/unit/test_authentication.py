# Authentication
import time

from unittest import mock
from parameterized import parameterized
from werkzeug.exceptions import Forbidden, BadRequest, Unauthorized
from jose import JWTError, jwt

from salsa.authentication import (login,
                                  verify_token,
                                  _current_timestamp,
                                  JWT_ISSUER,
                                  JWT_SECRET,
                                  JWT_ALGORITHM,
                                  JWT_LIFETIME_SECONDS)
from tests import SalsaTestCase
from tests import admin_user, basic_user

from tests.factories import UserAccountFactory, UserRoleFactory
from salsa.api.resources.helpers import get_hashed_password



timestamp = _current_timestamp()


class TestAuthentication(SalsaTestCase):

    @parameterized.expand([
        ('user_0', 'pass_0', True),
        ('USER_0', 'pass_0', False),
        ('user_0', 'PASS_0', False),
        ('user_0', 'incorrect', False),
        ('', 'pass_0', False),
        ('user_0', '', False),
        ('', '', False),])
    def test_login(self, user_name, password, is_successful):
        user = UserAccountFactory(user_name='user_0',
                                  password_hashed=get_hashed_password('pass_0'))

        login_payload = {
            'username': user_name,
            'password': password,
        }
        with mock.patch('flask.request.get_json', return_value=login_payload):
            if is_successful:
                res = login()
                self.assertEqual(res.get('status_code'), 200)
                self.assertTrue(res.get('token'))
                self.assertTrue(res.get('user_account_id'))
            else:
                with self.assertRaises(BadRequest):
                    login()


    @parameterized.expand([
        (JWT_ISSUER, int(timestamp), int(timestamp + JWT_LIFETIME_SECONDS), { 'user_name': 'test_user' }, {}),
        (None, int(timestamp), int(timestamp + JWT_LIFETIME_SECONDS), { 'user_name': 'test_user' }, {}),
        (JWT_ISSUER, int(timestamp), int(timestamp + JWT_LIFETIME_SECONDS), { 'user_name': 'test_user' }, None),])
    def test_verify_token_success(self, iss, iat, exp, usr, prm):
        user = UserAccountFactory(user_name='test_user',
                                  password_hashed=get_hashed_password('test_user_pass'))
        test_payload = {
            'iss': iss,
            'iat': iat,
            'exp': exp,
            'usr': usr,
            'prm': prm,
        }
        token = jwt.encode(test_payload, JWT_SECRET, algorithm=JWT_ALGORITHM)
        res = verify_token(token)
        self.assertTrue(res)


    @parameterized.expand([
        (JWT_ISSUER, int(timestamp), int(timestamp + JWT_LIFETIME_SECONDS), { 'user_name': 'test_user' }, {}),
        (JWT_ISSUER, int(timestamp), int(timestamp - 1), { 'user_name': 'test_user' },  {}),
        (JWT_ISSUER, int(timestamp), int(timestamp + JWT_LIFETIME_SECONDS), {},  {}),
        (JWT_ISSUER, int(timestamp), int(timestamp + JWT_LIFETIME_SECONDS), None,  {}),])
    def test_verify_token_fail(self, iss, iat, exp, usr, prm):
        test_payload = {
            'iss': iss,
            'iat': iat,
            'exp': exp,
            'usr': usr,
            'prm': prm,
        }
        token = jwt.encode(test_payload, JWT_SECRET, algorithm=JWT_ALGORITHM)
        with self.assertRaises(Unauthorized):
            res = verify_token(token)

    def test_malformed_token_fail(self):
        token_value = ''
        with self.assertRaises(Unauthorized):
            res = verify_token(token_value)

        token_value = 'abc'
        with self.assertRaises(Unauthorized):
            res = verify_token(token_value)

        # Modify the token value
        user = UserAccountFactory(user_name='test_user',
                                  password_hashed=get_hashed_password('test_user_pass'))
        test_payload = {
            'iss': JWT_ISSUER,
            'iat': int(timestamp),
            'exp': int(timestamp + JWT_LIFETIME_SECONDS),
            'usr': { 'user_name': 'test_user' },
            'prm': {},
        }
        token_value = jwt.encode(test_payload, JWT_SECRET, algorithm=JWT_ALGORITHM)
        parts = token_value.split('.')
        parts[0] = 'thisreplacedit'
        token_value = '.'.join(parts)
        with self.assertRaises(Unauthorized):
            res = verify_token(token_value)
