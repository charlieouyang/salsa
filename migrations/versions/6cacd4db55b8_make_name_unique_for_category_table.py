"""Make name unique for category table

Revision ID: 6cacd4db55b8
Revises: fda01d592a69
Create Date: 2020-06-21 01:46:07.605804

"""
import salsa
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '6cacd4db55b8'
down_revision = 'fda01d592a69'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.create_unique_constraint(op.f('uq_category_name'), 'category', ['name'])
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_constraint(op.f('uq_category_name'), 'category', type_='unique')
    # ### end Alembic commands ###
