from testnet_client import getAlgodClient
from algosdk import account, mnemonic
import json

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


passphrases = getPassphrases()
private_key1 = mnemonic.to_private_key(passphrases[0])
private_key2 = mnemonic.to_private_key(passphrases[1])
my_address1 = mnemonic.to_public_key(passphrases[0])
my_address2 = mnemonic.to_public_key(passphrases[1])
print("First address: {}".format(my_address1))
print("Second address: {}".format(my_address2))

account_info = getAlgodClient().account_info(my_address1)
account_info2 = getAlgodClient().account_info(my_address2)
print("First account balance: {} microAlgos".format(account_info.get('amount')))
print("Second account balance: {} microAlgos".format(account_info2.get('amount')))
