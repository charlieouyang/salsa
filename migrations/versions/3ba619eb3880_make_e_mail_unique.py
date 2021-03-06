"""Make e-mail unique

Revision ID: 3ba619eb3880
Revises: 566afb5b027d
Create Date: 2020-07-04 02:36:38.943658

"""
import salsa
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '3ba619eb3880'
down_revision = '566afb5b027d'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.create_unique_constraint(op.f('uq_user_account_email'), 'user_account', ['email'])
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_constraint(op.f('uq_user_account_email'), 'user_account', type_='unique')
    # ### end Alembic commands ###
