part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

// quando c'è home started si deve caricare la passphrase e anche l'elenco delle transazioni
class HomeStarted extends HomeEvent {}
