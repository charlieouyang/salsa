from .config import db_uri, env
from .defaults import Config


class ProductionConfig(Config):
    """
    ProductionConfig stores the production environment specific config params.
    """
    DEBUG = False
