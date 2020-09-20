import toolz as T
from datetime import datetime

from salsa.db import db
from salsa.db.types import GUID
from salsa.models import BaseModel
from salsa.exc import ResourceNotFoundError


class Category(BaseModel):
    __tablename__ = 'category'
    id = db.Column(GUID, primary_key=True, default=GUID.default_value)
    name = db.Column(db.String(255), unique=True, nullable=False)

    created_at = db.Column(
        db.DateTime, default=datetime.utcnow, nullable=False)
    updated_at = db.Column(
        db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    product_categories = db.relationship(
        'ProductCategory',
        back_populates='category')

    def update(self, **kwargs):
        allowed_attrs = ['name']
        for k, v in kwargs.items():
            if k in allowed_attrs and v is not None:
                setattr(self, k, v)

    @classmethod
    def find_by_ids(self, category_ids):
        query_ids = list(set(category_ids))
        categories = self.query.filter(self.id.in_(query_ids)).all()

        if len(categories) != len(category_ids):
            raise ResourceNotFoundError(self.not_found_msg(category_ids),
                                        self.humanized_tablename())

        return categories
