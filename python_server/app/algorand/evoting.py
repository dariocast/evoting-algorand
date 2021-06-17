import base64
import json
import logging
from posixpath import dirname
import os


from algosdk.future import transaction
from algosdk import account
from algosdk.v2client import algod

from algorand import evoting_utils

# user declared algod connection parameters. Node must have EnableDeveloperAPI set to true in its config
algod_address = "https://testnet-algorand.api.purestake.io/ps2"
algod_token = "6ouFHKmlgF57UkOUz9eDZ1XTN7iZU9Fo2LxhxhBX"

# initialize and return a valid algodClient
def get_client():
    headers = {
            "X-API-Key": algod_token,
        }
    algod_client = algod.AlgodClient(algod_token, algod_address, headers)
    return algod_client

# create new application
def create_app(client, private_key, approval_program, clear_program, global_schema, local_schema, app_args, note):
    log = logging.getLogger("{}.{}".format(__package__, __name__))
    log.debug("Creating app on algorand")
    # define sender as creator
    sender = account.address_from_private_key(private_key)

    # declare on_complete as NoOp
    on_complete = transaction.OnComplete.NoOpOC.real

	# get node suggested parameters
    params = client.suggested_params()
    # comment out the next two (2) lines to use suggested fees
    params.flat_fee = True
    params.fee = 1000

    # create unsigned transaction
    txn = transaction.ApplicationCreateTxn(sender, params, on_complete, \
                                            approval_program, clear_program, \
                                            global_schema, local_schema, app_args,
                                            note=note)

    # sign transaction
    signed_txn = txn.sign(private_key)
    tx_id = signed_txn.transaction.get_txid()

    # send transaction
    client.send_transactions([signed_txn])

    # await confirmation
    evoting_utils.wait_for_confirmation(client, tx_id)

    # display results
    transaction_response = client.pending_transaction_info(tx_id)
    app_id = transaction_response['application-index']
    log.debug(f"Created new app-id: {app_id}")

    return app_id

# opt-in to application
def opt_in_app(client, private_key, index):
    log = logging.getLogger("{}.{}".format(__package__, __name__))
    log.debug("Opting into app on algorand")
    # declare sender
    sender = account.address_from_private_key(private_key)
    log.debug(f"OptIn from account: {sender}")

	# get node suggested parameters
    params = client.suggested_params()
    # comment out the next two (2) lines to use suggested fees
    params.flat_fee = True
    params.fee = 1000

    # create unsigned transaction
    txn = transaction.ApplicationOptInTxn(sender, params, index, [b'register'])

    # sign transaction
    signed_txn = txn.sign(private_key)
    tx_id = signed_txn.transaction.get_txid()

    # send transaction
    client.send_transactions([signed_txn])

    # await confirmation
    evoting_utils.wait_for_confirmation(client, tx_id)

    # display results
    transaction_response = client.pending_transaction_info(tx_id)
    log.debug(f"OptIn to app-id: {transaction_response['txn']['txn']['apid']}")    

# call application
def call_app(client: algod.AlgodClient, private_key, creator_address, index,  app_args, assetId):
    log = logging.getLogger("{}.{}".format(__package__, __name__))
    log.debug("Calling app on algorand")

    # declare sender
    sender = account.address_from_private_key(private_key)
    log.debug(f"Call from account: {sender}")

	# get node suggested parameters
    params = client.suggested_params()
    # comment out the next two (2) lines to use suggested fees
    params.flat_fee = True
    params.fee = 1000

    # create unsigned transaction
    appcall_txn = transaction.ApplicationNoOpTxn(sender, params, index, app_args)

    axfer_txn = transaction.AssetTransferTxn(
        sender=sender,
        sp=params,
        receiver=creator_address,
        amt=1,
        index=assetId,
    )
    
    # assign group id
    log.debug("Grouping transactions...")
    group_id = transaction.calculate_group_id([appcall_txn, axfer_txn])
    log.debug(f"...computed groupId: {group_id}")
    appcall_txn.group = group_id
    axfer_txn.group = group_id
    # sign transactions
    log.debug("Signing transactions...")
    signed_txn_appcall = appcall_txn.sign(private_key)
    log.debug(f"...account1 signed txn_1: {signed_txn_appcall.get_txid()}")
    signed_txn_axfer = axfer_txn.sign(private_key)
    log.debug(f"...account2 signed txn_2: {signed_txn_axfer.get_txid()}")

    # combine
    log.debug("Assembling transaction group...")
    signed_group = [signed_txn_appcall, signed_txn_axfer]

    # send transaction
    print("Sending transaction group...")
    tx_id = client.send_transactions(signed_group)

    # await confirmation
    evoting_utils.wait_for_confirmation(client, tx_id)

