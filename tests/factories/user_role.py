import factory
import random

from salsa import models
from salsa import permission

from .base import ModelFactory


def get_role():
    return random.choice([permission.ADMIN_PERM_TITLE,
                          permission.USER_PERM_TITLE])

class UserRoleFactory(ModelFactory):
    # title = get_role()
    title = factory.Faker('text')
    description = factory.Faker('text')

    class Meta:
        model = models.UserRole
