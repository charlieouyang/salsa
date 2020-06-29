import json
from sqlalchemy import exc, or_

from .base import BaseResource
from salsa.models import Listing, Purchase
from salsa.api.resources.helpers import (serialize_return,
                                         sqlalchemy_exception_handler)
from salsa.permission import only_admin, get_user, get_user_id_from_user, is_user_admin
from salsa.utils.decorators import decorate_all_methods
from salsa.exc import InvalidRequest


BAD_AS_ERROR = ('Invalid "user_as" parameter is passed in. '
                'Please use [buyer] or [seller]')
UPDATE_SELLER_COMP_ERROR = ('Invalid inputs to update seller_complete')

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

            if 'user_as' not in kwargs:
                raise InvalidRequest(BAD_AS_ERROR)
            user_as = kwargs.pop('user_as')
            user_id = get_user_id_from_user(get_user(kwargs))

            if user_as == 'buyer':
                # Get all of the purchases made by user_id
                instances = instances.filter(
                    self.model.user_id == user_id)
            elif user_as == 'seller':
                # Get all of the purchases made to this user_id's listings
                instances = instances.join(Listing).filter(
                    Listing.user_id == user_id)
            else:
                raise InvalidRequest(BAD_AS_ERROR)

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

        if not is_user_admin(get_user(kwargs)):
            # update buyer_complete -> Only updatable by buyer
            #        by checking the user_id of purchase...
            if updated.get('buyer_complete') is not None:
                Purchase.belongs_to_user(purchase_id, get_user(kwargs))

            # update seller_complete -> Only updatable by seller
            #        by checking the user_id of the listing
            if updated.get('seller_complete') is not None:
                purchases = self.model.query.filter(self.model.id == purchase_id).\
                                             join(Listing).all()
                if (len(purchases) != 1 or
                    str(purchases[0].listing.user_id) != get_user_id_from_user(get_user(kwargs))):
                    raise InvalidRequest(UPDATE_SELLER_COMP_ERROR)


        return super().update(purchase_id, updated)


purchases = PurchaseResource()
