import factory

from salsa import models

from .base import ModelFactory


class ExclusionSetFactory(ModelFactory):
    name = factory.sequence(lambda n: 'exclusion_set{0}'.format(n))
    usr = factory.Faker('name')

    class Meta:
        model = models.ExclusionSet
