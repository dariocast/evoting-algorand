import json
import logging
import os

from flask import Flask, request
from flask_mongoengine import MongoEngine

from algorand import evoting, evoting_utils
from builders.response_builder import ResponseBuilder
from errors import AlgoVotingErrorCode, AlgoVotingException
from models.voting import Voting

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


@app.route('/')
def home():
    log = logging.getLogger("{}.{}".format(__package__, __name__))
    log.debug("Homepage called")
    return 'Python Server is up and running'

@app.route('/voting', methods=['POST'])
def createVoting():
    log = logging.getLogger("{}.{}".format(__package__, __name__))
    log.debug("Create voting called")
    if not request.is_json:
        raise AlgoVotingException(message='Body must be a json', status_code=400,
                            exception_type=AlgoVotingErrorCode.REQUEST_NOT_JSON)
    try:
        voting_configuration = request.get_json()
        voting = Voting.from_dict(voting_configuration)
        approval_program = evoting_utils.generate_approval_program(client=client, preferences=voting.options, assetId=voting.asset_id,)
        clear_state_program = evoting_utils.generate_clear_state_program(client=client)
        global_schema = evoting_utils.generate_global_schema(len(voting.options))
        local_schema = evoting_utils.generate_local_schema()
        # configure registration and voting period
        status = client.status()
        regBegin = status['last-round'] + 1
        regEnd = regBegin + 100
        voteBegin = regEnd + 1
        voteEnd = voteBegin + 100

        log.info(f"Registration rounds: {regBegin} to {regEnd}")
        log.info(f"Vote rounds: {voteBegin} to {voteEnd}")

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
        voting.creator = evoting_utils.get_address_from_mnemonic(voting_configuration['passphrase'])
        voting.algo_id = algorand_app_id
        voting.save()
        return ResponseBuilder(
            data={'created': voting.created, 'algo_id': voting.algo_id, 'creator': voting.creator},
            status_code=200).build()
    except AlgoVotingException as e:
        log.error("Raised exception in Create Voting")
        raise e


@app.route('/voting', methods=['GET'])
def getAllVoting():
    log = logging.getLogger("{}.{}".format(__package__, __name__))
    log.debug("Get all voting called")
    all_voting = []
    for voting in Voting.objects:
        all_voting.append(voting.to_json())
    return ResponseBuilder(
            data=all_voting,
            status_code=200).build()

@app.route('/voting/<id>', methods=['DELETE'])
def deleteVoting(id):
    log = logging.getLogger("{}.{}".format(__package__, __name__))
    log.debug(f"Delete voting {id} called")
    pass

@app.route('/voting/<id>', methods=['GET'])
def getVoting(id):
    log = logging.getLogger("{}.{}".format(__package__, __name__))
    log.debug(f"Get voting {id} called")
    pass

@app.errorhandler(AlgoVotingException)
def handle_door_exception(e: AlgoVotingException):
    try:
        status_code = e.code if e.code else 500
    except:
        status_code = 500

    response = ResponseBuilder(e.message, status_code=status_code, exception=e, errors=e.exception_type.name)
    return response.build()

if __name__ == '__main__':
    app.run(host="0.0.0.0")
