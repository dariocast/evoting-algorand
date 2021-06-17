from enum import Enum


class AlgoVotingErrorCode(Enum):
    GENERIC_ERROR = -1,
    REQUEST_NOT_JSON = 1,
    INVALID_VOTING_JSON = 2,


    @staticmethod
    def getErrorCodeListToString(list):
        str1 = ""
        for ele in list:
            str1 += " " + str(ele.value) + "(" + ele.name + ")"
        return str1

class AlgoVotingException(Exception):
    def __init__(self, status_code: int, exception_type: AlgoVotingErrorCode = AlgoVotingErrorCode.GENERIC_ERROR, message: str = "",
                 errors: str = "", data=None):
        if data is None:
            data = {}
        self.code = status_code
        self.exception_type = exception_type
        self.message = message
        self.errors = errors
        self.data = data

    def to_dict(self):
        return self.__dict__

class InputValidationResponse(Exception):
    pass


class UnsupportedServiceName(Exception):
    pass