import toolz as T
from datetime import datetime

from salsa.db import db
from salsa.db.types import GUID
from salsa.models import BaseModel


class ProductCategory(BaseModel):
    __tablename__ = 'product_category'
    id = db.Column(GUID, primary_key=True, default=GUID.default_value)

    product_id = db.Column(GUID, db.ForeignKey('product.id'), nullable=False)
    category_id = db.Column(GUID, db.ForeignKey('category.id'), nullable=False)

    created_at = db.Column(
        db.DateTime, default=datetime.utcnow, nullable=False)
    updated_at = db.Column(
        db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    product = db.relationship(
        'Product',
        back_populates="product_categories")
    category = db.relationship(
        'Category',
        back_populates="product_categories")

    __table_args__ = (
        db.UniqueConstraint(
            'product_id',
            'category_id',
            name='uk_product_to_category'),)
