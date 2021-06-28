import datetime
import json
import logging
import os
import uuid

from flask import Flask, request
from flask_mongoengine import MongoEngine

from algorand import evoting, evoting_utils
from algosdk.error import AlgodHTTPError, IndexerHTTPError
from builders.response_builder import ResponseBuilder
from errors import AlgoVotingErrorCode, AlgoVotingException
from models.voting import Voting
import adapters

log_lvl = os.environ.get('LOGGER', 'INFO')
logging.basicConfig(level=log_lvl,
                    format='%(asctime)s %(name)-12s %(levelname)-8s %(message)s',
                    datefmt='%m-%d %H:%M',
                    )

app = Flask(__name__)
app.config['MONGO_URI'] = 'mongodb://python_server_mongo_1/voting'
app.config['MONGODB_SETTINGS'] = {'host': app.config['MONGO_URI']}
db = MongoEngine()
db.init_app(app)

client = evoting.get_client()
indexer = evoting.get_indexer()

@app.route('/')
def home():
    log = logging.getLogger("{}.{}".format(__package__, __name__))
    log.debug("Homepage called")
    return 'Python Server is up and running'

# TODO Handle creation failed due to max app reached
@app.route('/voting', methods=['POST'])
def createVoting():
    log = logging.getLogger("{}.{}".format(__package__, __name__))
    log.debug("Create voting called")
    if not request.is_json:
        raise AlgoVotingException(message='Body must be a json', status_code=400,
                            exception_type=AlgoVotingErrorCode.REQUEST_NOT_JSON)
    status = client.status()
    voting_configuration = request.get_json()
    voting = Voting.from_dict(voting_configuration)
    voting.creator = evoting_utils.get_address_from_mnemonic(voting_configuration['passphrase'])
    creator_is_asset_creator = voting.creator == evoting_utils.asset_creator(indexer, voting.asset_id)
    if not creator_is_asset_creator:
        raise AlgoVotingException(
            status_code=400,
            exception_type=AlgoVotingErrorCode.ADDRESS_NOT_ASSET_CREATOR,
            message=f'Address {voting.creator} is not the creator for the asset {voting.asset_id}'
        )
    approval_program = evoting_utils.generate_approval_program(client=client, preferences=voting.options, assetId=voting.asset_id,)
    clear_state_program = evoting_utils.generate_clear_state_program(client=client)
    global_schema = evoting_utils.generate_global_schema(len(voting.options))
    local_schema = evoting_utils.generate_local_schema()
    # configure registration and voting period
    regBegin = adapters.date_to_block_time(voting.start_subscription_time, status['last-round'])
    regEnd = adapters.date_to_block_time(voting.end_subscription_time, status['last-round'])
    voteBegin = adapters.date_to_block_time(voting.start_voting_time, status['last-round'])
    voteEnd = adapters.date_to_block_time(voting.end_voting_time, status['last-round'])

    log.debug(f"Current Round: {status['last-round']}")
    log.debug(f"Registration begin time: {voting.start_subscription_time}")
    log.debug(f"Registration end time: {voting.end_subscription_time}")
    log.debug(f"Vote begin time: {voting.start_voting_time}")
    log.debug(f"Vote end time: {voting.end_voting_time}")
    log.debug(f"Registration rounds: {regBegin} to {regEnd}")
    log.debug(f"Vote rounds: {voteBegin} to {voteEnd}")

    # create list of bytes for app args
    app_args = [
        evoting_utils.intToBytes(regBegin),
        evoting_utils.intToBytes(regEnd),
        evoting_utils.intToBytes(voteBegin),
        evoting_utils.intToBytes(voteEnd)
    ]
    data_set = {"options": voting.options, "title":voting.title, "description":voting.description}
    json_dump = json.dumps(data_set)
    note = f"[voteapp][creation]{json_dump}".encode()

    algorand_app_id = evoting.create_app(
        client=client,
        private_key=evoting_utils.get_private_key_from_mnemonic(voting_configuration['passphrase']),
        approval_program=approval_program,
        clear_program=clear_state_program,
        global_schema=global_schema,
        local_schema=local_schema,
        app_args=app_args,
        note=note
        )
    voting.algo_id = str(algorand_app_id)
    voting.save()
    return ResponseBuilder(
        data=evoting_utils.prettify_voting_info(voting, indexer=indexer),
        status_code=200).build()


