import base64
import json
import logging
from posixpath import dirname
import os


from algosdk.future import transaction
from algosdk import account
from algosdk.v2client import algod, indexer

from algorand import evoting_utils

# user declared algod connection parameters. Node must have EnableDeveloperAPI set to true in its config
algod_address = "https://testnet-algorand.api.purestake.io/ps2"
algod_token = "6ouFHKmlgF57UkOUz9eDZ1XTN7iZU9Fo2LxhxhBX"

indexer_address = "https://testnet-algorand.api.purestake.io/idx2"

# initialize and return a valid indexerClient
def get_indexer() -> indexer.IndexerClient:
    headers = {
            "X-API-Key": algod_token,
        }
    indexer_client = indexer.IndexerClient("", indexer_address, headers)
    return indexer_client

# initialize and return a valid algodClient
def get_client() -> algod.AlgodClient:
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
    log.debug("Sending transaction group...")
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

# read app global state
def read_global_state(client, app_id):
    app = client.application_info(app_id)
    # return evoting_utils.format_state(app['params']['global-state'])
    return evoting_utils.format_voting_results(app['params']['global-state'])


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