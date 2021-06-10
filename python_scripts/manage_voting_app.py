import base64
from posixpath import dirname
from algosdk.future import transaction
from algosdk.future.transaction import ApplicationCallTxn, ApplicationCreateTxn, StateSchema
import utils


def app_opt_in():
    pass


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
    # args per le variabili globali
    app_args = [
        "14696170".encode("utf-8"),
        "14740000".encode("utf-8"),
        "14740000".encode("utf-8"),
        "14896170".encode("utf-8"),
    ]
    app_args_forse_buone = [
        (14696170).to_bytes(length=4, byteorder='big'),
        (14740000).to_bytes(length=4, byteorder='big'),
        (14740000).to_bytes(length=4, byteorder='big'),
        (14896170).to_bytes(length=4, byteorder='big'),
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
    pass


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
