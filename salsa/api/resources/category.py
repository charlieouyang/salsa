import json
from werkzeug.exceptions import BadRequest, InternalServerError
from sqlalchemy import exc

from .base import BaseResource
from salsa.models import Category
from salsa.api.resources.helpers import (serialize_return,
                                         get_hashed_password,
                                         sqlalchemy_exception_handler)
from salsa.permission import only_admin
from salsa.utils.decorators import decorate_all_methods


@decorate_all_methods(sqlalchemy_exception_handler)
class CategoryResource(BaseResource):
    model = Category

    @serialize_return(status=200)
    def retrieve(self, category_id, **kwargs):
        return self.model.find_by_id(category_id)

    @serialize_return(status=200)
    def retrieve_list(self, **kwargs):
        instances = super().retrieve_list(**kwargs)
        return instances

    @only_admin
    @serialize_return(status=201)
    def create(self, **kwargs):
        category = kwargs.get('body')
        return super().create(category)

    @only_admin
    @serialize_return(status=200)
    def update(self, category_id, **kwargs):
        category = kwargs.get('body')
        return super().update(category_id, category)


categories = CategoryResource()
