from collections import Iterable
from functools import wraps
from uuid import UUID, uuid4
import bcrypt
import json

import flask
from flask import current_app as app
import sqlalchemy as sa
from marshmallow import fields
import toolz as T
from werkzeug.exceptions import Forbidden, BadRequest

import salsa.serializers
from salsa.utils.responses import error, no_content, not_found, reply
from salsa.exc import (CuratedAlertingError, ForbiddenAction,
                       InvalidRequest, MetricNotFoundError,
                       MissingMetricParametersError,
                       SalesforceAccountNotFound, SalesforceDisabled,
                       SwaggerValidationError, ValidationError,
                       ResourceNotFoundError)

def sqlalchemy_exception_handler(f):
    @wraps(f)
    def wrapper(obj, *args, **kwargs):
        try:
            return f(obj, *args, **kwargs)
        except sa.exc.IntegrityError as exc:

            title = 'Invalid {}'.format(obj.model.__name__)
            detail = '{} validation error'.format(obj.model.__name__)

            if 'already exists' in str(exc):
                title = 'Duplicate {}'.format(obj.model.__name__)
                detail = '{} already exists'.format(obj.model.__name__)

            return error(title=title, status=400, detail=detail)

        except sa.exc.StatementError as exc:
            if str(exc.orig) == 'badly formed hexadecimal UUID string':
                title = 'Invalid {}'.format(obj.model.__name__)
                detail = 'Not a valid {} ID'.format(obj.model.__name__)
                return error(title=title, status=400, detail=detail)
            raise
        except sa.exc.SQLAlchemyError as exc:
            error_id = uuid4()
            app.logger.error(f'Database error: {error_id}: {str(exc)}')
            return error(detail=f'Database error: {error_id}', status=500)
        except ResourceNotFoundError as exc:
            title = 'Missing {}'.format(exc.model)
            return not_found(title=title, detail=str(exc))
        except CuratedAlertingError as exc:
            return error(status=403, title='Keyword creation forbidden',
                         detail=str(exc))
        except MetricNotFoundError as exc:
            title = 'Missing Metric'
            return not_found(title=title, detail=str(exc))
        except MissingMetricParametersError as exc:
            title = 'Missing Metric Parameter'
            return error(title=title, status=400, detail=str(exc))
        except ValidationError as exc:
            title = 'Invalid {}'.format(obj.model.__name__)
            return error(title=title, status=400, detail=str(exc))
        except (InvalidRequest, SwaggerValidationError) as exc:
            title = 'Invalid Request'
            return error(title=title, status=400, detail=str(exc))
        except ForbiddenAction as exc:
            return error(title='Forbidden', status=403, detail=str(exc))
        except Forbidden as exc:
            return error(title='Forbidden', status=403, detail=exc.description)

    return wrapper

def get_serializer(kls, embed=None):
    serializer_name = '{}Serializer'.format(kls.__name__)
    serializer_cls = getattr(salsa.serializers, serializer_name)

    # by default, exclude nested fields
    exclude_fields = salsa.serializers.EXCLUDE_FIELDS.get(
        serializer_name, [])
    default_excludes = set(
        f for f, k in serializer_cls._declared_fields.items()
        if isinstance(k, fields.Nested) or isinstance(k, fields.Dict)
    ).union(k for k in exclude_fields)
    embed = set(embed) if embed is not None else set()
    extra_excludes = set()

    # of the fields to embed, exclude their nested fields as well
    for e in embed:
        try:
            schema = serializer_cls._declared_fields[e].schema.__class__
        except (AttributeError, KeyError):
            pass
        else:
            more_excludes = set(
                '{}.{}'.format(e, f)
                for f, k in schema._declared_fields.items()
                if isinstance(k, fields.Nested) or isinstance(k, fields.Dict))
            extra_excludes.update(more_excludes)

    all_excludes = default_excludes.union(extra_excludes) - set(embed)

    serializer = serializer_cls(exclude=all_excludes)
    return serializer


def serialize_instance(instance, embed=None):
    """Convert model instance to dict for JSON response serialization

    :param salsa.models.about_face_base.BaseModel instance:
    :param str embed: CSV of names of relations to embed in the response e.g.
        'curator,keywords' for an salsa.models.Owner
    """
    serializer = get_serializer(instance.__class__, embed=embed)
    return serializer.dump(instance)


def serialize_instances(instances, embed=None, page=None):
    instances = list(instances)
    if instances:
        serializer = get_serializer(instances[0].__class__, embed=embed)
        data = serializer.dump(instances, many=True)
    else:
        data = []

    # if any pagination data is provided, return an object response
    # with the pagination data as top-level keys, and the serialized
    # instances as a list under the `data` key
    if page:
        res = dict(data=data)
        res.update(page)
        return res

    return data


def serialize_return(**overrides):
    def serialize_response_inner(f):
        @wraps(f)
        def wrapper(obj, *args, **kwargs):
            instances = f(obj, *args, **kwargs)

            if isinstance(instances, flask.Response):
                return instances

            # handle sorting
            sort = kwargs.get('sort')

            if sort and instances:
                if sort.startswith('-'):
                    order = 'desc'
                    field_name = sort[1:]
                else:
                    order = 'asc'
                    field_name = sort
                field = getattr(obj.model, field_name)

                instances = instances.order_by(getattr(field, order)())

            # handle pagination
            page_number = kwargs.get('page_number')
            page_size = kwargs.get('page_size')
            page = None

            if page_number and page_size:
                total = instances.count()
                count = total // page_size
                if total > count * page_size:
                    count += 1
                page = dict(
                    size=page_size,
                    number=page_number,
                    total=total,
                    count=count)
                instances = instances.limit(page_size).offset(
                    (page_number - 1) * page_size)

            # handle embedded relations
            embed = kwargs.get('embed')

            # handle 204s
            if instances is None:
                return no_content()

            # serialize model instances to JSON
            # instances can be a non-iterable if serializing a single
            # resource e.g. after a POST
            if not isinstance(instances, Iterable):
                return reply(
                    body=serialize_instance(instances, embed), **overrides)
            return reply(
                body=serialize_instances(
                    instances, embed=embed, page=page),
                **overrides)

        return wrapper

    return serialize_response_inner


def get_hashed_password(plain_text_password):
    # Hash a password for the first time
    #   (Using bcrypt, the salt is saved into the hash itself)
    return bcrypt.hashpw(plain_text_password.encode('utf8'), bcrypt.gensalt(12)).decode('utf8')


def check_password(plain_text_password, hashed_password):
    # Check hashed password. Using bcrypt, the salt is saved into the hash itself
    if not bcrypt.checkpw(plain_text_password.encode('utf8'), hashed_password.encode('utf8')):
        raise ValueError('Password do not match')

def is_valid_json(string_payload):
    json.loads(string_payload)

def is_valid_uuid4(uuid_string):
    try:
        UUID(uuid_string, version=4)
    except ValueError:
        return False

    return True
