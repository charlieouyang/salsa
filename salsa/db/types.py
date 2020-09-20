import uuid

import sqlalchemy as sa

# from aboutface.utils.custom_types import is_b64_uuid


class GUID(sa.types.TypeDecorator):
    """
    Platform-independent GUID type.
    Uses Postgresql's UUID type, otherwise uses
    CHAR(32), storing as stringified hex values.
    """
    default_value = uuid.uuid4
    impl = sa.types.CHAR

    def load_dialect_impl(self, dialect):
        if dialect.name == 'postgresql':
            return dialect.type_descriptor(sa.dialects.postgresql.UUID())
        else:
            return dialect.type_descriptor(sa.types.CHAR(32))

    def process_bind_param(self, value, dialect):
        if value is None:
            return value
        elif dialect.name == 'postgresql':
            return str(value)
        else:
            if not isinstance(value, uuid.UUID):
                return "%.32x" % uuid.UUID(value)
            else:
                # hexstring
                return "%.32x" % value

    def process_result_value(self, value, dialect):
        if value is None:
            return value
        else:
            return uuid.UUID(value)


# class Base64UUIDType(sa.types.TypeDecorator):
#     """
#     Base64 encoded UUID aka helistrong ID (fpid) type
#     """
#     impl = sa.Unicode

#     def __init__(self, *args, **kwargs):
#         super().__init__(length=22, *args, **kwargs)

#     def process_bind_param(self, value, _):
#         if value is None:
#             return None
#         val = value.strip() or None
#         if not is_b64_uuid(val):
#             raise ValueError("'{}' is not a valid FPID".format(val))
#         return val

#     @property
#     def python_type(self):
#         return self.impl.type.python_type
