import json
import time
from os import path

from salsa.app import app

config = app.config


def gen_google_jwt_payload(**kwargs):
    now = int(time.time())
    expires = now + 3600  # One hour in seconds

    payload = {
        'iat': now,
        'aud': config.get('GOOGLE_CLIENT_ID'),
        'sub': '103933419542963973012',
        'hd': 'helistrong.com',
        'email': 'mzhang@helistrong.com',
        'iss': 'accounts.google.com',
        'exp': expires,
    }

    payload.update(kwargs)

    return payload


def build_dict(seq, key):
    """
    Converts an iterable of dicts into a single dict whose keys are the
    values for that key in the original dicts.

    >>> fruits = [{'id':'1234','name':'apple', 'color':'red'},
                  {'id':'2345','name':'lemon', 'color':'yellow'},
                  {'id':'3456','name':'grape', 'color':'white'}]

    >>> build_dict(fruits, 'name')

    {'apple': {'id': '1234', 'name': 'apple', 'color': 'red', 'index': 0},
     'lemon': {'id': '2345', 'name': 'lemon', 'color': 'yellow', 'index': 1},
     'grape': {'id': '3456', 'name': 'grape', 'color': 'white', 'index': 2}}

    """
    return dict((d[key], dict(d, index=idx)) for (idx, d) in enumerate(seq))


def build_event(model, update_type):
    return {
        'model_object': model,
        'model': model.__class__.__name__,
        'type': update_type,
    }


def load_fixture(name):
    data = None
    filepath = path.join('tests/fixtures', '{}.json'.format(name))
    with open(filepath, 'r') as f:
        data = json.load(f)

    return data
