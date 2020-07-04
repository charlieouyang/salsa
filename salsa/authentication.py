# Authentication
import time
import os
import random

import connexion
import six
import toolz as T
from werkzeug.exceptions import Unauthorized, NotFound, BadRequest

from jose import JWTError, jwt
from flask import Flask, jsonify, request

from salsa import email
from salsa.models import UserAccount, UserRole
from salsa.db import db

from salsa.api.resources.helpers import (serialize_instance,
                                         check_password,
                                         get_hashed_password)

JWT_ISSUER = 'com.salsa.connexion'
JWT_SECRET = os.getenv('SALSA_AUTH_SALT', 'did_not_work')
JWT_LIFETIME_SECONDS = 60*60*24 #24 hours
JWT_ALGORITHM = 'HS256'

INCORRECT_LOGIN_INFO_MSG = 'Username or password incorrect'
USER_ROLE_ERROR_INFO_MSG = 'User doesn\'t have a role assigned'
INCORRECT_RESET_PARAMS_MSG = 'Invalid email'


def _current_timestamp() -> int:
    return int(time.time())

def login():
    json_data = request.get_json()
    username = json_data.get('username') or None
    password = json_data.get('password') or None

    if username is None or password is None:
        raise BadRequest(description=INCORRECT_LOGIN_INFO_MSG)

    res = db.session.query(UserAccount, UserRole).join(UserRole).filter(
                UserAccount.user_name==username).first()

    if res is None:
        raise BadRequest(description=INCORRECT_LOGIN_INFO_MSG)

    user, role = res

    try:
        return_value = check_password(password, user.password_hashed)
    except ValueError:
        raise BadRequest(description=INCORRECT_LOGIN_INFO_MSG)

    if role is None:
        raise BadRequest(description=USER_ROLE_ERROR_INFO_MSG)

    timestamp = _current_timestamp()
    payload = {
        'iss': JWT_ISSUER,
        'iat': int(timestamp),
        'exp': int(timestamp + JWT_LIFETIME_SECONDS),
        'usr': serialize_instance(user),
        'prm': serialize_instance(role)
    }

    token = jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)
    return {'status_code': 200, 'token': token, 'user_account_id': str(user.id)}

def reset_password():
    """
    1. Validate the email address
    2. Generate simple password
    3. Replace UserAccount.password with new change
    4. Send e-mail to user's address with new password
    """
    json_data = request.get_json()
    user_email = json_data.get('email') or None

    if user_email is None:
        raise BadRequest(description=INCORRECT_RESET_PARAMS_MSG)

    user_account = db.session.query(UserAccount).filter(
        UserAccount.email == user_email).first()
    if user_account is None:
        raise BadRequest(description=INCORRECT_RESET_PARAMS_MSG)

    # Generate password hash
    temp_password = str(random.randint(10000,99999))
    update_user = {'password_hashed': get_hashed_password(temp_password)}
    user_account.update(**update_user)
    user_account.save()

    email.send('reset_password', user_email, temp_password)

    return {'status_code': 200, 'message': 'Password reset success!'}

def verify_token(token):
    try:
        decoded = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])

        user_name = T.get_in(['usr', 'user_name'], decoded)
        if not user_name:
            raise JWTError('Invalid JWT header', 'user_name missing')

        instance = db.session.query(UserAccount).filter_by(user_name=user_name).first()
        if not instance:
            raise JWTError('Invalid JWT header', 'user missing')

        return decoded

    except JWTError as e:
        six.raise_from(Unauthorized, e)

