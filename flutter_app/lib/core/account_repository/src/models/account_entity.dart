import 'dart:typed_data';

import '../../../../constants/app_constants.dart';
import 'package:hive/hive.dart';
import 'package:algorand_dart/algorand_dart.dart';

part 'account_entity.g.dart';

@HiveType(typeId: accountTypeId, adapterName: 'AccountAdapter')
class AccountEntity {
  @HiveField(0)
  late String publicAddress;

  @HiveField(1)
  late Uint8List privateKey;

  AccountEntity();

  AccountEntity.account(Account account, Uint8List privateKey) {
    this.publicAddress = account.publicAddress;
    this.privateKey = privateKey;
  }

  Future<Account> unwrap() async {
    return Account.fromSeed(this.privateKey);
  }
}
