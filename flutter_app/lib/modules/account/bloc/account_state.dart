part of 'account_bloc.dart';

abstract class AccountState extends Equatable {
  const AccountState();

  @override
  List<Object> get props => [];
}

class AccountNotPresent extends AccountState {}

class AccountLoaded extends AccountState {
  final Account? account;

  AccountLoaded({this.account});
}
