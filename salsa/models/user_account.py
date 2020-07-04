import toolz as T
from datetime import datetime

from salsa.db import db
from salsa.db.types import GUID
from salsa.models import BaseModel
from salsa.exc import ResourceNotFoundError
from salsa.permission import is_user_admin


class UserAccount(BaseModel):
    # user is a reserved keyword in postgres
    __tablename__ = 'user_account'
    id = db.Column(GUID, primary_key=True, default=GUID.default_value)
    user_name = db.Column(db.String(255), unique=True, nullable=False)
    name = db.Column(db.String(255), unique=False, nullable=False)
    email = db.Column(db.String(255), unique=True, nullable=False)
    extradata = db.Column(db.String(255), unique=False, nullable=True)
    password_hashed = db.Column(db.String(255), nullable=False)
    user_role_id = db.Column(GUID,
                             db.ForeignKey('user_role.id'),
                             nullable=False)
    created_at = db.Column(
        db.DateTime, default=datetime.utcnow, nullable=False)
    updated_at = db.Column(
        db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    user_role = db.relationship('UserRole',
                                foreign_keys=user_role_id,
                                back_populates='user_accounts')

    products = db.relationship(
        'Product',
        cascade="delete",
        back_populates="user_account",
        lazy='dynamic')
    listings = db.relationship(
        'Listing',
        cascade="delete",
        back_populates="user_account",
        lazy='dynamic')
    purchases = db.relationship(
        'Purchase',
        cascade="delete",
        back_populates="user_account",
        lazy='dynamic')
    reviews = db.relationship(
        'Review',
        cascade="delete",
        back_populates="user_account",
        lazy='dynamic')

    def update(self, **kwargs):
        allowed_attrs = ['name', 'email', 'password_hashed', 'extradata']
        for k, v in kwargs.items():
            if k in allowed_attrs and v is not None:
                setattr(self, k, v)

    @classmethod
    def find_by_ids_for_user(self, user_account_ids, user):
        query_ids = list(set(user_account_ids))
        user_accounts = self.query.filter(self.id.in_(query_ids)).all()

        if len(user_accounts) != len(user_account_ids):
            raise ResourceNotFoundError(self.not_found_msg(user_account_ids),
                                        self.humanized_tablename())

        return list(map(lambda user_account: self.check_resource(
            user_account, user), user_accounts))

    @classmethod
    def check_resource(self, user_account, user):
        if not is_user_admin(user) and str(user_account.id) != T.get_in(['usr', 'id'], user):
            raise ResourceNotFoundError(self.not_found_msg(user_account.id),
                                        self.humanized_tablename())

        return user_account
