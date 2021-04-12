# Main module for create a voting app and to cast votes

from pyteal import *

# On creation, minimum balance increase:
# 100000 + (25000+3500)*schema.NumUint + (25000+25000)*schema.NumByteSlice
# Where schema.NumUint and schema.NumByteSlice are the amount of on-chain storage desired 
def create_app():
    
    pass

def evoting_approval_program(preferences):
    on_creation = Seq([
        App.globalPut(Bytes("Creator"), Txn.sender()),
        Assert(Txn.application_args.length() == Int(len(preferences))),
        Return(Int(1))
    ])
    is_creator = Txn.sender() == App.globalGet(Bytes("Creator"))
    pass

def evoting_clear_program():
    pass

def vote():
    pass