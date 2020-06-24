import toolz as T
from datetime import datetime
from sqlalchemy import types

from salsa.db import db
from salsa.db.types import GUID
from salsa.models import BaseModel
from salsa.exc import ResourceNotFoundError
from salsa.permission import is_user_admin, get_user_id_from_user


class Review(BaseModel):
    # user is a reserved keyword in postgres
    __tablename__ = 'review'

    id = db.Column(GUID, primary_key=True, default=GUID.default_value)
    name = db.Column(db.String(255), unique=False, nullable=False)
    description = db.Column(db.Text(), unique=False, nullable=False)
    numstars = db.Column(db.Integer(), unique=False, nullable=False)

    created_at = db.Column(
        db.DateTime, default=datetime.utcnow, nullable=False)
    updated_at = db.Column(
        db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    user_id = db.Column(GUID,
                        db.ForeignKey('user_account.id'),
                        nullable=False)
    user_account = db.relationship('UserAccount',
                                   foreign_keys=user_id,
                                   back_populates='reviews')

    product_id = db.Column(GUID,
                           db.ForeignKey('product.id'),
                           nullable=False)
    product = db.relationship('Product',
                              foreign_keys=product_id,
                              back_populates='reviews')

    purchase_id = db.Column(GUID,
                           db.ForeignKey('purchase.id'),
                           nullable=False)
    purchase = db.relationship('Purchase',
                              foreign_keys=purchase_id,
                              back_populates='reviews')

    __table_args__ = (
        db.UniqueConstraint(
            'user_id',
            'product_id',
            'purchase_id',
            name='_user_id_product_id_purchase_id_uc'),)

    def update(self, **kwargs):
        allowed_attrs = ['name', 'description', 'numstars']
        for k, v in kwargs.items():
            if k in allowed_attrs and v is not None:
                setattr(self, k, v)

    @classmethod
    def can_update_ids_by_user(self, review_ids, user):
        query_ids = list(set(review_ids))
        reviews = self.query.filter(self.id.in_(query_ids)).all()

        if len(reviews) != len(review_ids):
            raise ResourceNotFoundError(self.not_found_msg(review_ids),
                                        self.humanized_tablename())

        return list(map(lambda review: self.check_resource(
            review, user), reviews))

    @classmethod
    def check_resource(self, review, user):
        if not is_user_admin(user) and str(review.user_id) != get_user_id_from_user(user):
            raise ResourceNotFoundError(self.not_found_msg(review.id),
                                        self.humanized_tablename())

        return review
