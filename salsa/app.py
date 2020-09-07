import importlib
import os
import re

from connexion import App
from connexion.resolver import RestyResolver

from salsa.config.config import config_class
from salsa.db import db


is_gunicorn = 'gunicorn' in os.getenv('SERVER_SOFTWARE', '')


def configure_api(app, config):
    # add custom swagger formatters to json schema registry

    # register the swagger-based API
    app.add_api(
        'api.yaml',
        base_path=config['BASE_PATH'],
        resolver=RestyResolver('salsa.api'),
        strict_validation=True,
        pythonic_params=True)

    # # register health endpoints
    # health_bind(app, config)

    # # register version route
    # version_bind(app, config)

    # # register the endpoint that proxies to curator
    # app.app.register_blueprint(curator_proxy, url_prefix=config
    #                            ['CURATOR_URL_PREFIX'])

    # # register the endpoint that proxies to postalservice
    # app.app.register_blueprint(postalservice_proxy, url_prefix=config
    #                            ['POSTALSERVICE_URL_PREFIX'])


# def configure_auth(app, config):
#     """Add authentication handler"""
#     excludes.append('/health')
#     excludes.append('/version')
#     excludes.append('/swagger.json')
#     excludes.append(re.compile('/favicon.ico'))
#     excludes.append('/metrics')
#     auth_bind(
#         app,
#         regex_excludes=excludes,
#         config=config,
#         base_path=config['BASE_PATH'])


def configure_db(app):
    # register db models
    from salsa import models  # noqa
    db.init_app(app)
    # from aboutface.models.keyword_set import setup as keyword_set_setup
    # keyword_set_setup()


def create_app(config=None):
    app = App(__name__)
    application = app.app

    if config is None:
        application.config.from_object(config_class)

    configure_api(app, config=application.config)
    configure_db(application)
    # configure_auth(application, config=application.config)

    @application.after_request
    def set_content_charset(response):
        if response.headers.get('Content-Type') == 'application/json':
            response.headers['Content-Type'] = \
                'application/json; charset=utf-8'
        return response

    return application


app = create_app()


def run():
    if not is_gunicorn:
        app.run(host=app.config['HOST'], port=app.config['PORT'])

# Auto start server if running as main module
if __name__ == '__main__':
    run()
