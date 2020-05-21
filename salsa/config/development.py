from .testing import TestingConfig


class DevelopmentConfig(TestingConfig):
    """
    DevelopmentConfig stores development environment specific config params.
    """
    SQLALCHEMY_ECHO = False
