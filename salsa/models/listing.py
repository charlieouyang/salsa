import toolz as T
from datetime import datetime
from sqlalchemy import types

from salsa.db import db
from salsa.db.types import GUID
from salsa.models import BaseModel
from salsa.exc import ResourceNotFoundError
from salsa.permission import is_user_admin, get_user_id_from_user


class Listing(BaseModel):
    # user is a reserved keyword in postgres
    __tablename__ = 'listing'

    id = db.Column(GUID, primary_key=True, default=GUID.default_value)
    active = db.Column(db.Boolean, default=False)
    name = db.Column(db.String(255), unique=False, nullable=False)
    description = db.Column(db.Text(), unique=False, nullable=False)
    # 10 integer places + 2 decimals.. Max value is 99,999,999.99
    price = db.Column(db.Numeric(10,2), unique=False, nullable=False)
    # 10 integer places + 2 decimals.. Max value is 99,999,999.99
    amount_available = db.Column(db.Numeric(10,2), unique=False, nullable=False)

    created_at = db.Column(
        db.DateTime, default=datetime.utcnow, nullable=False)
    updated_at = db.Column(
        db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    user_id = db.Column(GUID,
                        db.ForeignKey('user_account.id'),
                        nullable=False)
    user_account = db.relationship('UserAccount',
                                   foreign_keys=user_id,
                                   back_populates='listings')

    product_id = db.Column(GUID,
                           db.ForeignKey('product.id'),
                           nullable=False)
    product = db.relationship('Product',
                              foreign_keys=product_id,
                              back_populates='listings')

    purchases = db.relationship(
        'Purchase',
        cascade="delete",
        back_populates="listing",
        lazy='dynamic')

    def update(self, **kwargs):
        allowed_attrs = ['active', 'name', 'description', 'price', 'amount_available']
        for k, v in kwargs.items():
            if k in allowed_attrs and v is not None:
                setattr(self, k, v)

    @classmethod
    def can_update_ids_by_user(self, listing_ids, user):
        query_ids = list(set(listing_ids))
        listings = self.query.filter(self.id.in_(query_ids)).all()

        if len(listings) != len(listing_ids):
            raise ResourceNotFoundError(self.not_found_msg(listing_ids),
                                        self.humanized_tablename())

        return list(map(lambda listing: self.check_resource(
            listing, user), listings))

    @classmethod
    def check_resource(self, listing, user):
        if not is_user_admin(user) and str(listing.user_id) != get_user_id_from_user(user):
            raise ResourceNotFoundError(self.not_found_msg(listing.id),
                                        self.humanized_tablename())

        return listing