# read user local state
def read_local_state(client, addr, app_id):
    results = client.account_info(addr)
    for local_state in results['apps-local-state']:
        if local_state['id'] == app_id:
            if 'key-value' not in local_state:
                return {}
            return evoting_utils.format_state(local_state['key-value'])
    return {}

# read app global state
def read_global_state(client, addr, app_id):
    results = client.account_info(addr)
    apps_created = results['created-apps']
    for app in apps_created:
        if app['id'] == app_id:
            return evoting_utils.format_state(app['params']['global-state'])
    return {}

# delete application
def delete_app(client, private_key, index):
    log = logging.getLogger("{}.{}".format(__package__, __name__))
    log.debug("Deleting app on algorand")
    # declare sender
    sender = account.address_from_private_key(private_key)

	# get node suggested parameters
    params = client.suggested_params()
    # comment out the next two (2) lines to use suggested fees
    params.flat_fee = True
    params.fee = 1000

    # create unsigned transaction
    txn = transaction.ApplicationDeleteTxn(sender, params, index)

    # sign transaction
    signed_txn = txn.sign(private_key)
    tx_id = signed_txn.transaction.get_txid()

    # send transaction
    client.send_transactions([signed_txn])

    # await confirmation
    evoting_utils.wait_for_confirmation(client, tx_id)

    # display results
    transaction_response = client.pending_transaction_info(tx_id)
    log.debug(f"Deleted app-id:{transaction_response['txn']['txn']['apid']}")    

# close out from application
def close_out_app(client, private_key, index):
    log = logging.getLogger("{}.{}".format(__package__, __name__))
    log.debug("Closing out app on algorand")
    # declare sender
    sender = account.address_from_private_key(private_key)

	# get node suggested parameters
    params = client.suggested_params()
    # comment out the next two (2) lines to use suggested fees
    params.flat_fee = True
    params.fee = 1000

    # create unsigned transaction
    txn = transaction.ApplicationCloseOutTxn(sender, params, index)

    # sign transaction
    signed_txn = txn.sign(private_key)
    tx_id = signed_txn.transaction.get_txid()

    # send transaction
    client.send_transactions([signed_txn])

    # await confirmation
    evoting_utils.wait_for_confirmation(client, tx_id)

    # display results
    transaction_response = client.pending_transaction_info(tx_id)
    log.debug(f"Closed out from app-id: {transaction_response['txn']['txn']['apid']}")

# clear application
def clear_app(client, private_key, index):
    log = logging.getLogger("{}.{}".format(__package__, __name__))
    log.debug("Clearing state of app on algorand")
    # declare sender
    sender = account.address_from_private_key(private_key)

	# get node suggested parameters
    params = client.suggested_params()
    # comment out the next two (2) lines to use suggested fees
    params.flat_fee = True
    params.fee = 1000

    # create unsigned transaction
    txn = transaction.ApplicationClearStateTxn(sender, params, index)

    # sign transaction
    signed_txn = txn.sign(private_key)
    tx_id = signed_txn.transaction.get_txid()

    # send transaction
    client.send_transactions([signed_txn])

    # await confirmation
    evoting_utils.wait_for_confirmation(client, tx_id)

    # display results
    transaction_response = client.pending_transaction_info(tx_id)
    log.debug(f"Cleared app-id: {transaction_response['txn']['txn']['apid']}")    

