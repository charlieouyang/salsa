from sqlalchemy.ext.associationproxy import ASSOCIATION_PROXY
from sqlalchemy.ext.hybrid import hybrid_property
from sqlalchemy.inspection import inspect as sa_inspect

from salsa.utils.singleton import Singleton


class BaseResource(metaclass=Singleton):
    """
    Base class for repesenting an api resource
    for a sqlalchemy model.
    """
    model = None

    def __init__(self):
        self.model = self.__class__.model

    def retrieve(self, id_, **kwargs):
        return self.model.find_by_id(id_)

    def retrieve_list(self, **kwargs):
        instances = self.model.query
        fields = [c.key for c in self.model.__mapper__.columns]

        filters = {
            k: v
            for k, v in kwargs.items() if k in fields and v is not None
        }

        if filters:
            instances = instances.filter_by(**filters)

        return instances

    def update(self, id_, values):
        instance = self.model.find_by_id(id_)

        if 'id' in values:
            values.pop('id', None)

        instance.update(**values)
        instance.save()

        return instance

    def create(self, values):
        instance = self._create_instance(values)
        instance.save()

        return instance

    def _create_instance(self, values):
        hybrid_props = {}
        for k in list(values.keys()):
            descriptor = sa_inspect(self.model).all_orm_descriptors[k]
            # mdzhang: can't pass hybrid properties to constructor, so
            #          pop them now and invoke the setter directly later
            if type(descriptor) == hybrid_property:
                hybrid_props[k] = values.pop(k)

            if descriptor.extension_type is ASSOCIATION_PROXY:
                hybrid_props[k] = values.pop(k)

        instance = self.model(**values)

        for k, v in hybrid_props.items():
            setattr(instance, k, v)

        return instance

    # def create_list(self, values_list):
    #     from aboutface.db import db
    #     db.session.flush()
    #     try:
    #         instances = list(
    #             map(lambda v: self._create_instance(v), values_list))
    #         db.session.add_all(instances)
    #         db.session.commit()
    #         for i in instances:
    #             db.session.refresh(i)
    #         return instances
    #     except Exception as e:  # noqa
    #         db.session.rollback()
    #         raise

    def delete(self, id_):
        instance = self.model.find_by_id(id_)
        instance.delete()

        return None