@app.route('/voting', methods=['GET'])
def getAllVoting():
    log = logging.getLogger("{}.{}".format(__package__, __name__))
    log.debug("Get all voting called")
    all_voting = []
    for voting in Voting.objects():
        prettified_voting = evoting_utils.prettify_voting_info(voting, indexer=indexer)
        all_voting.append(prettified_voting)
    return ResponseBuilder(
            message = "All votings reported in 'data' variable." if len(all_voting) > 0 else "No votings available",
            data=all_voting,
            status_code=200).build()

@app.route('/voting/<id>', methods=['DELETE'])
def deleteVoting(id):
    log = logging.getLogger("{}.{}".format(__package__, __name__))
    log.debug(f"Delete voting {id} called")
    passphrase = request.get_json()['passphrase']
    voting_to_delete = Voting.objects(algo_id=id).limit(1)
    if voting_to_delete.count() < 1:
        raise AlgoVotingException(status_code=404, exception_type=AlgoVotingErrorCode.VOTING_NOT_FOUND, message=f"Voting with id {id} not found")
    voting_to_delete : Voting = voting_to_delete[0]
    address = evoting_utils.get_address_from_mnemonic(passphrase)
    is_voting_owner = voting_to_delete.creator == address
    has_opted_in = evoting_utils.address_opted_in_app(indexer, address, voting_to_delete.algo_id)
    if is_voting_owner:
        log.debug(f"Address {address} is the owner of app {voting_to_delete.algo_id}")
        evoting.delete_app(
            client=client,
            private_key=evoting_utils.get_private_key_from_mnemonic(passphrase),
            index=id
        )
        voting_to_delete.delete()
    if has_opted_in:
        log.debug(f"Address {address} opted into app {voting_to_delete.algo_id}")
        evoting.clear_app(
            client=client,
            private_key=evoting_utils.get_private_key_from_mnemonic(passphrase),
            index=id
            )
    return ResponseBuilder(message=f"App {id} correctly deleted",status_code=200).build()

@app.route('/voting/<id>', methods=['GET'])
def getVoting(id):
    log = logging.getLogger("{}.{}".format(__package__, __name__))
    log.debug(f"Get voting {id} called")
    voting_to_return = Voting.objects(algo_id=id).limit(1)
    if voting_to_return.count() < 1:
        raise AlgoVotingException(status_code=404, exception_type=AlgoVotingErrorCode.VOTING_NOT_FOUND, message=f"Voting with id {id} not found")
    return ResponseBuilder(
        data=evoting_utils.prettify_voting_info(voting_to_return[0], indexer=indexer),
        message="Here you are",
        status_code=200).build()


@app.route('/algorand/register/<id>', methods=['POST'])
def register(id):
    log = logging.getLogger("{}.{}".format(__package__, __name__))
    log.debug(f"Register for {id} called")
    vote_config = request.get_json()
    voting_to_opt_in : Voting = Voting.objects(algo_id=id).limit(1)
    if voting_to_opt_in.count() < 1:
        raise AlgoVotingException(status_code=404, exception_type=AlgoVotingErrorCode.VOTING_NOT_FOUND, message=f"Voting with id {id} not found")
    voting_to_opt_in = voting_to_opt_in[0]
    if voting_to_opt_in.start_subscription_time <= datetime.datetime.now() <= voting_to_opt_in.end_subscription_time:
        passphrase = vote_config['passphrase']
        try:
            evoting.opt_in_app(
            client=client,
            private_key=evoting_utils.get_private_key_from_mnemonic(passphrase),
            index=id)
            return ResponseBuilder(message="Opted into app correctly",status_code=200).build()
        except AlgodHTTPError as e:
            #  TODO fare json.loads(str(e))
            return ResponseBuilder(message=json.loads(str(e))['message'], exception=e).build()
    else:
        raise AlgoVotingException(
            status_code=400,
            exception_type=AlgoVotingErrorCode.REGISTRATION_CLOSED,
            message=f"Registration is already closed or has not been opened yet. Start date: {voting_to_opt_in.start_subscription_time}, end date: {voting_to_opt_in.end_subscription_time}"
        )


