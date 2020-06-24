from flask import current_app as app
from marshmallow import fields
from marshmallow_sqlalchemy import ModelSchema as BaseSerializer

from salsa.models import (UserAccount,
                          UserRole,
                          Product,
                          Purchase,
                          Listing,
                          Review,
                          Category,
                          ProductCategory)


class PrettyField(fields.Field):
    def _serialize(self, value, attr, obj):
        if value is None:
            return ''
        return value


NON_EMBEDDED_FIELDS = {
    'ProductSerializer': ('id', 'active', 'name', 'description', 'image_urls', 'user_id', 'created_at', 'updated_at'),
    'ListingSerializer': ('id', 'active', 'name', 'description', 'price', 'amount_available', 'user_id', 'product_id', 'created_at', 'updated_at'),
    'PurchaseSerializer': ('id', 'amount', 'notes', 'user_id', 'listing_id', 'created_at', 'updated_at'),
    'ReviewSerializer': ('id', 'name', 'description', 'numstars', 'user_id', 'product_id', 'purchase_id', 'created_at', 'updated_at'),
    'UserAccountSerializer': ('id', 'name', 'email', 'user_role_id', 'extradata', 'created_at', 'updated_at'),
    'UserRoleSerializer': ('id', 'title', 'description'),
    'CategorySerializer': ('id', 'name'),
    'ProductCategorySerializer': ('id', 'product_id', 'category_id', 'created_at', 'updated_at'),
}

# things we don't want to show by default
EXCLUDE_FIELDS = {
    'UserAccountSerializer': ['password_hashed', 'listings', 'products',
                              'reviews', 'purchases'],
    'ListingSerializer': ['purchases'],
    'CategorySerializer': ['product_categories'],
}


class ProductSerializer(BaseSerializer):
    id = fields.UUID()
    user_id = fields.UUID()

    user_account = fields.Nested(
        'UserAccountSerializer',
        only=NON_EMBEDDED_FIELDS['UserAccountSerializer'])

    class Meta:
        model = Product


class ListingSerializer(BaseSerializer):
    id = fields.UUID()
    user_id = fields.UUID()
    product_id = fields.UUID()

    user_account = fields.Nested(
        'UserAccountSerializer',
        only=NON_EMBEDDED_FIELDS['UserAccountSerializer'])

    product = fields.Nested(
        'ProductSerializer',
        only=NON_EMBEDDED_FIELDS['ProductSerializer'])

    class Meta:
        model = Listing


class PurchaseSerializer(BaseSerializer):
    id = fields.UUID()
    user_id = fields.UUID()
    listing_id = fields.UUID()

    user_account = fields.Nested(
        'UserAccountSerializer',
        only=NON_EMBEDDED_FIELDS['UserAccountSerializer'])

    listing = fields.Nested(
        'ListingSerializer',
        only=NON_EMBEDDED_FIELDS['ListingSerializer'])

    class Meta:
        model = Purchase


class ReviewSerializer(BaseSerializer):
    id = fields.UUID()
    user_id = fields.UUID()
    purchase_id = fields.UUID()
    product_id = fields.UUID()

    user_account = fields.Nested(
        'UserAccountSerializer',
        only=NON_EMBEDDED_FIELDS['UserAccountSerializer'])

    purchase = fields.Nested(
        'PurchaseSerializer',
        only=NON_EMBEDDED_FIELDS['PurchaseSerializer'])

    product = fields.Nested(
        'ProductSerializer',
        only=NON_EMBEDDED_FIELDS['ProductSerializer'])

    class Meta:
        model = Review


class UserAccountSerializer(BaseSerializer):
    id = fields.UUID()
    user_role_id = fields.UUID()

    user_role = fields.Nested(
        'UserRoleSerializer',
        only=NON_EMBEDDED_FIELDS['UserRoleSerializer'])

    class Meta:
        model = UserAccount


class UserRoleSerializer(BaseSerializer):
    id = fields.UUID()

    user_accounts = fields.Nested(
        'UserAccountSerializer',
        many=True,
        only=NON_EMBEDDED_FIELDS['UserAccountSerializer'])

    class Meta:
        model = UserRole


class CategorySerializer(BaseSerializer):
    id = fields.UUID()

    class Meta:
        model = Category


class ProductCategorySerializer(BaseSerializer):
    id = fields.UUID()
    product_id = fields.UUID()
    category_id = fields.UUID()

    product = fields.Nested(
        'ProductSerializer',
        only=NON_EMBEDDED_FIELDS['ProductSerializer'])
    category = fields.Nested(
        'CategorySerializer',
        only=NON_EMBEDDED_FIELDS['CategorySerializer'])

    class Meta:
        model = ProductCategory
