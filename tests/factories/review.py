import factory
import random

from salsa import models

from .base import ModelFactory
from .user_account import UserAccountFactory
from .product import ProductFactory
from .purchase import PurchaseFactory


class ReviewFactory(ModelFactory):
    name = factory.Faker('text')
    description = factory.Faker('text')
    numstars = random.randint(1,6)

    user_account = factory.SubFactory(UserAccountFactory)
    product = factory.SubFactory(ProductFactory)
    purchase = factory.SubFactory(PurchaseFactory)

    class Meta:
        model = models.Review
