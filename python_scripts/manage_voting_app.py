import base64
from posixpath import dirname
from algosdk.future import transaction
from algosdk.future.transaction import ApplicationCallTxn, ApplicationCreateTxn, ApplicationNoOpTxn, AssetTransferTxn, StateSchema, Transaction, assign_group_id
import utils


def app_opt_in():
    # declare sender
    sender_account = utils.account_selection('sender')
    sender = sender_account['pk']
    index = input(f"Enter app ID: ")

    print("OptIn from account: ",sender)
    client = utils.getAlgodClient()

	# get node suggested parameters
    params = client.suggested_params()
    # comment out the next two (2) lines to use suggested fees
    params.flat_fee = True
    params.fee = 1000

    # create unsigned transaction
    txn = transaction.ApplicationOptInTxn(sender, params, index)

    # sign transaction
    signed_txn = txn.sign(sender_account['sk'])
    tx_id = signed_txn.transaction.get_txid()

    # send transaction
    client.send_transactions([signed_txn])

    # await confirmation
    utils.wait_for_confirmation(client, tx_id)

    # display results
    transaction_response = client.pending_transaction_info(tx_id)
    print("OptIn to app-id:", transaction_response['txn']['txn']['apid'])


def app_creation():
    creator = utils.account_selection('creator')
    client = utils.getAlgodClient()
    params = client.suggested_params()
    preferences = input(f"Enter the options:")
    preferences = preferences.split(' ')
    assert len(preferences) >= 2
    assetID = input(f"Enter asset ID: ")

    firstOptionTemplate = "txna ApplicationArgs 1\nbyte \"OPTION\"\n==\n"
    optionTextTemplate = "txna ApplicationArgs 1\nbyte \"OPTION\"\n==\n||\n";

    options = firstOptionTemplate.replace("OPTION", preferences[0])
    for preference in preferences:
        if preference == preferences[0]:
            continue
        option = optionTextTemplate.replace("OPTION", preference)
        options = options+option

    # Dichiaro parametri
    on_complete = transaction.OnComplete.NoOpOC.real
    file = open(dirname(__file__)+'/utility/TEAL/flutterapp_vote_approval.teal',mode='rb')
    source_code = file.read()
    file.close()
    source_code = source_code.decode("utf-8")
    source_code = source_code.replace("ASSET_ID", assetID)
    source_code = source_code.replace("OPTIONS_PLACEHOLDER", options)
    compile_response = client.compile(source_code)
    approval_program = base64.b64decode(compile_response['result'])
    file = open(dirname(__file__)+'/utility/TEAL/flutterapp_vote_clear_state.teal',mode='rb')
    source_code = file.read()
    file.close()
    compile_response = client.compile(source_code.decode("utf-8"))
    clear_state_program = base64.b64decode(compile_response['result'])
    
    # schemi per i dati globali e locali
    global_schema = StateSchema(num_uints=6, num_byte_slices=1)
    local_schema = StateSchema(num_uints=0, num_byte_slices=1)

    # configure registration and voting period
    status = client.status()
    regBegin = status['last-round'] + 10
    regEnd = regBegin + 10
    voteBegin = regEnd + 1
    voteEnd = voteBegin + 10

    # create list of bytes for app args
    app_args = [
        utils.intToBytes(regBegin),
        utils.intToBytes(regEnd),
        utils.intToBytes(voteBegin),
        utils.intToBytes(voteEnd)
    ]

    txn = ApplicationCreateTxn(
        sender=creator['pk'],
        sp=params,
        on_complete=on_complete,
        global_schema=global_schema,
        local_schema=local_schema,
        approval_program=approval_program,
        clear_program=clear_state_program,
        app_args=app_args
    )
    # sign transaction
    signed_txn = txn.sign(creator['sk'])
    tx_id = signed_txn.transaction.get_txid()

    # send transaction
    client.send_transactions([signed_txn])

    # await confirmation
    utils.wait_for_confirmation(client, tx_id)

    # display results
    transaction_response = client.pending_transaction_info(tx_id)
    app_id = transaction_response['application-index']
    print("Voting app created with ID: ",app_id)    

def app_vote():
    voter = utils.account_selection('voter')
    creator = utils.account_selection('creator')
    client = utils.getAlgodClient()
    params = client.suggested_params()
    appID = input(f"Enter app ID: ")
    assetID = input(f"Enter asset ID: ")
    appcall_txn = ApplicationNoOpTxn(
        sender=voter['pk'],
        sp=params,
        index=appID,
        app_args=[b'vote', b'pref2']
    )
    axfer_txn = AssetTransferTxn(
        sender=voter['pk'],
        sp=params,
        receiver=creator['pk'],
        amt=1,
        index=assetID,
    )
    # assign group id
    gid = transaction.calculate_group_id([appcall_txn, axfer_txn])
    appcall_txn.group = gid
    axfer_txn.group = gid
    # sign transactions
    signed_txn_appcall = appcall_txn.sign(voter['sk'])
    signed_txn_axfer = axfer_txn.sign(voter['sk'])
    # combine
    signed_group = [signed_txn_appcall, signed_txn_axfer]

    # send transaction
    tx_id = client.send_transactions(signed_group)

    # await confirmation
    utils.wait_for_confirmation(client, tx_id)

    # display results
    transaction_response = client.pending_transaction_info(tx_id)
    print("Vote expressed correctly",)    



def app_opt_out():
    pass


def app_read_state():
    pass


def app_delete():
    manager = utils.account_selection('manager')
    app_id = input("Type app ID to destroy: ")
    try:
        app_id = int(app_id)
    except:
        print("Entered value MUST be integer!")

    client = utils.getAlgodClient()
    params = client.suggested_params()

    txn = transaction.ApplicationDeleteTxn(
        manager['pk'],
        params,
        app_id)

    signed_txn = txn.sign(manager['sk'])
    tx_id = signed_txn.transaction.get_txid()

    # send transaction
    client.send_transactions([signed_txn])

    # await confirmation
    utils.wait_for_confirmation(client, tx_id)


    # display results
    transaction_response = client.pending_transaction_info(tx_id)
    print("Deleted app-id: ",transaction_response['txn']['txn']['apid'])  


def main():
    options = {
        0 : app_creation,
        1 : app_opt_in,
        2 : app_opt_out,
        3 : app_delete,
        4 : app_vote,
        5 : app_read_state,
    }

    cmd = input("type a command: ")
    options[int(cmd)]()


if __name__ == "__main__":
    main()
