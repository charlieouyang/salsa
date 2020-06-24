"""Add notes column to purchase table

Revision ID: dc9ae69457dc
Revises: f91f0bbb43e5
Create Date: 2020-05-31 16:32:48.575189

"""
import salsa
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'dc9ae69457dc'
down_revision = 'f91f0bbb43e5'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.add_column('purchase', sa.Column('notes', sa.Text(), nullable=True))
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_column('purchase', 'notes')
    # ### end Alembic commands ###
