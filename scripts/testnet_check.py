from config_utils import getAlgodClient, getPassphrases
from algosdk import account, mnemonic
import json


client = getAlgodClient()
status = client.status()
print(json.dumps(status, indent=4))

passphrases = getPassphrases()
private_key1 = mnemonic.to_private_key(passphrases[0])
private_key2 = mnemonic.to_private_key(passphrases[1])
my_address1 = mnemonic.to_public_key(passphrases[0])
my_address2 = mnemonic.to_public_key(passphrases[1])
print("First address: {}".format(my_address1))
print("Second address: {}".format(my_address2))

account_info = client.account_info(my_address1)
account_info2 = client.account_info(my_address2)
print("First account balance: {} microAlgos".format(account_info.get('amount')))
print("Second account balance: {} microAlgos".format(account_info2.get('amount')))
