import os

# Stores supported environments: name -> config class relative import
environments = {
    'development': 'development.DevelopmentConfig',
    'testing': 'testing.TestingConfig',
    'staging': 'staging.StagingConfig',
    'production': 'production.ProductionConfig',
}

# Get the current runtime environment variable
environment = os.getenv('ENVIRONMENT', 'development')

# Config environment import expression to load
config_import = environments.get(environment, environments['development'])

# Expose the config class Python import expression
# to be used based on the runtime environment.
config_class = 'salsa.config.' + config_import

PREFIX = 'SALSA'
SQLALCHEMY_DB_URI_TEMPLATE = \
    '{dialect}://{user}:{password}@{host}:{port}/{name}'
SQLALCHEMY_DB_URI_DEFAULTS = {
    'dialect': 'postgresql',
    'name': 'salsa-{}'.format(environment),
    'user': 'salsa',
    'password': 'salsa',
    'host': 'localhost',
    'port': '5432',
}


def env(name, default=None):
    """
    Returns a value from an environment variable.

    Mimics behaviour of ``os.getenv()``.

    Returns:
        str: environment variable value or default value.
    """
    return os.getenv('{}_{}'.format(PREFIX, name), default)


def env_bool(name, default=None, truthy=(1, '1', 'true', 'True', True)):
    """
    Returns a bool value from an environment variable.
    Uses env() and return True if value is one of the items in `truthy`

    Returns:
        bool: environment variable bool value.
    """
    val = env(name, default)
    return (val in truthy)


def db_uri(template=SQLALCHEMY_DB_URI_TEMPLATE, **overrides):
    defaults = SQLALCHEMY_DB_URI_DEFAULTS.copy()
    defaults.update(overrides)

    return template.format(**{
        'dialect': 'postgresql',
        'name': env('DB_NAME', defaults.get('name')),
        'user': env('DB_USER', defaults.get('user')),
        'password': env('DB_PASSWORD', defaults.get('password')),
        'host': env('DB_HOST', defaults.get('host')),
        'port': env('DB_PORT', defaults.get('port')),
    })


def read_key(path):
    if not path or not os.path.isfile(path):
        return

    with open(path, 'r') as fin:
        return fin.read()
