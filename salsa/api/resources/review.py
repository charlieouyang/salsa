import json
from werkzeug.exceptions import BadRequest, InternalServerError
from sqlalchemy import exc

from .base import BaseResource
from salsa.models import Review, Product, Purchase, Listing
from salsa.exc import ResourceNotFoundError
from salsa.api.resources.helpers import (serialize_return,
                                         sqlalchemy_exception_handler)
from salsa.permission import only_admin, get_user, get_user_id_from_user
from salsa.utils.decorators import decorate_all_methods


@decorate_all_methods(sqlalchemy_exception_handler)
class ReviewResource(BaseResource):
    model = Review

    @serialize_return(status=200)
    def retrieve(self, review_id, **kwargs):
        return self.model.find_by_id(review_id)

    @serialize_return(status=200)
    def retrieve_list(self, **kwargs):
        return super().retrieve_list(**kwargs)

    @serialize_return(status=201)
    def create(self, **kwargs):
        new_review = kwargs.get('body')

        purchase_id = new_review.get('purchase_id')
        product_id = new_review.get('product_id')

        # Validate the purchase_id to make sure purchase it is
        # made by this user
        Purchase.belongs_to_user(purchase_id, get_user(kwargs))

        # Validate the product_id by making sure this purchase
        # was made on the listing that had this product
        Purchase.check_purchase_made_on_product(purchase_id, product_id)

        new_review['user_id'] = get_user_id_from_user(get_user(kwargs))
        return super().create(new_review)

    @serialize_return(status=200)
    def update(self, review_id, **kwargs):
        Review.can_update_ids_by_user([review_id], get_user(kwargs))
        updated = kwargs.get('body')
        return super().update(review_id, updated)


reviews = ReviewResource()
