import toolz as T
from datetime import datetime
from sqlalchemy import types

from salsa.db import db
from salsa.db.types import GUID
from salsa.models import BaseModel, Listing, Product
from salsa.exc import ResourceNotFoundError
from salsa.permission import is_user_admin, get_user_id_from_user


class Purchase(BaseModel):
    # user is a reserved keyword in postgres
    __tablename__ = 'purchase'

    id = db.Column(GUID, primary_key=True, default=GUID.default_value)

    # 10 integer places + 2 decimals.. Max value is 99,999,999.99
    amount = db.Column(db.Numeric(10,2), unique=False, nullable=False)
    notes = db.Column(db.Text(), unique=False, nullable=True)
    created_at = db.Column(
        db.DateTime, default=datetime.utcnow, nullable=False)
    updated_at = db.Column(
        db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    buyer_complete = db.Column(db.Boolean, nullable=False, default=False)
    seller_complete = db.Column(db.Boolean, nullable=False, default=False)

    user_id = db.Column(GUID,
                        db.ForeignKey('user_account.id'),
                        nullable=False)
    user_account = db.relationship('UserAccount',
                                   foreign_keys=user_id,
                                   back_populates='purchases')

    listing_id = db.Column(GUID,
                           db.ForeignKey('listing.id'),
                           nullable=False)
    listing = db.relationship('Listing',
                              foreign_keys=listing_id,
                              back_populates='purchases')

    reviews = db.relationship(
        'Review',
        cascade="delete",
        back_populates="purchase",
        lazy='dynamic')

    def update(self, **kwargs):
        allowed_attrs = ['amount', 'notes', 'buyer_complete', 'seller_complete']
        for k, v in kwargs.items():
            if k in allowed_attrs and v is not None:
                setattr(self, k, v)

    @classmethod
    def check_purchase_made_on_product(self, purchase_id, product_id):
        products = Product.query.join(Listing).join(self)                \
                                .filter(self.id==purchase_id)            \
                                .filter(self.listing_id==Listing.id)     \
                                .filter(Listing.product_id==Product.id)  \
                                .filter(Product.id==product_id).all()

        if len(products) == 0:
            raise ResourceNotFoundError(
                f'Product associated with purchase_id {purchase_id} was not found',
                Product.humanized_tablename())

    # ADMIN PERMISSIONS DO NOT OVERRIDE THIS
    @classmethod
    def belongs_to_user(self, purchase_id, user):
        user_id = get_user_id_from_user(user)
        purchases = self.query.filter(self.id==purchase_id).          \
                               filter(self.user_id==user_id).all()

        if len(purchases) == 0:
            raise ResourceNotFoundError(self.not_found_msg(purchase_id),
                                        self.humanized_tablename())

    # Who can view/edit a purchase:
    #     1. User that created the purchase
    #     2. User that created the listing
    @classmethod
    def can_update_ids_by_user(self, purchase_ids, user):
        query_ids = list(set(purchase_ids))
        purchases = self.query.filter(self.id.in_(query_ids)).join(Listing).all()

        if len(purchases) != len(purchase_ids):
            raise ResourceNotFoundError(self.not_found_msg(purchase_ids),
                                        self.humanized_tablename())

        return list(map(lambda purchase: self.check_resource(
            purchase, user), purchases))

    @classmethod
    def check_resource(self, purchase, user):
        if not is_user_admin(user) and str(purchase.listing.user_id) != get_user_id_from_user(user) and str(purchase.user_id) != get_user_id_from_user(user):
            raise ResourceNotFoundError(self.not_found_msg(purchase.id),
                                        self.humanized_tablename())

        return purchase
