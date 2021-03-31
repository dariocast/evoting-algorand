from algosdk.v2client import algod
import json
# token e address del macmini
algod_address_macmini = "http://192.168.1.17:8888"
algod_token_macmini = "5d7b1576d3a5894252fc5a444a758b8e4427f6406d2c3fc6fbf32ba021cd6d35"

# token e address del raspberry
algod_address_raspi = "http://192.168.1.111:8888"
algod_token_raspi = "829446f8f7168d305dcdcd71c9e00e2bb624763df946ccf3ccdb5a0bea9084eb"


algod_client = algod.AlgodClient(algod_address=algod_address_macmini, algod_token=algod_token_macmini)

status = algod_client.status()
print(json.dumps(status, indent=4))