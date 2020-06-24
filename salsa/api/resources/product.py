import json
from werkzeug.exceptions import BadRequest, InternalServerError
from sqlalchemy import exc

from .base import BaseResource
from salsa.models import Product
from salsa.api.resources.helpers import (serialize_return,
                                         sqlalchemy_exception_handler)
from salsa.permission import only_admin, get_user, get_user_id_from_user
from salsa.utils.decorators import decorate_all_methods


@decorate_all_methods(sqlalchemy_exception_handler)
class ProductResource(BaseResource):
    model = Product

    @serialize_return(status=200)
    def retrieve(self, product_id, **kwargs):
        return self.model.find_by_id(product_id)

    @serialize_return(status=200)
    def retrieve_list(self, **kwargs):
        return super().retrieve_list(**kwargs)

    @serialize_return(status=201)
    def create(self, **kwargs):
        new_product = kwargs.get('body')
        new_product['user_id'] = get_user_id_from_user(get_user(kwargs))
        return super().create(new_product)

    @serialize_return(status=200)
    def update(self, product_id, **kwargs):
        Product.can_update_ids_by_user([product_id], get_user(kwargs))
        updated = kwargs.get('body')
        return super().update(product_id, updated)


products = ProductResource()
