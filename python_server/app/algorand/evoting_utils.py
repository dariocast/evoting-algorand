import base64
import os

from algosdk import mnemonic
from algosdk.future import transaction

# helper function to compile program source
def compile_program(client, source_code):
    compile_response = client.compile(source_code)
    return base64.b64decode(compile_response['result'])

# helper function that converts a mnemonic passphrase into a private signing key
def get_private_key_from_mnemonic(mn):
    private_key = mnemonic.to_private_key(mn)
    return private_key

# helper function that convert a mnemonic passphrase into a public key = address
def get_address_from_mnemonic(mn):
    address = mnemonic.to_public_key(mn)
    return address

# helper function that waits for a given txid to be confirmed by the network
def wait_for_confirmation(client, txid):
    last_round = client.status().get('last-round')
    txinfo = client.pending_transaction_info(txid)
    while not (txinfo.get('confirmed-round') and txinfo.get('confirmed-round') > 0):
        print("Waiting for confirmation...")
        last_round += 1
        client.status_after_block(last_round)
        txinfo = client.pending_transaction_info(txid)
    print("Transaction {} confirmed in round {}.".format(txid, txinfo.get('confirmed-round')))
    return txinfo

# helper function that waits for a given round
def wait_for_round(client, round):
    last_round = client.status().get('last-round')
    print(f"Waiting for round {round}")
    while last_round < round:
        last_round += 1
        client.status_after_block(last_round)
        print(f"Round {last_round}")

# helper function that format an algorand asc1 local state
def format_state(state):
    formatted = {}
    for item in state:
        key = item['key']
        value = item['value']
        formatted_key = base64.b64decode(key).decode('utf-8')
        if value['type'] == 1:
            # byte string
            if formatted_key == 'voted':
                formatted_value = base64.b64decode(value['bytes']).decode('utf-8')
            else:
                formatted_value = value['bytes']
            formatted[formatted_key] = formatted_value
        else:
            # integer
            formatted[formatted_key] = value['uint']
    return formatted

# convert 64 bit integer i to byte string
def intToBytes(i):
    return i.to_bytes(8, "big")

# helper function that prepare the teal programs
def generate_approval_program(client, preferences, assetId):
    firstOptionTemplate = "txna ApplicationArgs 1\nbyte \"OPTION\"\n==\n"
    optionTextTemplate = "txna ApplicationArgs 1\nbyte \"OPTION\"\n==\n||\n";

    options = firstOptionTemplate.replace("OPTION", preferences[0])
    for preference in preferences:
        if preference == preferences[0]:
            continue
        option = optionTextTemplate.replace("OPTION", preference)
        options = options+option

    file = open(os.path.dirname(__file__)+'/teal/flutterapp_vote_approval.teal',mode='rb')
    source_code = file.read()
    file.close()
    source_code = source_code.decode("utf-8")
    source_code = source_code.replace("ASSET_ID", str(assetId))
    source_code = source_code.replace("OPTIONS_PLACEHOLDER", options)
    compile_response = client.compile(source_code)
    approval_program = base64.b64decode(compile_response['result'])
    return approval_program

def generate_clear_state_program(client):
    file = open(os.path.dirname(__file__)+'/teal/flutterapp_vote_clear_state.teal',mode='rb')
    source_code = file.read()
    file.close()
    compile_response = client.compile(source_code.decode("utf-8"))
    clear_state_program = base64.b64decode(compile_response['result'])
    return clear_state_program

def generate_global_schema(n_options: int):
    # declare application state storage (immutable)
    global_ints = 4 + n_options # 4 for setup + 6 for choices. Use a larger number for more choices.
    global_bytes = 1
    global_schema = transaction.StateSchema(global_ints, global_bytes)
    return global_schema
    
def generate_local_schema():
    # declare application state storage (immutable)
    local_ints = 1
    local_bytes = 0
    local_schema = transaction.StateSchema(local_ints, local_bytes)
    return local_schema