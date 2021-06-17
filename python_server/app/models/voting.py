from mongoengine.document import Document
from mongoengine.fields import *
from errors import AlgoVotingErrorCode, AlgoVotingException
import datetime
import logging

class Voting(Document):
    created = DateTimeField(default=datetime.datetime.now)
    creator = StringField(required=True)
    title = StringField(required=True)
    options = ListField(StringField(max_length=50), required=True)
    algo_id = IntField(required=True)
    asset_id = StringField()
    description = StringField()

    @classmethod
    def from_dict(cls, dikt):
        log = logging.getLogger("{}.{}".format(__package__, __name__))
        log.debug("Voting generation from dictionary started")
        try:
            voting = Voting()
            voting.title = dikt['title']
            voting.options = dikt['options']
            voting.description = dikt['description']
            voting.asset_id = dikt['assetId']
            log.debug("Voting generation from dictionary completed")
            return voting
        except KeyError as e:
            log.error("Error while parsing json, Exception: {}", e)
            raise AlgoVotingException(message='Error while parsing json', status_code=400,
                            exception_type=AlgoVotingErrorCode.INVALID_VOTING_JSON)