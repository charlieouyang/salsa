from salsa.db import db
from salsa.db.types import GUID
from salsa.models import BaseModel
from salsa.exc import ResourceNotFoundError, ForbiddenAction
from salsa.permission import is_user_admin, ADMIN_PERM_TITLE


class UserRole(BaseModel):
    __tablename__ = 'user_role'
    id = db.Column(GUID, primary_key=True, default=GUID.default_value)
    title = db.Column(db.String(255), unique=True, nullable=False)
    description = db.Column(db.String(255), unique=True, nullable=False)

    user_accounts = db.relationship(
        'UserAccount',
        cascade="delete",
        back_populates="user_role",
        lazy='dynamic')

    def update(self, **kwargs):
        allowed_attrs = ['description', 'title']
        for k, v in kwargs.items():
            if k in allowed_attrs and v is not None:
                setattr(self, k, v)

    # This permission check is only used when creating user_accounts
    # We want to prevent NOT admin users to create admin users
    @classmethod
    def can_create_user_account_with_role_ids(self, user_role_ids, user):
        query_ids = list(set(user_role_ids))
        user_roles = self.query.filter(self.id.in_(query_ids)).all()

        if len(user_roles) != len(user_role_ids):
            raise ResourceNotFoundError(self.not_found_msg(user_role_ids),
                                        self.humanized_tablename())

        return list(map(lambda u_role: self.check_resource(
            u_role, user), user_roles))

    @classmethod
    def check_resource(self, user_role, user):
        # If user is NOT admin, and user_role title is admin... ERROR
        if not is_user_admin(user) and str(user_role.title) == ADMIN_PERM_TITLE:
            raise ForbiddenAction(f'Using this role id <{user_role.id}> is not allowed.')

        return user_role
