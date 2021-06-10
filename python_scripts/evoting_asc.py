from algosdk.future.transaction import *
from pyteal import *


def voting_approval_program(preferences, assetId):
    available_choices = [
        App.globalPut(Bytes(x), Int(0))
        for x in preferences
    ]
    on_creation = Seq(
        [ApplicationCallTxn.globalPut(Bytes("Creator"), Txn.sender()), Assert(Txn.application_args.length() == Int(4))]
        + available_choices +
        [Return(Int(1))]
    )
    is_creator = Txn.sender() == App.globalGet(Bytes("Creator"))

    on_closeout = Return(Int(1))
    on_register = Return(Int(1))

    choice = Txn.application_args[1]
    is_choice_valid = App.globalGetEx(Global.current_application_id(), choice)
    choice_tally = App.globalGet(choice)

    on_vote = Seq([
        Assert(is_choice_valid.hasValue()),
        App.globalPut(choice, choice_tally + Int(1)),
        Return(Int(1))
    ])

    program = Cond(
        [Txn.application_id() == Int(0), on_creation],
        [Txn.on_completion() == OnComplete.DeleteApplication, Return(is_creator)],
        [Txn.on_completion() == OnComplete.UpdateApplication, Return(is_creator)],
        [Txn.on_completion() == OnComplete.CloseOut, on_closeout],
        [Txn.on_completion() == OnComplete.OptIn, on_register],
        [Txn.application_args[0] == Bytes("vote"), on_vote]
    )

    return program


def voting_clear_program():
    program = Return(Int(1))

    return program


if __name__ == "__main__":
    preferences = [
        'Preference1',
        'Preference2',
        'Preference3'
    ]
    with open('vote_approval.teal', 'w') as f:
        compiled = compileTeal(voting_approval_program(preferences), mode=Mode.Application, version=2)
        f.write(compiled)

    with open('vote_clear_state.teal', 'w') as f:
        compiled = compileTeal(voting_clear_program(), mode=Mode.Application, version=2)
        f.write(compiled)
