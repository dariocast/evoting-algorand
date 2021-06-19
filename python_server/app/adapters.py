import datetime

from errors import AlgoVotingErrorCode, AlgoVotingException

# Average time for block generation
MEAN_TIME_FOR_BLOCK_GENERATION_IN_SECOND = 4.5

def date_to_block_time(date, last_round):
    duration = (date - datetime.datetime.now()).total_seconds()
    if duration <= 0:
        raise AlgoVotingException(status_code=400, exception_type=AlgoVotingErrorCode.INVALID_DATE, message=f"Something gone wrong with date selection. Date {date} is previous than now")
    date_as_round = round(duration/MEAN_TIME_FOR_BLOCK_GENERATION_IN_SECOND)
    return last_round + date_as_round