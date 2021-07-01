import 'dart:async';

import 'package:algorand_evoting/modules/account/account.dart';
import 'package:algorand_evoting/core/models/models.dart';
import 'package:algorand_evoting/modules/home/repository/home_repository.dart';
import 'package:algorand_evoting/utils/services/algorand_service.dart';
import 'package:algorand_evoting/utils/services/rest_api_service.dart';
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
      yield* _handleHomeStartedEvent();
    } else if (event is HomePassphraseChanged) {
      yield* _handlePassphraseChangedEvent(event);
    } else if (event is HomeDeleteVoting) {
      yield* _handleDeleteVotingEvent(event);
    }
  }

  @override
  Future<void> close() {
    accountBlocSubscription.cancel();
    return super.close();
  }

  Stream<HomeState> _handleHomeStartedEvent() async* {
    final accountState = accountBloc.state;
    if (accountState is AccountLoaded) {
      final words = await accountState.account!.seedPhrase;
      final passphrase = words.join(' ');
      List<Voting> votings = await _repository.getVotings();
      List<SimpleAsset> assets =
          await _repository.getAssets(accountState.account!.publicAddress);
      yield state.copyWith(
        passphrase: passphrase,
        votings: votings.length > 0 ? votings : state.votings,
        assets: assets,
        loading: false,
      );
    } else {
      List<Voting> votings = await _repository.getVotings();
      yield state.copyWith(
        votings: votings,
        loading: false,
      );
    }
  }

  Stream<HomeState> _handlePassphraseChangedEvent(
      HomePassphraseChanged event) async* {
    yield state.copyWith(
      passphrase: event.passphrase,
      loading: false,
    );
  }

  Stream<HomeState> _handleDeleteVotingEvent(HomeDeleteVoting event) async* {
    final id = event.voting.votingId;
    try {
      final response = await _repository.deleteVoting(id, state.passphrase);
      if (response.status == 200) {
        yield* _handleHomeStartedEvent();
      }
    } on RestApiException catch (e) {
      print(e);
      yield state.copyWith(
        loading: false,
      );
    }
  }
}
