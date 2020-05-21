import os

from .config import db_uri, env, environment, env_bool, read_key


class Config:
    APP_NAME = 'salsa'
    VERSION = '0.0.1'

    ENVIRONMENT = environment
    DEBUG = True
    HOST = '0.0.0.0'
    PORT = int(os.getenv('PORT', 5000))
    JSON_SORT_KEYS = False

    SALSA_ROOT = '/opt/couyang'
    if not os.path.isdir(SALSA_ROOT):
        SALSA_ROOT = os.path.dirname(
            os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        )

    LOG_DIR = env('LOG_DIR', os.path.join(SALSA_ROOT, 'logs'))
    if not os.path.isdir(LOG_DIR):
        os.mkdir(LOG_DIR)
    LOG_LEVEL = env('LOG_LEVEL', 'INFO')
    LOG_HANDLERS = env('LOG_HANDLERS', None)

    # Health check settings
    HEALTH_CHECK = True
    HEALTH_ENVIRONMENT = True

    # Specifies the service API version
    BASE_PATH = '/v1'
    BASE_LOCATION = '/v1/'
    SWAGGER_SPEC_LOCATION = 'api.yaml'

    SQLALCHEMY_DATABASE_URI = env('SQLALCHEMY_DATABASE_URI', db_uri())
    # Track changes to models through signals
    # (see http://flask-sqlalchemy.pocoo.org/2.1/signals/)
    SQLALCHEMY_TRACK_MODIFICATIONS = True

    JWT_PUBLIC_KEYS = {
        service:
        read_key(os.getenv('FP_{}_JWT_PUBLIC_KEY'.format(service.upper())))
        for service in
        ['salsa']
    }

    JWT_PRIVATE_KEY = read_key(env('JWT_PRIVATE_KEY'))
