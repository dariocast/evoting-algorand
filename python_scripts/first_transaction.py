from algosdk import account, mnemonic

def generate_algorand_keypair():
    private_key, address = account.generate_account()
    print("My address: {}".format(address))
    print("My passphrase: {}".format(mnemonic.from_private_key(private_key)))

from testnet_client_test import algod_client

# generate_algorand_keypair()

# passphrase = "head exile credit private couch special spawn also merry grant faith parent blade measure rigid mixed waste notice dizzy concert hidden nephew change absent emotion"
passphrase = "burger annual abstract dentist unable glad crash cannon wet long fringe cube dress devote hill ancient luggage apple unable van inspire lesson wine abstract timber"
private_key = mnemonic.to_private_key(passphrase)
my_address = mnemonic.to_public_key(passphrase)
print("My address: {}".format(my_address))

account_info = algod_client.account_info(my_address)
print("Account balance: {} microAlgos".format(account_info.get('amount')))

# params = algod_client.suggested_params()
# # comment out the next two (2) lines to use suggested fees
# params.flat_fee = True
# params.fee = 1000
# # receiver è l'address del sink della testnet, cioè mando indietro i soldi
# receiver = "GD64YIY3TWGDMCNPP553DZPPR6LDUSFQOIJVFDPPXWEG3FVOJCCDBBHU5A"
# note = "Ciao Roberta".encode()

# from algosdk.future.transaction import PaymentTxn

# unsigned_txn = PaymentTxn(my_address, params, receiver, 1000000, None, note)
# signed_txn = unsigned_txn.sign(mnemonic.to_private_key(passphrase))

# txid = algod_client.send_transaction(signed_txn)
# print("Successfully sent transaction with txID: {}".format(txid))

# import time
# time.sleep(10)

# account_info = algod_client.account_info(my_address)
# print("New account balance: {} microAlgos".format(account_info.get('amount')))
