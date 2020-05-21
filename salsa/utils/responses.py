"""Helpers to generate API responses
"""
import flask
from connexion import Api, problem


def reply(status=200, body=None, headers=None):
    """
    Returns a tuple with the HTTP response based
    on the given arguments.
    """

    if body is None:
        res = flask.make_response()
    else:
        res = flask.jsonify(body)

    res.status_code = status

    if headers:
        res.headers.extend(headers)

    return res


def error(status=500, title='Server Error', detail='Server error', headers={}):
    """
    Returns a custom error response based on
    the given status code, message error and optional headers.
    """
    res = problem(
        status, title, str(detail), type='application/json', headers=headers)
    return Api.get_response(response=res)


def not_found(title='Not Found Error', detail='Resource not found'):
    """
    Returns a generic 404 Not Found response.
    """
    return error(404, title=title, detail=detail)


def no_content(headers=None):
    """
    Returns a generic 204 No Content response.
    """
    return reply(status=204, headers=None)
