from enum import Enum


class AlgoVotingErrorCode(Enum):
    GENERIC_ERROR = -1,
    REQUEST_NOT_JSON = 1,
    INVALID_VOTING_JSON = 2,
    INVALID_DATE = 3,
    REGISTRATION_CLOSED = 4,
    VOTING_CLOSED = 5,
    VOTING_NOT_FOUND = 6,
    RIGHT_TO_VOTE_REQUIRED = 7,
    ADDRESS_NOT_ASSET_CREATOR = 8,

    @staticmethod
    def getErrorCodeListToString(list):
        str1 = ""
        for ele in list:
            str1 += " " + str(ele.value) + "(" + ele.name + ")"
        return str1

class AlgoVotingException(Exception):
    def __init__(self, status_code: int, exception_type: AlgoVotingErrorCode = AlgoVotingErrorCode.GENERIC_ERROR, message: str = "",
                 data=None):
        if data is None:
            data = {}
        self.code = status_code
        self.exception_type = exception_type
        self.message = message
        self.data = data

    def to_dict(self):
        return self.__dict__

class InputValidationResponse(Exception):
    pass


class UnsupportedServiceName(Exception):
    pass