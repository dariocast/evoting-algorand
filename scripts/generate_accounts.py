from algosdk import account, mnemonic

number_of_account_to_generate = input("How many account do you want?: ")
try:
    entered_number = int(number_of_account_to_generate)
except:
    print("Entered value MUST be an integer!")

print("Generating " + number_of_account_to_generate + " account(s)")
f = open("accounts.txt", "w")
for x in range(entered_number):
    private_key, address = account.generate_account()
    f.write("Address #"+str(x+1)+": {}".format(address)+"\n")
    f.write("Passphrase #"+str(x+1)+": {}".format(mnemonic.from_private_key(private_key))+"\n")
    f.write("---\n")
f.close()
print("Account(s) generated in " + f.name)
print("Account(s) generated will be overwritten next time, save it NOW if you need them later!")
