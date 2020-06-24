import factory
import random

from salsa import models

from .base import ModelFactory
from .user_account import UserAccountFactory
from .listing import ListingFactory


class CategoryFactory(ModelFactory):
    name = factory.Faker('text')

    class Meta:
        model = models.Category
