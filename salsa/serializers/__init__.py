from flask import current_app as app
from marshmallow import fields
from marshmallow_sqlalchemy import ModelSchema as BaseSerializer

from salsa.models import ExclusionSet
from salsa.models import UserAccount, UserRole


class PrettyField(fields.Field):
    def _serialize(self, value, attr, obj):
        if value is None:
            return ''
        return value


NON_EMBEDDED_FIELDS = {
    'ExclusionSetSerializer': ('id', 'name'),
    'UserAccountSerializer': ('id', 'name', 'email', 'user_role_id', 'created_at', 'updated_at'),
    'UserRoleSerializer': ('id', 'title', 'description'),
}

EXCLUDE_FIELDS = {
    'UserAccountSerializer': ['password_hashed'],
}


class ExclusionSetSerializer(BaseSerializer):
    id = fields.UUID()

    class Meta:
        model = ExclusionSet

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



# class KeywordSerializer(BaseSerializer):
#     keyword_set_id = fields.UUID()
#     keyword_set = fields.Nested(
#         'KeywordSetSerializer',
#         only=NON_EMBEDDED_FIELDS['KeywordSetSerializer'])
#     keyclass_id = fields.UUID()
#     keyclass = fields.Nested(
#         'KeywordClassSerializer',
#         only=NON_EMBEDDED_FIELDS['KeywordClassSerializer'])
#     industry = fields.Nested(
#         'IndustrySerializer', only=NON_EMBEDDED_FIELDS['IndustrySerializer'])
#     industry_id = fields.UUID()
#     owner = fields.Nested(
#         'OwnerSerializer', only=NON_EMBEDDED_FIELDS['OwnerSerializer'])
#     owner_id = fields.UUID()

#     class Meta:
#         model = Keyword
#         exclude = ('keyword_subscriptions', 'keyword_datasource')


# class KeywordClassSerializer(BaseSerializer):
#     keywords = fields.Nested(
#         'KeywordSerializer',
#         many=True,
#         only=NON_EMBEDDED_FIELDS['KeywordSerializer'])

#     class Meta:
#         model = KeywordClass