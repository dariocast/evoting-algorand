import 'dart:async';

import 'package:algorand_dart/algorand_dart.dart';
import 'package:algorand_evoting/core/account_repository/account_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'wallet_event.dart';
part 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final AccountRepository accountRepository;

  WalletBloc({required this.accountRepository}) : super(WalletInitial());

  @override
  Stream<WalletState> mapEventToState(
    WalletEvent event,
  ) async* {
    if (event is WalletCreateStarted) {
      try {
        final account = await accountRepository.createAccount();
        yield WalletCreateSuccess(account: account);
      } catch (AlgorandException) {
        yield WalletFailure(message: 'Unable to create account');
      }
    } else if (event is WalletImportStarted) {
      final words = event.passphrase.trim().split(' ');

      try {
        final account = await accountRepository.importAccount(words);
        yield WalletRestoreSuccess(account: account);
      } catch (AlgorandException) {
        yield WalletFailure(message: 'Unable to recover account');
      }
    }
    yield WalletInitial();
  }
}
