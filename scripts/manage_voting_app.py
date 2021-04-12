import base64
from algosdk.future import transaction
from algosdk.future.transaction import ApplicationCallTxn, StateSchema
import utils


def app_opt_in():
    pass


def app_creation():
    creator = utils.account_selection('creator')
    client = utils.getAlgodClient()
    params = client.suggested_params()
    
    # Dichiaro parametri
    on_complete = transaction.OnComplete.NoOpOC.real
    file = open('../utility/TEAL/voting_app.teal',mode='r')
    source_code = file.read()
    file.close()
    compile_response = client.compile(source_code.decode('utf-8'))
    approval_program = base64.b64decode(compile_response['result'])
    file = open('../utility/TEAL/voting_app_clear.teal',mode='r')
    source_code = file.read()
    file.close()
    compile_response = client.compile(source_code.decode('utf-8'))
    clear_state_program = base64.b64decode(compile_response['result'])
    
    # schemi per i dati globali e locali
    global_schema = StateSchema(num_uints=6, num_byte_slices=1)
    local_schema = StateSchema(num_uints=0, num_byte_slices=1)

    # args per le variabili globali
    app_args = [
        "int:1".encode("utf-8"),
        "int:20".encode("utf-8"),
        "int:20".encode("utf-8"),
        "int:100".encode("utf-8"),
    ]

    txn = ApplicationCallTxn(
        sender=creator['pk'],
        sp=params,
        on_complete=on_complete,
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
    app_id = input("Type asset ID to destroy: ")
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
        0 : create_asset,
        1 : opt_in_to_asset,
        2 : opt_out_from_asset,
        3 : send_to,
        4 : destroy_all_units,
        5 : check_holdings,
    }

    cmd = input("type a command: ")
    options[int(cmd)]()


if __name__ == "__main__":
    main()
