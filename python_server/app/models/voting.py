from mongoengine.document import Document
from mongoengine.fields import *
from errors import AlgoVotingErrorCode, AlgoVotingException
import datetime
import logging

class Voting(Document):
    start_subscription_time = DateTimeField(required=True)
    end_subscription_time = DateTimeField(required=True)
    start_voting_time = DateTimeField(required=True)
    end_voting_time = DateTimeField(required=True)
    creator = StringField(required=True)
    title = StringField(required=True)
    options = ListField(StringField(max_length=50), required=True)
    algo_id = StringField(required=True, primary_key=True)
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
            # date section
            voting.start_subscription_time = datetime.datetime.strptime(dikt['regBegin'], '%Y-%m-%d %H:%M:%S')
            voting.end_subscription_time = datetime.datetime.strptime(dikt['regEnd'], '%Y-%m-%d %H:%M:%S')
            voting.start_voting_time = datetime.datetime.strptime(dikt['voteBegin'], '%Y-%m-%d %H:%M:%S')
            voting.end_voting_time = datetime.datetime.strptime(dikt['voteEnd'], '%Y-%m-%d %H:%M:%S')

            log.debug("Voting generation from dictionary completed")
            return voting
        except KeyError as e:
            log.error("Error while parsing json, Exception: {}", e)
            raise AlgoVotingException(message='Error while parsing json', status_code=400,
                            exception_type=AlgoVotingErrorCode.INVALID_VOTING_JSON)