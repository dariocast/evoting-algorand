import 'app.dart';
import 'core/account_repository/account_repository.dart';
import 'utils/services/account_service.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  // Initialize hive
  await Hive.initFlutter();
  Hive.registerAdapter(AccountAdapter());

  await Hive.openBox<AccountEntity>('accounts');

  // Register the account repository
  await accountRepository.init();

  runApp(App(accountRepository: accountRepository));
}
