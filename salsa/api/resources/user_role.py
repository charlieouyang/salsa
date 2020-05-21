import json
from werkzeug.exceptions import BadRequest, InternalServerError
from sqlalchemy import exc

from .base import BaseResource
from salsa.models import UserAccount, UserRole
from salsa.api.resources.helpers import (serialize_return,
                                         get_hashed_password,
                                         sqlalchemy_exception_handler)
from salsa.permission import only_admin, get_user
from salsa.utils.decorators import decorate_all_methods


@decorate_all_methods(sqlalchemy_exception_handler)
class UserRoleResource(BaseResource):
    model = UserRole

    @serialize_return(status=200)
    def retrieve(self, user_role_id, **kwargs):
        return self.model.find_by_id(user_role_id)

    @serialize_return(status=200)
    def retrieve_list(self, **kwargs):
        instances = super().retrieve_list(**kwargs)
        return instances

    @only_admin
    @serialize_return(status=201)
    def create(self, **kwargs):
        user_role = kwargs.get('body')
        return super().create(user_role)

    @only_admin
    @serialize_return(status=200)
    def update(self, user_role_id, **kwargs):
        user_role = kwargs.get('body')
        return super().update(user_role_id, user_role)

    @only_admin
    @serialize_return(status=204)
    def delete(self, user_role_id, **kwargs):
        return super().delete(user_role_id)


user_roles = UserRoleResource()
