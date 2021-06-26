part of 'account_bloc.dart';

abstract class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object> get props => [];
}

class AccountStatusChanged extends AccountEvent {
  final Account? account;

  AccountStatusChanged(this.account);

  @override
  List<Object> get props => account != null ? [account!] : [];
}

class AccountDeleteRequested extends AccountEvent {}
