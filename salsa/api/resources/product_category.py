import json
from werkzeug.exceptions import BadRequest, InternalServerError
from sqlalchemy import exc
from sqlalchemy.dialects.postgresql import insert

from .base import BaseResource
from salsa.db import db
from salsa.models import ProductCategory, Product, Category
from salsa.api.resources.helpers import (serialize_return,
                                         get_hashed_password,
                                         sqlalchemy_exception_handler)
from salsa.permission import only_admin, get_user
from salsa.utils.decorators import decorate_all_methods


@decorate_all_methods(sqlalchemy_exception_handler)
class ProductCategoryResource(BaseResource):
    model = ProductCategory

    @serialize_return(status=200)
    def retrieve(self, product_id, **kwargs):
        # This should be used for getting categories of a product
        # on a view product page

        # Validate the product_id
        Product.find_by_id(product_id)

        return self.model.query.\
                          join(Product, Product.id == self.model.product_id).\
                          join(Category, Category.id == self.model.category_id).\
                          filter(Product.id == product_id)

    @serialize_return(status=201)
    def create(self, **kwargs):
        """
        1. As a user, I want to assign/unassign category(s) to my product
        {
            "product_id": <product_id_0>,
            "category_ids": [<category_id_0>, <category_id_1>]
        }
        """
        product_categories = kwargs.get('body')

        # validate user has access to product && product exists
        product_id = product_categories.get('product_id')
        Product.can_update_ids_by_user([product_id], get_user(kwargs))

        # validate all of the category_ids
        category_ids = product_categories.get('category_ids')
        Category.find_by_ids(category_ids)

        try:
            # find list of categories that's already assigned but not in input category_ids
            # DELETE THAT LIST
            existing = self.model.query.filter(self.model.product_id == product_id).\
                                        filter(self.model.category_id.notin_(category_ids))
            existing.delete(synchronize_session=False)

            # INSERT INTO product_category.. ON CONFLICT do nothing
            product_category_instances = [{'product_id': product_id,
                                           'category_id': cat_id}
                                           for cat_id in category_ids]
            insert_stmt = insert(self.model.__table__).values(
                product_category_instances).on_conflict_do_nothing(
                index_elements=['product_id', 'category_id'])
            db.session.execute(insert_stmt)

            db.session.commit()
        except Exception as e:
            db.session.rollback()
            raise
        
        return []


product_categories = ProductCategoryResource()
