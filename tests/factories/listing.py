import factory
import random

from salsa import models

from .base import ModelFactory
from .user_account import UserAccountFactory
from .product import ProductFactory


class ListingFactory(ModelFactory):
    active = True
    name = factory.Faker('text')
    description = factory.Faker('text')
    price = random.randint(1,101)
    amount_available = random.randint(1,101)

    product = factory.SubFactory(ProductFactory)
    user_account = factory.SubFactory(UserAccountFactory)

    class Meta:
        model = models.Listing
