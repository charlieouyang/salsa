from os import getenv
from gevent import monkey
from grpc.experimental.gevent import init_gevent

monkey.patch_all()
init_gevent()

command = '/usr/bin/gunicorn'
worker_class = 'gevent'
debug = True

_port = getenv('GUNICORN_PORT', 5000)
bind = f'0.0.0.0:{_port}'
workers = 2
threads = 4
timeout = 15

logfile = '-'
accesslog = '-'
errorlog = '-'

limit_request_line = 4094

loglevel = 'debug'
reload = True
preload_app = False
