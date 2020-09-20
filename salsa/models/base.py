from sqlalchemy.exc import DatabaseError
from sqlalchemy.sql import text

from salsa.db import db
from salsa.exc import ResourceNotFoundError


class BaseModel(db.Model):
    __abstract__ = True

    def save(self, _commit=True):
        db.session.add(self)
        db.session.flush()

        if not _commit:
            return
        try:
            db.session.commit()
        except DatabaseError:
            db.session.rollback()
            raise

    def delete(self):
        db.session.delete(self)
        db.session.commit()

    @classmethod
    def find_by_id(cls, id_):
        instance = cls.query.get(id_)

        if instance is None:
            raise ResourceNotFoundError(cls.not_found_msg(id_),
                                        cls.humanized_tablename())

        return instance

    @classmethod
    def get_or_create(cls, _commit=True, **kwargs):
        instance = cls.get_from_field(**kwargs)

        if instance is None:
            instance = cls(**kwargs)
            instance.save(_commit)
            return instance
        return instance

    @classmethod
    def get_from_field(cls, **kwargs):
        return cls.query.filter_by(**kwargs).first()

    @classmethod
    def humanized_tablename(cls):
        return cls.__tablename__.replace('_', ' ').capitalize()

    @classmethod
    def not_found_msg(cls, id_):
        if type(id_) is list and len(id_) == 1:
            id_ = id_[0]
        return '{} with id {} not found'.format(cls.humanized_tablename(), id_)


def query_many(statement, **params):
    """
    Execute a raw SQL query and return all rows from the result.
    """
    with db.engine.connect() as con:
        result = con.execute(text(statement), **params)
        return result.fetchall()
