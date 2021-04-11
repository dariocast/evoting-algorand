from algosdk.v2client import algod
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