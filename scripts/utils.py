from algosdk.v2client import algod
from algosdk import account, mnemonic
import json


def getAlgodClient() -> algod.AlgodClient:
    import os
    THIS_FOLDER = os.path.dirname(os.path.abspath(__file__))
    file = os.path.join(THIS_FOLDER, 'config.json')
    with open(file, "r") as config_file:
        data = json.load(config_file)
        algod_address = 'http://' + data['macmini']['host'] + ':' + str(data['macmini']['port'])
        algod_token = data['macmini']['token']
        return algod.AlgodClient(algod_address=algod_address, algod_token=algod_token)


def account_selection(type='creator'):
    # select creator address
    accounts = {}
    counter = 0
    for m in getPassphrases():
        accounts[counter] = {}
        accounts[counter]['pk'] = mnemonic.to_public_key(m)
        accounts[counter]['sk'] = mnemonic.to_private_key(m)
        counter += 1
    print(f"you have {len(accounts)} account(s):")
    for a in accounts:
        print(f"{a} - {accounts[a]['pk']}")
    account_selected = input(f"Which account do you want as {type}?: ")
    try:
        account_selected = int(account_selected)
    except:
        print(f"Entered value MUST be integer < {len(accounts)}!")
    return accounts[account_selected]


def getPassphrases():
    passphrases = []
    import os
    THIS_FOLDER = os.path.dirname(os.path.abspath(__file__))
    file = os.path.join(THIS_FOLDER, 'config.json')
    with open(file, "r") as config_file:
        data = json.load(config_file)
        for account in data['accounts']:
            passphrases.append(account['passphrase'])
        return passphrases

def getAddresses():
    addresses = []
    import os
    THIS_FOLDER = os.path.dirname(os.path.abspath(__file__))
    file = os.path.join(THIS_FOLDER, 'config.json')
    with open(file, "r") as config_file:
        data = json.load(config_file)
        for account in data['accounts']:
            addresses.append(account['address'])
        return addresses

def wait_for_confirmation(client, txid):
    """
    Utility function to wait until the transaction is
    confirmed before proceeding.
    """
    last_round = client.status().get('last-round')
    txinfo = client.pending_transaction_info(txid)
    while not (txinfo.get('confirmed-round') and txinfo.get('confirmed-round') > 0):
        print("Waiting for confirmation")
        last_round += 1
        client.status_after_block(last_round)
        txinfo = client.pending_transaction_info(txid)
    print("Transaction {} confirmed in round {}.".format(txid, txinfo.get('confirmed-round')))
    return txinfo

#   Utility function used to print created asset for account and assetid
def print_created_asset(algodclient, account, assetid):    
    # note: if you have an indexer instance available it is easier to just use this
    # response = myindexer.accounts(asset_id = assetid)
    # then use 'account_info['created-assets'][0] to get info on the created asset
    account_info = algodclient.account_info(account)
    idx = 0
    for my_account_info in account_info['created-assets']:
        scrutinized_asset = account_info['created-assets'][idx]
        idx = idx + 1       
        if (scrutinized_asset['index'] == assetid):
            print("Asset ID: {}".format(scrutinized_asset['index']))
            print(json.dumps(my_account_info['params'], indent=4))
            break

#   Utility function used to print asset holding for account and assetid
def print_asset_holding(algodclient, account, assetid):
    # note: if you have an indexer instance available it is easier to just use this
    # response = myindexer.accounts(asset_id = assetid)
    # then loop thru the accounts returned and match the account you are looking for
    account_info = algodclient.account_info(account)
    idx = 0
    for my_account_info in account_info['assets']:
        scrutinized_asset = account_info['assets'][idx]
        idx = idx + 1        
        if (scrutinized_asset['asset-id'] == assetid):
            print("Asset ID: {}".format(scrutinized_asset['asset-id']))
            print(json.dumps(scrutinized_asset, indent=4))
            break