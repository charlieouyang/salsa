import json
from werkzeug.exceptions import BadRequest, InternalServerError
from sqlalchemy import exc

from .base import BaseResource
from salsa.models import UserAccount, UserRole
from salsa.api.resources.helpers import (serialize_return,
                                         get_hashed_password,
                                         sqlalchemy_exception_handler,
                                         is_valid_json)
from salsa.permission import only_admin, get_user
from salsa.utils.decorators import decorate_all_methods


INVALID_PASSWORD_MSG = 'Invalid password'
INVALID_EXTRADATA_MSG = 'Invalid extradata. Extradata must be a json string'


@decorate_all_methods(sqlalchemy_exception_handler)
class UserAccountResource(BaseResource):
    model = UserAccount

    @serialize_return(status=200)
    def retrieve(self, user_account_id, **kwargs):
        res = self.model.find_by_ids_for_user([user_account_id], get_user(kwargs))
        if len(res) > 0:
            return res[0]
        else:
            return {}

    @only_admin
    @serialize_return(status=200)
    def retrieve_list(self, **kwargs):
        instances = super().retrieve_list(**kwargs)
        return instances

    # Only used by admins to create accounts
    @only_admin
    @serialize_return(status=201)
    def create(self, **kwargs):
        new_account = self._try_to_get_new_user_account(
            kwargs.get('body'),
            user=get_user(kwargs))

        return super().create(new_account)

    # Create user_account without authentication... New normal user
    @serialize_return(status=201)
    def create_no_auth(self, **kwargs):
        new_account = self._try_to_get_new_user_account(
            kwargs.get('body'),
            user=get_user(kwargs))

        if isinstance(new_account, dict) and 'password_hashed' in new_account:
            return super().create(new_account)
        else:
            # This is just the 403 response
            return new_account

    def _try_to_get_new_user_account(self, user_account, user=None):
        password = user_account.pop("password") or False
        if not password:
            raise BadRequest(description=INVALID_PASSWORD_MSG)

        UserRole.can_create_user_account_with_role_ids(
            [user_account.get('user_role_id')], user)

        # Generate password hash
        password_hashed = get_hashed_password(password)
        user_account['password_hashed'] = password_hashed

        extradata = user_account.get("extradata")
        if extradata:
            self._check_extradata(extradata)

        return user_account

    @serialize_return(status=200)
    def update(self, user_account_id, **kwargs):
        user_account = kwargs.get('body')

        if 'password' in user_account:
            password = user_account.pop("password") or False
            if password:
                # Generate password hash
                password_hashed = get_hashed_password(password)
                user_account['password_hashed'] = password_hashed
            else:
                raise BadRequest(description='Can\'t set an empty password')

        extradata = user_account.get("extradata")
        if extradata:
            self._check_extradata(extradata)

        self.model.find_by_ids_for_user([user_account_id], get_user(kwargs))
        return super().update(user_account_id, user_account)

    def _check_extradata(self, extradata):
        try:
            is_valid_json(extradata)
        except ValueError as exc:
            raise BadRequest(description=INVALID_EXTRADATA_MSG)


user_accounts = UserAccountResource()
