from scripts.testnet_client import getAlgodClient
from algosdk import account, mnemonic
import json

def getPassphrases():
    passphrases = []
    import os
    THIS_FOLDER = os.path.dirname(os.path.abspath(__file__))
    file = os.path.join(THIS_FOLDER, 'config.json')
    with open(file, "r") as config_file:
        data = json.load(config_file)
        for passphrase in data:
            passphrases.append(data['passphrase'])
        return passphrases

passphrases = getPassphrases()
private_key = mnemonic.to_private_key(passphrases[0])
my_address = mnemonic.to_public_key(passphrases[0])
print("My address: {}".format(my_address))

account_info = getAlgodClient.account_info(my_address)
print("Account balance: {} microAlgos".format(account_info.get('amount')))