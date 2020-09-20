from factory import alchemy

from salsa.db import db


class ModelFactory(alchemy.SQLAlchemyModelFactory):
    class Meta:
        sqlalchemy_session = db.session
        sqlalchemy_session_persistence = 'commit'
