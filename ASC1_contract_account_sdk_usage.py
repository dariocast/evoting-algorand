from algosdk.v2client import algod
from algosdk.future.transaction import PaymentTxn, LogicSig, LogicSigTransaction
import base64

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
    print("Transaction {} confirmed in round {}.".format(
        txid, txinfo.get('confirmed-round')))
    return txinfo

try:
    from testnet_client_test import algod_client
    from first_transaction import my_address
    receiver = my_address 

    myprogram = "samplearg.teal"
    # Read TEAL program
    data = open(myprogram, 'r').read()
    # Compile TEAL program
    response = algod_client.compile(data)
    # Print(response)
    print("Response Result = ", response['result'])
    print("Response Hash = ", response['hash'])

    # Create logic sig
    programstr = response['result']
    t = programstr.encode()
    # program = b"hex-encoded-program"
    program = base64.decodebytes(t)
    print(program)

    # Create arg to pass if TEAL program requires an arg
    # if not, omit args param
    arg1 = (123).to_bytes(8, 'big')
    lsig = LogicSig(program, args=[arg1])
    print("lsig Address: " + lsig.address())
    sender = lsig.address()

    # Get suggested parameters
    params = algod_client.suggested_params()
    # Comment out the next two (2) lines to use suggested fees
    params.flat_fee = True
    params.fee = 1000

    # Build transaction  
    amount = 10000 
    closeremainderto = None

    # Create a transaction
    txn = PaymentTxn(
        sender, params, receiver, amount, closeremainderto)

    # Create the LogicSigTransaction with contract account LogicSig
    lstx = LogicSigTransaction(txn, lsig)

    # Send raw LogicSigTransaction to network
    txid = algod_client.send_transaction(lstx)
    print("Transaction ID: " + txid)    
    wait_for_confirmation(algod_client, txid) 

except Exception as e:
    print(e)