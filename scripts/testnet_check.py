from config_utils import getAlgodClient, getPassphrases
from algosdk import account, mnemonic
import json


client = getAlgodClient()
status = client.status()
print(json.dumps(status, indent=4))

passphrases = getPassphrases()

private_key1 = mnemonic.to_private_key(passphrases[0])
private_key2 = mnemonic.to_private_key(passphrases[1])
private_key3 = mnemonic.to_private_key(passphrases[2])
private_key4 = mnemonic.to_private_key(passphrases[3])

my_address1 = mnemonic.to_public_key(passphrases[0])
my_address2 = mnemonic.to_public_key(passphrases[1])
my_address3 = mnemonic.to_public_key(passphrases[2])
my_address4 = mnemonic.to_public_key(passphrases[3])

print("First address: {}".format(my_address1))
print("Second address: {}".format(my_address2))
print("Third address: {}".format(my_address3))
print("Fourth address: {}".format(my_address4))

account_info = client.account_info(my_address1)
account_info2 = client.account_info(my_address2)
account_info3 = client.account_info(my_address3)
account_info4 = client.account_info(my_address4)

print("First account balance: {} microAlgos".format(account_info.get('amount')))
print("Second account balance: {} microAlgos".format(account_info2.get('amount')))
print("Third account balance: {} microAlgos".format(account_info3.get('amount')))
print("Fourth account balance: {} microAlgos".format(account_info4.get('amount')))
