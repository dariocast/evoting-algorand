import 'dart:async';

import 'package:algorand_evoting/modules/account/account.dart';
import 'package:algorand_evoting/core/models/models.dart';
import 'package:algorand_evoting/modules/home/repository/home_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AccountBloc accountBloc;
  late StreamSubscription accountBlocSubscription;
  final HomeRepository _repository;

  HomeBloc(this.accountBloc, this._repository) : super(HomeState()) {
    this.accountBlocSubscription = accountBloc.stream.listen((state) async {
      if (state is AccountLoaded) {
        final words = await state.account!.seedPhrase;
        final passphrase = words.join(' ');
        add(HomePassphraseChanged(passphrase: passphrase));
      }
    });
  }

  @override
  Stream<HomeState> mapEventToState(
    HomeEvent event,
  ) async* {
    yield state.copyWith(
      loading: true,
    );
    if (event is HomeStarted) {
      yield* _handleHomeStartedEvent(event);
    } else if (event is HomePassphraseChanged) {
      yield* _handlePassphraseChangedEvent(event);
    }
  }

  @override
  Future<void> close() {
    accountBlocSubscription.cancel();
    return super.close();
  }

  Stream<HomeState> _handleHomeStartedEvent(HomeStarted event) async* {
    List<Voting> votings = await _repository.getVotings();
    yield state.copyWith(
      votings: votings,
      loading: false,
    );
  }

  Stream<HomeState> _handlePassphraseChangedEvent(
      HomePassphraseChanged event) async* {
    yield state.copyWith(
      passphrase: event.passphrase,
      loading: false,
    );
  }
}
