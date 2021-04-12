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

    # create unsigned transaction
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

    # await confirmation
    wait_for_confirmation(algod_client, tx_id)

    # display results
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

    # # read global state of application
    # print("Global state:", read_global_state(algod_client, account.address_from_private_key(creator_private_key), app_id))
    #
    # # wait for registration period to start
    # wait_for_round(algod_client, regBegin)
    #
    # # opt-in to application
    # opt_in_app(algod_client, user_private_key, app_id)
    #
    # wait_for_round(algod_client, voteBegin)
    #
    # # call application without arguments
    # call_app(algod_client, user_private_key, app_id, [b'vote', b'choiceA'])
    #
    # # read local state of application from user account
    # print("Local state:", read_local_state(algod_client, account.address_from_private_key(user_private_key), app_id))
    #
    # # wait for registration period to start
    # wait_for_round(algod_client, voteEnd)
    #
    # # read global state of application
    # global_state = read_global_state(algod_client, account.address_from_private_key(creator_private_key), app_id)
    # print("Global state:", global_state)
    #
    # max_votes = 0
    # max_votes_choice = None
    # for key,value in global_state.items():
    #     if key not in ('RegBegin', 'RegEnd', 'VoteBegin', 'VoteEnd', 'Creator') and isinstance(value, int):
    #         if value > max_votes:
    #             max_votes = value
    #             max_votes_choice = key
    #
    # print("The winner is:", max_votes_choice)
    #
    # # delete application
    # delete_app(algod_client, creator_private_key, app_id)
    #
    # # clear application from user account
    # clear_app(algod_client, user_private_key, app_id)


if __name__ == "__main__":
    main()
