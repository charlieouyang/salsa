"""Set foreignkeys on user_account and user_role tables

Revision ID: ceff866606d9
Revises: e3a1fba5d24c
Create Date: 2020-03-27 01:39:52.564640

"""
import salsa
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'ceff866606d9'
down_revision = 'e3a1fba5d24c'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_constraint('fk_user_account_user_role_id_user_role', 'user_account', type_='foreignkey')
    op.create_foreign_key(op.f('fk_user_account_user_role_id_user_role'), 'user_account', 'user_role', ['user_role_id'], ['id'])
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_constraint(op.f('fk_user_account_user_role_id_user_role'), 'user_account', type_='foreignkey')
    op.create_foreign_key('fk_user_account_user_role_id_user_role', 'user_account', 'user_role', ['user_role_id'], ['id'], ondelete='CASCADE')
    # ### end Alembic commands ###
