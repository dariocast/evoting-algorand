import json
from datetime import date

from flask import Response


def json_date_to_str(o):
    if isinstance(o, date):
        return o.__str__()


class ResponseBuilder(object):

    def __init__(self, message: str = None, data=None, status_code: int = 200, exception: Exception = None,
                 errors: str = ""):

        self.values = {}
        self.message = message
        self.status_code = status_code

        if exception:
            self.exception = exception.__class__.__name__
            self.data = "Generic Error" if data == "" else data
            self.errors = str(exception) if errors == "" else errors
        else:
            self.exception = None
            self.data = data
            self.errors = errors
        if self.message:
            self.values['message'] = self.message
        if self.status_code:
            self.values['status'] = self.status_code
        if self.data:
            self.values['data'] = self.data
        if self.exception:
            self.values['exception'] = self.exception
        if self.errors:
            self.values['errors'] = self.errors

    def _to_json(self):
        return json.dumps(self.values, default=json_date_to_str)

    def build(self):
        return Response(response=self._to_json(),
                        status=self.status_code,
                        mimetype="application/json")
