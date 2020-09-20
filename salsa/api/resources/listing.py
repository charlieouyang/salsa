import json
from werkzeug.exceptions import BadRequest, InternalServerError
from sqlalchemy import exc, func, or_

from .base import BaseResource
from salsa.models import Listing, Product, ProductCategory, Category
from salsa.api.resources.helpers import (serialize_return,
                                         sqlalchemy_exception_handler,
                                         is_valid_uuid4)
from salsa.permission import only_admin, get_user, get_user_id_from_user
from salsa.utils.decorators import decorate_all_methods

CATEGORY_MISFORMAT_ERROR = 'category_ids must be in uuid format'


@decorate_all_methods(sqlalchemy_exception_handler)
class ListingResource(BaseResource):
    model = Listing

    @serialize_return(status=200)
    def retrieve(self, listing_id, **kwargs):
        return self.model.find_by_id(listing_id)

    @serialize_return(status=200)
    def retrieve_list(self, **kwargs):
        name_param = None
        if 'name' in kwargs:
            name_param = kwargs.pop('name')

        categories_param = None
        if 'category_ids' in kwargs:
            categories_param = kwargs.pop('category_ids')
            for cat_id in categories_param:
                if not is_valid_uuid4(cat_id):
                    raise BadRequest(description=CATEGORY_MISFORMAT_ERROR)
            Category.find_by_ids(categories_param)

        instances = super().retrieve_list(**kwargs)
        instances = instances.join(Product, self.model.product_id == Product.id)

        if name_param:
            # Search for listings with name or description like or
            # their linked product name or description like
            name = name_param.lower()
            name_search = '%{}%'.format(name)
            instances = instances.filter(or_(
                func.lower(self.model.name).like(name_search),
                func.lower(self.model.description).like(name_search),
                func.lower(Product.name).like(name_search),
                func.lower(Product.description).like(name_search)))

        if categories_param:
            # Search for listings with product assigned to these categories
            instances = instances.\
                join(ProductCategory, Product.id == ProductCategory.product_id).\
                join(Category, ProductCategory.category_id == Category.id).\
                filter(Category.id.in_(categories_param))

        return instances

    @serialize_return(status=201)
    def create(self, **kwargs):
        new_listing = kwargs.get('body')

        # Validate the product_id
        product_id = new_listing.get('product_id')
        Product.can_update_ids_by_user([product_id], get_user(kwargs))

        new_listing['user_id'] = get_user_id_from_user(get_user(kwargs))
        return super().create(new_listing)

    @serialize_return(status=200)
    def update(self, listing_id, **kwargs):
        Listing.can_update_ids_by_user([listing_id], get_user(kwargs))
        updated = kwargs.get('body')
        return super().update(listing_id, updated)


listings = ListingResource()
