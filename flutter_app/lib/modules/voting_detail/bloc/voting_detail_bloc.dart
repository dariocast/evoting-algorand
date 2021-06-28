import 'dart:async';
import 'dart:convert';

import 'package:algorand_evoting/core/account_repository/account_repository.dart';
import 'package:algorand_evoting/core/models/models.dart';
import 'package:algorand_evoting/utils/services/algorand_service.dart';
import 'package:algorand_evoting/utils/services/rest_api_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'voting_detail_event.dart';
part 'voting_detail_state.dart';

class VotingDetailBloc extends Bloc<VotingDetailEvent, VotingDetailState> {
  VotingDetailBloc({required this.accountRepo, required Voting voting})
      : super(VotingDetailState(voting: voting));

  final AccountRepository accountRepo;

  @override
  Stream<VotingDetailState> mapEventToState(
    VotingDetailEvent event,
  ) async* {
    yield state.copyWith(loading: true);
    if (event is VotingDetailLoaded) {
      final searchAsset = await algorand
          .indexer()
          .assets()
          .whereAssetId(int.parse(state.voting.requiredAsset))
          .search();
      final asset = searchAsset.assets.elementAt(0).params.name;
      final searchResponse = await algorand
          .indexer()
          .accounts()
          .whereApplicationId(int.parse(state.voting.votingId))
          .search();
      final address = accountRepo.account?.address;
      bool optedIn = false;
      searchResponse.accounts.forEach((account) {
        if (account.address == address!.encodedAddress) {
          optedIn = true;
        }
      });
      RestApiResponse localState = await RestApiService.votingLocalState(
        state.voting.votingId,
        address!.encodedAddress,
      );
      bool voted = localState.data != null &&
          (localState.data as Map).containsKey('voted');
      yield state.copyWith(
        optedIn: optedIn,
        voted: voted,
        loading: false,
        assetName: asset,
      );
    } else if (event is VotingDetailOptedIn) {
      final passphrase = (await accountRepo.account!.seedPhrase).join(' ');
      try {
        RestApiResponse response = await RestApiService.registerForVoting(
            state.voting.votingId, passphrase);
        print(response.message);
        if (response.status == 200)
          yield state.copyWith(
            optedIn: true,
            loading: false,
          );
        else
          yield state.copyWith(
            optedIn: false,
            loading: false,
          );
      } on Exception catch (e) {
        print(e);
        yield state.copyWith(
          optedIn: false,
          loading: false,
        );
      }
    } else if (event is VotingDetailVoted) {
      final passphrase = (await accountRepo.account!.seedPhrase).join(' ');
      try {
        RestApiResponse response = await RestApiService.voteForVoting(
            state.voting.votingId, passphrase, event.choice);
        print(response.message);
        if (response.status == 200)
          yield state.copyWith(
            voted: true,
            loading: false,
          );
        else
          yield state.copyWith(
            voted: false,
            loading: false,
          );
      } on Exception catch (e) {
        print(e);
        yield state.copyWith(
          voted: false,
          loading: false,
        );
      }
    }
  }
}
