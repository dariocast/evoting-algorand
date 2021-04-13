# Main module for create a voting app and to cast votes

from algosdk import mnemonic, account
from algosdk.future import transaction
from algosdk.future.transaction import StateSchema
from pyteal import compileTeal, Mode

from evoting_asc import voting_clear_program, voting_approval_program
from evoting_utils import compile_program, wait_for_confirmation, get_private_key_from_mnemonic


# On creation, minimum balance increase:
# 100000 + (25000+3500)*schema.NumUint + (25000+25000)*schema.NumByteSlice
# Where schema.NumUint and schema.NumByteSlice are the amount of on-chain storage desired
def create_app(algod_client, priv_key, preferences):
    sender = account.address_from_private_key(priv_key)
    on_complete = transaction.OnComplete.NoOpOC.real
    params = algod_client.suggested_params()
    global_schema = StateSchema(num_uints=len(preferences), num_byte_slices=1)
    local_schema = StateSchema(num_uints=0, num_byte_slices=0)
    approval_program_ast = voting_approval_program(preferences)
    approval_program_teal = compileTeal(approval_program_ast, mode=Mode.Application, version=2)
    approval_program_compiled = compile_program(algod_client, approval_program_teal)
    clear_state_program_ast = voting_clear_program()
    clear_state_program_teal = compileTeal(clear_state_program_ast, mode=Mode.Application, version=2)
    clear_state_program_compiled = compile_program(algod_client, clear_state_program_teal)

    txn = transaction.ApplicationCreateTxn(
        sender,
        params,
        on_complete,
        approval_program_compiled,
        clear_state_program_compiled,
        global_schema,
        local_schema,
        app_args=preferences
    )
    signed_txn = txn.sign(priv_key)
    tx_id = signed_txn.transaction.get_txid()
    algod_client.send_transaction(signed_txn)

    wait_for_confirmation(algod_client, tx_id)

    transaction_response = algod_client.pending_transaction_info(tx_id)
    app_id = transaction_response['application-index']
    print("Created new app-id:", app_id)

    return app_id


def vote():
    pass


def main():
    # initialize an algodClient
    from scripts.utils import getAlgodClient, account_selection
    algod_client = getAlgodClient()
    creator = account_selection('creator')
    creator_private_key = creator['sk']
    # voter = account_selection('voter')
    # user_private_key = voter['sk']
    # creator_private_key = get_private_key_from_mnemonic(creator_mnemonic)

# create list of bytes for app args
    preferences = [
        'Preferenza1',
        'Preferenza2',
        'Preferenza3'
    ]

    # create new application
    app_id = create_app(algod_client, creator_private_key, preferences)


if __name__ == "__main__":
    main()