@app.route('/algorand/vote/<id>', methods=['POST'])
def vote(id):
    log = logging.getLogger("{}.{}".format(__package__, __name__))
    log.debug(f"Vote for {id} called")
    vote_config = request.get_json()
    passphrase = vote_config['passphrase']
    choice : str = vote_config['choice']
    # voting : Voting = Voting.objects(algo_id=str(id))[0]
    voting : Voting = Voting.objects(algo_id=id).limit(1)
    if voting.count() < 1:
        raise AlgoVotingException(status_code=404, exception_type=AlgoVotingErrorCode.VOTING_NOT_FOUND, message=f"Voting with id {id} not found")
    voting = voting[0]
    address = evoting_utils.get_address_from_mnemonic(passphrase)
    if voting.start_voting_time <= datetime.datetime.now() <= voting.end_voting_time:
        address_holds_spending_token = evoting_utils.address_holds_asset(
            indexer=indexer,
            address=address,
            id=voting.asset_id)
        if not address_holds_spending_token:
            raise AlgoVotingException(
                status_code=400,
                exception_type=AlgoVotingErrorCode.RIGHT_TO_VOTE_REQUIRED,
                message=f"Address {address} does not have right to vote. Token {voting.asset_id} is required"
            )
        # Check per vedere se ha votato già (il teal cmq lo impedirebbe)
        local_state = evoting.read_local_state(client,address, int(id))
        log.debug(local_state)
        if "voted" in local_state:
            log.debug(f'{address} already voted for {id}')
            raise AlgoVotingException(
                status_code=400,
                exception_type=AlgoVotingErrorCode.ALREADY_VOTED,
                message=f"Address has already voted"
            )
        try:
            evoting.call_app(
                client=client,
                private_key=evoting_utils.get_private_key_from_mnemonic(passphrase),
                index=id,
                creator_address=voting.creator,
                app_args=[b'vote', choice.encode()],
                assetId=int(voting.asset_id)
            )
            to_return = evoting.read_local_state(client, evoting_utils.get_address_from_mnemonic(passphrase), int(id))
            return ResponseBuilder(data=to_return,message="Thank you. Your vote counts!",status_code=200).build()
        except Exception as e:
            return ResponseBuilder(exception=e,status_code=400).build()
    else:
        raise AlgoVotingException(
            status_code=400,
            exception_type=AlgoVotingErrorCode.VOTING_CLOSED,
            message=f"Voting is already closed or has not been opened yet. Start date: {voting.start_voting_time}, end date: {voting.end_voting_time}"
        )


@app.route('/voting/state/<id>', methods=['GET'])
def voting_global_state(id):
    log = logging.getLogger("{}.{}".format(__package__, __name__))
    log.debug("Read evoting global state called")    
    global_state = evoting.read_global_state(client, id)
    log.debug(f"Global state for {id}: {global_state}")
    return ResponseBuilder(
        data=global_state,
        status_code=200).build()


@app.route('/voting/state/<id>/<address>', methods=['GET'])
def registry_local_state(id, address):
    log = logging.getLogger("{}.{}".format(__package__, __name__))
    log.debug(f"Read evoting local state for address {address} called")    
    has_opted_in = evoting_utils.address_opted_in_app(indexer, address, id)
    if not has_opted_in:
        raise AlgoVotingException(
            status_code=400,
            exception_type=AlgoVotingErrorCode.REGISTRATION_REQUIRED,
            message=f"Address {address} need to register for the voting to have a state for that voting"
        )
    local_state = evoting.read_local_state(client, address, int(id))
    log.debug(f"{id} Local state: {local_state}")
    return ResponseBuilder(
        data=local_state,
        status_code=200).build()

@app.errorhandler(AlgoVotingException)
def handle_exception(e: AlgoVotingException):
    try:
        status_code = e.code if e.code else 400
    except:
        status_code = 500

    response = ResponseBuilder(e.message, status_code=status_code, exception=e, errors=e.exception_type.name)
    return response.build()


@app.errorhandler(AlgodHTTPError)
def handle_exception(e: AlgodHTTPError):
    try:
        status_code = e.code if e.code else 400
    except:
        status_code = 500
    
    response = ResponseBuilder(message=json.loads(str(e))['message'], exception=e)
    return response.build()

@app.errorhandler(IndexerHTTPError)
def handle_exception(e: IndexerHTTPError):
    try:
        status_code = e.code if e.code else 400
    except:
        status_code = 500
    
    response = ResponseBuilder(message=json.loads(str(e))['message'], exception=e)
    return response.build()


if __name__ == '__main__':
    app.run(host="0.0.0.0")
