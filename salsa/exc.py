class SalsaError(Exception):
    """Generic error class."""

    def __init__(self, *arg, **kw):
        self.code = kw.pop('code', None)
        super(SalsaError, self).__init__(*arg, **kw)


class InvalidEventHandler(SalsaError):
    """Recieved an invalid event handler"""
    def __init__(self, msg, *args, **kwargs):
        message = "Invalid Event Handler: {}".format(msg)
        super(InvalidEventHandler, self).__init__(message, *args, **kwargs)


class ValidationError(SalsaError):
    """Generic model validation error"""

    def __init__(self, field, model, value, reason, detail=None, *arg, **kw):
        self.field = field
        self.model = model
        self.value = value
        self.reason = reason
        self.detail = detail

        message = ("Validation failed on {} for field {} with value {}: {}"
                   .format(self.model.__name__, self.field, self.value,
                           self.reason))

        super(ValidationError, self).__init__(message, *arg, **kw)


class InvalidCsvError(SalsaError):
    """Tried to process an invalid CSV"""


class ResourceNotFoundError(SalsaError):
    """Unable to retrieve the requested resource"""

    def __init__(self, message, model, *arg, **kw):
        self.message = message
        self.model = model

        super().__init__(message, *arg, **kw)


class MetricNotFoundError(SalsaError):
    """Passed an invalid metric"""

    def __init__(self, metric, code='metric.notfound', *arg, **kw):
        self.metric = metric

        msg = "Metric '{}' not found".format(metric)

        super().__init__(msg, *arg, **kw)


class MissingMetricParametersError(SalsaError):
    """Failed to pass a required parameter for a parameterized metric"""

    def __init__(self, param, code='metric.parameter.missing', *arg, **kw):
        self.param = param

        msg = "Metric parameter '{}' not given".format(param)

        super().__init__(msg, *arg, **kw)


class NoValidatorForMetricException(SalsaError):
    """Failed to validate a metric query param set due to missing definition"""

    def __init__(self, metric, code='metric.validator.notfound', **kwargs):
        self.metric = metric
        message = 'No swagger validator found for metric "{}"'.format(metric)
        super().__init__(message, code=code, **kwargs)


class SwaggerValidationError(SalsaError):
    """Custom swagger validation failed"""

    def __init__(self, message, code='validation.swagger.failed', **kwargs):
        super().__init__(message, code=code, **kwargs)


class ForbiddenAction(SalsaError):
    """Tried setting a value that was not allowed"""


class SalesforceDisabled(SalsaError):
    """Salesforce integration is disabled"""


class SalesforceAccountNotFound(SalsaError):
    """Salesforce integration is disabled"""


class CuratedAlertingError(SalsaError):
    """Curated keywords could not created or updated due to errors"""


class OperationalError(SalsaError):
    """Generic error to categorize all 500 errros"""

class InvalidRequest(SalsaError):
    """Generic invalid request"""
