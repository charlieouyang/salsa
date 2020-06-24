import json
from werkzeug.exceptions import BadRequest, InternalServerError
from sqlalchemy import exc, or_

from .base import BaseResource
from salsa.models import Listing, Purchase
from salsa.api.resources.helpers import (serialize_return,
                                         sqlalchemy_exception_handler)
from salsa.permission import only_admin, get_user, get_user_id_from_user, is_user_admin
from salsa.utils.decorators import decorate_all_methods


@decorate_all_methods(sqlalchemy_exception_handler)
class PurchaseResource(BaseResource):
    model = Purchase

    @serialize_return(status=200)
    def retrieve(self, purchase_id, **kwargs):
        # Who can view a purchase:
        #     1. User that created the purchase
        #     2. User that created the listing
        Purchase.can_update_ids_by_user([purchase_id], get_user(kwargs))
        return self.model.find_by_id(purchase_id)

    @serialize_return(status=200)
    def retrieve_list(self, **kwargs):
        instances = super().retrieve_list(**kwargs)

        if not is_user_admin(get_user(kwargs)):
            # Get all of the purchases made by user_id, and
            # all of the purchases that are made to this user_id's listings
            user_id = get_user_id_from_user(get_user(kwargs))
            instances = instances.join(Listing).filter(or_(
                self.model.user_id == user_id,
                Listing.user_id == user_id))

        return instances

    @serialize_return(status=201)
    def create(self, **kwargs):
        new_purchase = kwargs.get('body')
        new_purchase['user_id'] = get_user_id_from_user(get_user(kwargs))
        return super().create(new_purchase)

    @serialize_return(status=200)
    def update(self, purchase_id, **kwargs):
        Purchase.can_update_ids_by_user([purchase_id], get_user(kwargs))
        updated = kwargs.get('body')
        return super().update(purchase_id, updated)


purchases = PurchaseResource()
