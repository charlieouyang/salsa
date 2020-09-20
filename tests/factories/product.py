import factory

from salsa import models

from .base import ModelFactory
from .user_account import UserAccountFactory


class ProductFactory(ModelFactory):
    active = True
    name = factory.Faker('text')
    description = factory.Faker('text')
    image_urls = factory.sequence(lambda n: 'image_url_{0}'.format(n))
    user_account = factory.SubFactory(UserAccountFactory)

    class Meta:
        model = models.Product
