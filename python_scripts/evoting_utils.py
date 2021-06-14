# helper function to compile program source
import base64
import json

from algosdk import mnemonic


def compile_program(client, source_code):
    compile_response = client.compile(source_code)
    return base64.b64decode(compile_response['result'])

# helper function that converts a mnemonic passphrase into a private signing key
def get_private_key_from_mnemonic(mn):
    private_key = mnemonic.to_private_key(mn)
    return private_key

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

def main():
    # /indexer/python/search_transactions_note.py
    from algosdk.v2client import indexer
    indexer_address = "https://testnet-algorand.api.purestake.io/idx2"
    indexer_token = "6ouFHKmlgF57UkOUz9eDZ1XTN7iZU9Fo2LxhxhBX"

    # instantiate indexer client
    myindexer = indexer.IndexerClient(
        indexer_token=indexer_token,
        indexer_address=indexer_address,
        headers = {
            "X-API-Key": indexer_token,
        },)

    note_prefix = base64.b64encode(b'[voteapp][creation]')
    print(note_prefix)

    response = myindexer.search_transactions(
        note_prefix=note_prefix)

    print("note_prefix = " + json.dumps(response, indent=2, sort_keys=True))

if __name__ == "__main__":
    main()