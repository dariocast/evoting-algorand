import 'dart:async';

import 'package:algorand_dart/algorand_dart.dart';
import '../../core/account_repository/src/account_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'wallet_event.dart';
part 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final AccountRepository accountRepository;

  void start() {
    add(WalletStarted());
  }

  void createWallet() {
    add(WalletCreateStarted());
  }

  void importWallet(String passphrase) {
    add(WalletImportStarted(passphrase: passphrase));
  }

  WalletBloc({required this.accountRepository}) : super(WalletInitial());

  @override
  Stream<WalletState> mapEventToState(
    WalletEvent event,
  ) async* {
    if (event is WalletCreateStarted) {
      final account = await accountRepository.createAccount();
      yield WalletCreateSuccess(account: account);
    } else if (event is WalletImportStarted) {
      final words = event.passphrase.trim().split(' ');
      final account = await accountRepository.importAccount(words);

      yield WalletRestoreSuccess(account: account);
    }
  }
}
