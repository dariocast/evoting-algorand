from algosdk.future.transaction import AssetConfigTxn, AssetTransferTxn
from algosdk import account, mnemonic
import utils

def account_selection(type='creator'):
    # select creator address
    accounts = {}
    counter = 0
    for m in utils.getPassphrases():
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


def create_asset():
    # choose amount
    number_of_units_to_generate = input("How many units do you want?: ")
    number_of_decimals = input("How many decimals do you want?: ")
    try:
        total_wanted = int(number_of_units_to_generate)
        decimal_wanted = int(number_of_decimals)
    except:
        print("Entered values MUST be integer>0!")

    account_selected = account_selection('creator')

    client = utils.getAlgodClient()
    params = client.suggested_params()
    txn = AssetConfigTxn(
        sender=account_selected['pk'],
        sp=params,
        total=total_wanted,
        default_frozen=False,
        unit_name="VOTASSET",
        asset_name="vote asset",
        manager=account_selected['pk'],
        reserve=account_selected['pk'],
        freeze=account_selected['pk'],
        clawback=account_selected['pk'],
        url="", 
        decimals=decimal_wanted)
    stxn = txn.sign(account_selected['sk'])

    txid = client.send_transaction(stxn)
    print(f"transaction ID: {txid}")

    # Retrieve the asset ID of the newly created asset by first
    # ensuring that the creation transaction was confirmed,
    # then grabbing the asset id from the transaction.

    # Wait for the transaction to be confirmed
    utils.wait_for_confirmation(client,txid)

    try:
        # Pull account info for the creator
        # account_info = client.account_info(account_selected['pk'])
        # get asset_id from tx
        # Get the new asset's information from the creator account
        ptx = client.pending_transaction_info(txid)
        asset_id = ptx["asset-index"]
        utils.print_created_asset(client, account_selected['pk'], asset_id)
        utils.print_asset_holding(client, account_selected['pk'], asset_id)
    except Exception as e:
        print(e)


def opt_in_to_asset():
    client = utils.getAlgodClient()
    account_selected = account_selection('interested-in')
    asset_id = input("Type asset ID to opt-in: ")
    try:
        asset_id = int(asset_id)
    except:
        print("Entered values MUST be integer!")
    # Check if asset_id is in account's asset holdings prior
    # to opt-in
    params = client.suggested_params()

    account_info = client.account_info(account_selected['pk'])
    holding = None
    idx = 0
    for my_account_info in account_info['assets']:
        scrutinized_asset = account_info['assets'][idx]
        idx = idx + 1    
        if (scrutinized_asset['asset-id'] == asset_id):
            holding = True
            break

    if not holding:
        txn = AssetTransferTxn(
            sender=account_selected['pk'],
            sp=params,
            amt=0,
            receiver=account_selected['pk'],
            index=asset_id)
        stxn = txn.sign(account_selected['sk'])
        txid = client.send_transaction(stxn)
        print(f"transaction ID: {txid}")
        # Wait for the transaction to be confirmed
        utils.wait_for_confirmation(client, txid)
        # Now check the asset holding for that account.
        # This should now show a holding with a balance of 0.
        utils.print_asset_holding(client, account_selected['pk'], asset_id)


def opt_out_from_asset():
    client = utils.getAlgodClient()
    account_selected = account_selection('interested-out')
    receiver = account_selection('receiver')
    asset_id = input("Type asset ID to opt-out: ")
    try:
        asset_id = int(asset_id)
    except:
        print("Entered values MUST be integer!")
    # Check if asset_id is in account's asset holdings prior
    # to opt-in
    params = client.suggested_params()

    account_info = client.account_info(account_selected['pk'])
    holding = None
    idx = 0
    for my_account_info in account_info['assets']:
        scrutinized_asset = account_info['assets'][idx]
        idx = idx + 1    
        if (scrutinized_asset['asset-id'] == asset_id):
            holding = True
            creator = scrutinized_asset['creator']
            break

    if holding:
        # Use the AssetTransferTxn class to transfer assets and opt-out
        txn = AssetTransferTxn(
            close_assets_to=creator if creator != '' else receiver['pk'],
            sender=account_selected['pk'],
            sp=params,
            amt=0,
            receiver=creator if creator != '' else receiver['pk'],
            index=asset_id)
        stxn = txn.sign(account_selected['sk'])
        txid = client.send_transaction(stxn)
        print(f"transaction ID: {txid}")
        # Wait for the transaction to be confirmed
        utils.wait_for_confirmation(client, txid)
        # Now check the asset holding for that account.
        # This should now show a holding with a balance of 0.
        utils.print_asset_holding(client, account_selected['pk'], asset_id)


def send_to():
    sender = account_selection('sender')
    receiver = account_selection('receiver')
    asset_id = input("Type asset ID to trade: ")
    amount = input("How many units do you want to transfer?: ")
    try:
        asset_id = int(asset_id)
        amount = int(amount)
    except:
        print("Entered values MUST be integer!")
    client = utils.getAlgodClient()
    params = client.suggested_params()
    txn = AssetTransferTxn(
        sender=sender['pk'],
        sp=params,
        receiver=receiver["pk"],
        amt=amount,
        index=asset_id)
    stxn = txn.sign(sender['sk'])
    txid = client.send_transaction(stxn)
    print(f"transaction ID: {txid}")
    # Wait for the transaction to be confirmed
    utils.wait_for_confirmation(client, txid)
    # The balance should now be 10.
    print("Asset holding for sender after transaction:")
    utils.print_asset_holding(client, sender['pk'], asset_id)
    print("Asset holding for receiver after transaction:")
    utils.print_asset_holding(client, receiver['pk'], asset_id)


def destroy_all_units():
    # DESTROY ASSET
    account_selected = account_selection("manager")
    asset_id = input("Type asset ID to destroy: ")
    try:
        asset_id = int(asset_id)
    except:
        print("Entered values MUST be integer!")

    # With all assets back in the creator's account,
    # the manager (Account 1) destroys the asset.
    client = utils.getAlgodClient()
    params = client.suggested_params()

    # Asset destroy transaction
    txn = AssetConfigTxn(
        sender=account_selected['pk'],
        sp=params,
        index=asset_id,
        strict_empty_address_check=False
        )

    # Sign with secret key of creator
    stxn = txn.sign(account_selected['sk'])
    # Send the transaction to the network and retrieve the txid.
    txid = client.send_transaction(stxn)
    print(f"transaction ID: {txid}")
    # Wait for the transaction to be confirmed
    utils.wait_for_confirmation(client, txid)

    # Asset was deleted.
    print("Accounts opted in must do a transaction for an amount of 0, " )
    print("with a close_assets_to to the creator account, to clear it from its accountholdings")
    for m in utils.getPassphrases():
        print(f"Address {mnemonic.to_public_key(m)} holdings: ")
        utils.print_asset_holding(client, mnemonic.to_public_key(m), asset_id)


def check_holdings():
    client = utils.getAlgodClient()
    account_selected = account_selection('to check')
    asset_id = input("Type asset ID to check: ")
    try:
        asset_id = int(asset_id)
    except:
        print("Entered values MUST be integer!")

    utils.print_asset_holding(client, account_selected['pk'], asset_id)


def main():
    options = {
        0 : create_asset,
        1 : opt_in_to_asset,
        2 : opt_out_from_asset,
        3 : send_to,
        4 : destroy_all_units,
        5 : check_holdings,
    }

    cmd = input("type a command: ")
    options[int(cmd)]()


if __name__ == "__main__":
    main()
