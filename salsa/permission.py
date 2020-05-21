from functools import wraps
import toolz as T
from werkzeug.exceptions import Forbidden

ADMIN_PERM_TITLE = 'Admin'
USER_PERM_TITLE = 'User'

def get_user(kwargs):
    return kwargs.get('token_info')


def is_user_admin(user):
    permission_title = T.get_in(['prm', 'title'], user)
    return permission_title == ADMIN_PERM_TITLE


def only_admin(f):
    def check_if_admin(obj, *args, **kwargs):
        if not is_user_admin(get_user(kwargs)):
            raise Forbidden('Insufficient permissions')
        return f(obj, *args, **kwargs)

    return check_if_admin


def restrict_to(permission_func):
    def check(f):
        @wraps(f)
        def wrapper(obj, *args, **kwargs):

            user = get_user(kwargs)
            if not (is_user_admin(user)):
                permission_func(user)
            return f(obj, *args, **kwargs)

        return wrapper

    return check
