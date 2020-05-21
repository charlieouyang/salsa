import inspect
from functools import wraps


def decorate_all_methods(decorator):
    def decorate(cls):
        for attr in cls.__dict__:
            prop = getattr(cls, attr)
            if inspect.isfunction(prop):
                ignore_decorators = getattr(prop, '__ignore_decorators', [])
                if decorator not in ignore_decorators:
                    setattr(cls, attr, decorator(getattr(cls, attr)))
        return cls

    return decorate


def skip_decorators(*decorators):
    def wrapper(func):
        func.__ignore_decorators = decorators

        @wraps(func)
        def inner(*args, **kwargs):
            return func(*args, **kwargs)
        return inner
    return wrapper
