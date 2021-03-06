"""Remove username from user_account table

Revision ID: f6fe465a6455
Revises: 3ba619eb3880
Create Date: 2020-07-05 20:07:03.925818

"""
import salsa
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'f6fe465a6455'
down_revision = '3ba619eb3880'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_constraint('uq_user_account_user_name', 'user_account', type_='unique')
    op.drop_column('user_account', 'user_name')
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.add_column('user_account', sa.Column('user_name', sa.VARCHAR(length=255), autoincrement=False, nullable=False))
    op.create_unique_constraint('uq_user_account_user_name', 'user_account', ['user_name'])
    # ### end Alembic commands ###
