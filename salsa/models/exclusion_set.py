from salsa.db import db
from salsa.db.types import GUID
from salsa.models import BaseModel


class ExclusionSet(BaseModel):
    __tablename__ = 'exclusion_set'
    id = db.Column(GUID, primary_key=True, default=GUID.default_value)
    name = db.Column(db.String(255), unique=True, nullable=False)
    usr = db.Column(db.String(255), unique=True, nullable=False)

    def update(self, **kwargs):
        allowed_attrs = ['name']
        for k, v in kwargs.items():
            if k in allowed_attrs and v is not None:
                setattr(self, k, v)