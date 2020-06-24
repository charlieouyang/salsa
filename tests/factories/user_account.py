import factory

from salsa import models

from .base import ModelFactory
from .user_role import UserRoleFactory


class UserAccountFactory(ModelFactory):
    user_name = factory.sequence(lambda n: 'user_name_{0}'.format(n))
    name = factory.sequence(lambda n: 'name_{0}'.format(n))
    email = factory.sequence(lambda n: 'email_{0}'.format(n))
    extradata = '{"sample": "extra", "example": "data"}'
    password_hashed = factory.Faker('text')
    user_role = factory.SubFactory(UserRoleFactory)

    class Meta:
        model = models.UserAccount
