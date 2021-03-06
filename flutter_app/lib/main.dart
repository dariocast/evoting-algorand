import 'package:algorand_evoting/utils/simple_bloc_observer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'core/account_repository/account_repository.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  // Initialize hive
  await Hive.initFlutter();
  Hive.registerAdapter(AccountAdapter());

  await Hive.openBox<AccountEntity>('accounts');

  // Register the account repository
  final AccountRepository accountRepository = AccountRepository();
  await accountRepository.init();

  // Bloc.observer = SimpleBlocObserver();

  runApp(App(accountRepository: accountRepository));
}
