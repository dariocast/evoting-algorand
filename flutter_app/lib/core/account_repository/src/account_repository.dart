import 'dart:typed_data';

import 'package:algorand_dart/algorand_dart.dart';
import '../account_repository.dart';
import '../../../utils/services/algorand_service.dart';
import 'package:hive/hive.dart';
import 'package:rxdart/rxdart.dart';

class AccountRepository {
  final Box<AccountEntity> accountBox;
  final BehaviorSubject<Account?> _accountSubject = BehaviorSubject<Account?>();

  AccountRepository() : accountBox = Hive.box<AccountEntity>('accounts');

  Stream<Account?> get accountStateChanged => _accountSubject.stream;

  Account? get account => _accountSubject.value;

  Future<void> init() async {
    final account = await accountBox.get(0)?.unwrap();
    // if (account == null) return;

    _accountSubject.add(account);
  }

  // Creazione nuovo account
  Future<Account> createAccount() async {
    final account = await algorand.createAccount();
    // ! Should be encrypted
    final privateKey = await account.keyPair.extractPrivateKeyBytes();
    final passphrase = await account.seedPhrase;
    final entity = AccountEntity.account(
        account, Uint8List.fromList(privateKey), passphrase.join(' '));
    await accountBox.put(0, entity);

    // publish on stream
    _accountSubject.add(account);

    return account;
  }

  // Import dalla passphrase
  Future<Account> importAccount(List<String> words) async {
    final account = await algorand.restoreAccount(words);

    // ! Should be encrypted
    final privateKey = await account.keyPair.extractPrivateKeyBytes();
    final entity = AccountEntity.account(
        account, Uint8List.fromList(privateKey), words.join(' '));
    await accountBox.put(0, entity);

    // publish on stream
    _accountSubject.add(account);

    return account;
  }

  // Import dalla passphrase
  Future deleteAccount() async {
    await accountBox.clear();

    return account;
  }

  void reload() {
    final account = this.account;
    if (account == null) return;

    _accountSubject.add(account);
  }

  void close() {
    _accountSubject.close();
  }
}