def main():
    # initialize an algodClient
    headers = {
            "X-API-Key": algod_token,
        }
    algod_client = algod.AlgodClient(algod_token, algod_address, headers)


    # define private keys
    creator_private_key = evoting_utils.get_private_key_from_mnemonic(creator_mnemonic)
    creator_address = evoting_utils.get_address_from_mnemonic(creator_mnemonic)
    user_private_key = evoting_utils.get_private_key_from_mnemonic(user_mnemonic)

    # declare application state storage (immutable)
    local_ints = 1
    local_bytes = 0
    global_ints = 10 # 4 for setup + 6 for choices. Use a larger number for more choices.
    global_bytes = 1
    global_schema = transaction.StateSchema(global_ints, global_bytes)
    local_schema = transaction.StateSchema(local_ints, local_bytes)

    # # get PyTeal approval program
    # approval_program_ast = approval_program()
    # # compile program to TEAL assembly
    # approval_program_teal = compileTeal(approval_program_ast, mode=Mode.Application, version=2)
    # # compile program to binary
    # approval_program_compiled = compile_program(algod_client, approval_program_teal)

    # # get PyTeal clear state program
    # clear_state_program_ast = clear_state_program()
    # # compile program to TEAL assembly
    # clear_state_program_teal = compileTeal(clear_state_program_ast, mode=Mode.Application, version=2)
    # # compile program to binary
    # clear_state_program_compiled = compile_program(algod_client, clear_state_program_teal)

    firstOptionTemplate = "txna ApplicationArgs 1\nbyte \"OPTION\"\n==\n"
    optionTextTemplate = "txna ApplicationArgs 1\nbyte \"OPTION\"\n==\n||\n";

    options = firstOptionTemplate.replace("OPTION", preferences[0])
    for preference in preferences:
        if preference == preferences[0]:
            continue
        option = optionTextTemplate.replace("OPTION", preference)
        options = options+option

    file = open(os.path.dirname(__file__)+'/utility/TEAL/flutterapp_vote_approval.teal',mode='rb')
    source_code = file.read()
    file.close()
    source_code = source_code.decode("utf-8")
    source_code = source_code.replace("ASSET_ID", str(assetID))
    source_code = source_code.replace("OPTIONS_PLACEHOLDER", options)
    compile_response = algod_client.compile(source_code)
    approval_program = base64.b64decode(compile_response['result'])
    file = open(os.path.dirname(__file__)+'/utility/TEAL/flutterapp_vote_clear_state.teal',mode='rb')
    source_code = file.read()
    file.close()
    compile_response = algod_client.compile(source_code.decode("utf-8"))
    clear_state_program = base64.b64decode(compile_response['result'])

    # configure registration and voting period
    status = algod_client.status()
    regBegin = status['last-round'] + 1
    regEnd = regBegin + 5
    voteBegin = regEnd + 1
    voteEnd = voteBegin + 5

    print(f"Registration rounds: {regBegin} to {regEnd}")
    print(f"Vote rounds: {voteBegin} to {voteEnd}")

    # create list of bytes for app args
    app_args = [
        evoting_utils.intToBytes(regBegin),
        evoting_utils.intToBytes(regEnd),
        evoting_utils.intToBytes(voteBegin),
        evoting_utils.intToBytes(voteEnd)
    ]

    data_set = {"options": preferences, "title":"TITOLO VOTAZIONE", "description":"DESCRIZIONE VOTAZIONE"}
    json_dump = json.dumps(data_set)
    note = f"[voteapp][creation]{json_dump}".encode()
    # create new application
    app_id = create_app(algod_client, creator_private_key, approval_program, clear_state_program, global_schema, local_schema, app_args, note)
    # read global state of application
    print("Global state:", read_global_state(algod_client, account.address_from_private_key(creator_private_key), app_id))

    # wait for registration period to start
    evoting_utils.wait_for_round(algod_client, regBegin)

    # opt-in to application
    opt_in_app(algod_client, user_private_key, app_id)

    evoting_utils.wait_for_round(algod_client, voteBegin)

    # call application without arguments
    call_app(
        client=algod_client,
        private_key=user_private_key, 
        creator_address=creator_address, 
        index=app_id, 
        app_args=[b'vote', b'choiceA']
        )

    # read local state of application from user account
    print("Local state:", read_local_state(algod_client, account.address_from_private_key(user_private_key), app_id))

    # wait for registration period to start
    evoting_utils.wait_for_round(algod_client, voteEnd)

    # read global state of application
    global_state = read_global_state(algod_client, account.address_from_private_key(creator_private_key), app_id)
    print("Global state:", global_state)

    max_votes = 0
    max_votes_choice = None
    for key,value in global_state.items():
        if key not in ('RegBegin', 'RegEnd', 'VoteBegin', 'VoteEnd', 'Creator') and isinstance(value, int):
            if value > max_votes:
                max_votes = value
                max_votes_choice = key
    
    print("The winner is:", max_votes_choice)

    # delete application
    delete_app(algod_client, creator_private_key, app_id)

    # clear application from user account
    clear_app(algod_client, user_private_key, app_id)

if __name__ == "__main__":
    main()