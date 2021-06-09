import 'dart:async';

import 'package:algorand_dart/algorand_dart.dart';
import '../../core/account_repository/account_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  AccountBloc({required AccountRepository accountRepository})
      : _accountRepository = accountRepository,
        super(AccountNotPresent()) {
    _accountSubscription =
        _accountRepository.accountStateChanged.listen((account) => add(
              AccountStatusChanged(account),
            ));
  }

  final AccountRepository _accountRepository;

  late final StreamSubscription _accountSubscription;

  @override
  Stream<AccountState> mapEventToState(
    AccountEvent event,
  ) async* {
    if (event is AccountStatusChanged) {
      if (event.account != null) {
        yield AccountLoaded(account: event.account);
      } else {
        yield AccountNotPresent();
      }
    } else if (event is AccountDeleteRequested) {
      await _accountRepository.deleteAccount();
      yield AccountNotPresent();
    }
  }

  Future<void> close() {
    _accountSubscription.cancel();
    return super.close();
  }
}
