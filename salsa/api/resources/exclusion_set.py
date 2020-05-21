from .base import BaseResource
from salsa.models import ExclusionSet
import json
from salsa.api.resources.helpers import serialize_return, sqlalchemy_exception_handler
from salsa.utils.decorators import decorate_all_methods


@decorate_all_methods(sqlalchemy_exception_handler)
class ExclusionSetResource(BaseResource):
    model = ExclusionSet

    @serialize_return(status=201)
    def create(self, exclusion_set, **kwargs):
        return super().create(exclusion_set)

    @serialize_return(status=201)
    def create_list(self, exclusion_sets, **kwargs):
        return super().create_list(exclusion_sets)

    @serialize_return(status=200)
    def retrieve(self, exclusion_set_id, **kwargs):
        return self.model.find_by_id(exclusion_set_id)

    @serialize_return(status=200)
    def retrieve_list(self, names=[], **kwargs):
        instances = super().retrieve_list(**kwargs)
        if len(names) > 0:
            instances = instances.filter(ExclusionSet.name.in_(names))
        return instances

    @serialize_return(status=200)
    def update(self, exclusion_set_id, exclusion_set, **kwargs):
        return super().update(exclusion_set_id, exclusion_set)

    @serialize_return(status=204)
    def delete(self, exclusion_set_id, **kwargs):
        return super().delete(exclusion_set_id)


exclusion_sets = ExclusionSetResource()
