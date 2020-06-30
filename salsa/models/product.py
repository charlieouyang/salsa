import toolz as T
from datetime import datetime
from sqlalchemy import types
from sqlalchemy.ext.hybrid import hybrid_property
from statistics import mean

from salsa.db import db
from salsa.db.types import GUID
from salsa.models import BaseModel
from salsa.exc import ResourceNotFoundError
from salsa.permission import is_user_admin, get_user_id_from_user


class Product(BaseModel):
    # user is a reserved keyword in postgres
    __tablename__ = 'product'

    id = db.Column(GUID, primary_key=True, default=GUID.default_value)
    active = db.Column(db.Boolean, default=False)
    name = db.Column(db.String(255), unique=False, nullable=False)
    description = db.Column(db.Text(), unique=False, nullable=False)
    image_urls = db.Column(types.ARRAY(db.String(255)), unique=False, nullable=False)

    created_at = db.Column(
        db.DateTime, default=datetime.utcnow, nullable=False)
    updated_at = db.Column(
        db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    user_id = db.Column(GUID,
                        db.ForeignKey('user_account.id'),
                        nullable=False)
    user_account = db.relationship('UserAccount',
                                   foreign_keys=user_id,
                                   back_populates='products')

    listings = db.relationship(
        'Listing',
        cascade="delete",
        back_populates="product",
        lazy='dynamic')
    reviews = db.relationship(
        'Review',
        cascade="delete",
        back_populates="product",
        lazy='dynamic')
    product_categories = db.relationship(
        'ProductCategory',
        back_populates="product")

    @hybrid_property
    def avg_numstars(self):
        total_stars = 0
        count_stars = 0
        for review_ in self.reviews:
            total_stars += review_.numstars
            count_stars += 1

        if count_stars > 0:
            return total_stars / count_stars
        else:
            return -1

    def update(self, **kwargs):
        allowed_attrs = ['active', 'name', 'description', 'image_urls']
        for k, v in kwargs.items():
            if k in allowed_attrs and v is not None:
                setattr(self, k, v)

    @classmethod
    def can_update_ids_by_user(self, product_ids, user):
        query_ids = list(set(product_ids))
        products = self.query.filter(self.id.in_(query_ids)).all()

        if len(products) != len(product_ids):
            raise ResourceNotFoundError(self.not_found_msg(product_ids),
                                        self.humanized_tablename())

        return list(map(lambda product: self.check_resource(
            product, user), products))

    @classmethod
    def check_resource(self, product, user):
        if not is_user_admin(user) and str(product.user_id) != get_user_id_from_user(user):
            raise ResourceNotFoundError(self.not_found_msg(product.id),
                                        self.humanized_tablename())

        return product
