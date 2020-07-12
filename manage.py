#!/usr/bin/env python

import importlib
import pprint
import random
import string
import jwt
import time

from flask_migrate import Migrate, MigrateCommand
from flask_script import Manager, Server, Shell
from sqlalchemy_utils import create_database, database_exists, drop_database

from salsa.app import app
from salsa.config.config import config_class
from salsa.db import db

migrate = Migrate()
migrate.init_app(app, db, transaction_per_migration=True)

manager = Manager(app)
manager.add_command(
    'runserver',
    Server(
        host=app.config['HOST'], port=app.config['PORT'], threaded=True))

manager.add_command('db', MigrateCommand)
manager.add_option('-c', '--config', dest='config', required=False)


def _make_context():
    from salsa import models
    return dict(app=app, db=db, models=models)


# bpython loses app context
# see https://github.com/smurfix/flask-script/issues/155
manager.add_command(
    "shell", Shell(
        make_context=_make_context, use_bpython=False))


@manager.command
def create_db():
    """Creates the db"""
    if not database_exists(db.engine.url):
        create_database(db.engine.url)


@manager.command
def drop_db():
    print('DROP_DB')
    print(db.engine.url)
    """Drops the db"""
    if database_exists(db.engine.url):
        drop_database(db.engine.url)


# @manager.command
# def jumbo_seed(owner_count=50, profile_count=15, keyword_count=100):
#     """Extra data on top of the checked in db/salsa.sql seed"""
#     from salsa import models
#     from faker import Faker
#     fake = Faker()

#     def random_string(k=5):
#         return ''.join(
#             random.choices(
#                 string.ascii_uppercase + string.digits, k=k))

#     with app.app_context():
#         products = models.Product.query.all()
#         keyclasses = models.KeywordClass.query.all()
#         industries = models.Industry.query.all()
#         curators = []

#         for i in range(10):
#             name = fake.user_name() + random_string(2)
#             curator = models.Owner(
#                 name=name, email='{}@helistrong.com'.format(name))
#             curators.append(curator)

#         for i in range(owner_count):
#             print('Adding owner...')
#             # create i owners, each with a keyword set
#             name = fake.domain_name()
#             is_curated = random.choice([0, 1])
#             if is_curated:
#                 curator = random.choice(curators)

#             o = models.Owner(
#                 name=name,
#                 industries=[random.choice(industries)],
#                 email=name,
#                 salesforce_id='s' + random_string(15),
#                 curator=curator)
#             o.save()
#             ks = models.KeywordSet(entity_id=o.id, entity_table_name='owner')
#             ks.save()

#             # create j profiles per owner
#             for j in range(profile_count):
#                 print('Adding profile...')
#                 endpoint = '{}@{}.com'.format(fake.user_name(), name)
#                 np = models.NotificationProfile(
#                     endpoint=endpoint, owner=o, active=random.choice([0, 1]))
#                 np.save()

#                 # subscribe them to each product
#                 for p in products:
#                     print('Adding subscription...')
#                     models.Subscription(
#                         active=random.choice([0, 1]),
#                         notification_profile=np,
#                         keyword_set_id=ks.id,
#                         product_id=p.id).save()

#             # create k keywords per owner
#             for k in range(keyword_count):
#                 print('Adding keyword...')
#                 value = fake.word() + random_string()
#                 kc = random.choice(keyclasses)
#                 models.Keyword(
#                     value=value,
#                     keyword_set=ks,
#                     keyclass_id=kc.id,
#                     active=random.choice([0, 1]),
#                     is_curated=random.choice([0, 1])).save()


@manager.command
def create_tables():
    """Creates the db tables."""
    db.create_all()


@manager.command
def drop_tables():
    """Drops the db tables."""
    db.drop_all()


@manager.command
def drop_data():
    """Drop current db data but preserve schema"""
    for table in db.engine.table_names():
        # skip database migration tables
        if table.startswith('alembic'):
            continue

        sql = "TRUNCATE {} CASCADE".format(table)
        db.session.execute(sql)
        db.session.commit()


@manager.command
def dump_config():
    """Dumps config to stdout."""
    pprint.pprint(app.config)


@manager.command
def token():
    """Generate an admin JWT"""
    config_module, config_klass = config_class.rsplit('.', 1)
    conf = getattr(importlib.import_module(config_module), config_klass)
    conf_dict = {
        'APP_NAME': conf.APP_NAME,
        'JWT_PRIVATE_KEY': conf.JWT_PRIVATE_KEY,
        'JWT_EXPIRES_IN': 86400,
    }
    token = generate_jwt(conf_dict)
    print(token.decode('utf-8'))


def gen_internal_jwt_payload(config, **kwargs):
    """Generate a JWT payload.

    Arguments:
        config (dict): Used to populate default JWT entries
        **kwargs (dict): Used to add arbitrary data to your JWT or override
            default entries

    Returns:
        dict: JWT payload to be encoded
    """
    now = int(time.time())

    # Default expire in one hour, unless JWT_EXPIRES_IN specifies otherwise, in
    # seconds
    expires = now + int(config.get('JWT_EXPIRES_IN', 3600))
    payload = {
        'iat': now,
        'aud': config['APP_NAME'],
        'iss': config['APP_NAME'],
        'exp': expires,
    }

    payload.update(kwargs)

    return payload


def generate_jwt(config, **kwargs):
    """Generate a JWT.

    Arguments:
        config (dict): Used to populate default JWT entries and sign token
        **kwargs (dict): Used to add arbitrary data to your JWT or override
            default entries

    Returns:
        str: Encoded JWT
    """
    payload = gen_internal_jwt_payload(config, **kwargs)
    token = jwt.encode(
        payload,
        config.get('JWT_PRIVATE_KEY'),
        algorithm=config.get('JWT_ALGORITHM', 'ES256'), )
    return token


def main():
    manager.run()


if __name__ == '__main__':
    main()
