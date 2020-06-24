"""Drop unused table

Revision ID: 3c409a2d11f6
Revises: 33e89c81d574
Create Date: 2020-05-31 04:53:40.827948

"""
import salsa
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision = '3c409a2d11f6'
down_revision = '33e89c81d574'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_table('exclusion_set')
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.create_table('exclusion_set',
    sa.Column('id', postgresql.UUID(), autoincrement=False, nullable=False),
    sa.Column('name', sa.VARCHAR(length=255), autoincrement=False, nullable=False),
    sa.Column('usr', sa.VARCHAR(length=255), autoincrement=False, nullable=False),
    sa.PrimaryKeyConstraint('id', name='pk_exclusion_set'),
    sa.UniqueConstraint('name', name='uq_exclusion_set_name'),
    sa.UniqueConstraint('usr', name='uq_exclusion_set_usr')
    )
    # ### end Alembic commands ###
