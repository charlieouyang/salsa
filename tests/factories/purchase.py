import factory
import random

from salsa import models

from .base import ModelFactory
from .user_account import UserAccountFactory
from .listing import ListingFactory


class PurchaseFactory(ModelFactory):
    amount = random.randint(1,101)
    notes = factory.Faker('text')

    listing = factory.SubFactory(ListingFactory)
    user_account = factory.SubFactory(UserAccountFactory)

    class Meta:
        model = models.Purchase
