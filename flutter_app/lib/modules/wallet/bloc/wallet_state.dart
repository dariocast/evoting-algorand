part of 'wallet_bloc.dart';

abstract class WalletState extends Equatable {
  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {}

class WalletCreateSuccess extends WalletState {
  final Account account;

  WalletCreateSuccess({required this.account});

  @override
  List<Object?> get props => [account];
}

class WalletRestoreSuccess extends WalletState {
  final Account account;

  WalletRestoreSuccess({required this.account});

  @override
  List<Object?> get props => [account];
}
