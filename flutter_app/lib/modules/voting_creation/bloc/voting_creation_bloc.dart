import 'dart:async';
import 'dart:convert';

import 'package:algorand_dart/algorand_dart.dart';
import 'package:algorand_evoting/core/account_repository/account_repository.dart';
import 'package:algorand_evoting/modules/voting_creation/models/asset_input.dart';
import 'package:algorand_evoting/modules/voting_creation/models/models.dart';
import 'package:algorand_evoting/modules/voting_creation/models/text_input.dart';
import 'package:algorand_evoting/utils/services/algorand_service.dart';
import 'package:algorand_evoting/utils/services/rest_api_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:intl/intl.dart';

part 'voting_creation_event.dart';
part 'voting_creation_state.dart';

class VotingCreationBloc
    extends Bloc<VotingCreationEvent, VotingCreationState> {
  VotingCreationBloc(this._accountRepo) : super(VotingCreationState());

  final AccountRepository _accountRepo;
  @override
  Stream<VotingCreationState> mapEventToState(
    VotingCreationEvent event,
  ) async* {
    if (event is VotingCreationRegBeginChanged) {
      final regBegin = DateInput.dirty(event.date);
      yield state.copyWith(
        regBegin: regBegin,
        status: Formz.validate(
          [
            state.title,
            state.description,
            state.assetId,
            state.optionOne,
            state.optionTwo,
            regBegin,
            state.regEnd,
            state.voteBegin,
            state.voteEnd,
          ],
        ),
      );
    } else if (event is VotingCreationRegEndChanged) {
      final regEnd = DateInput.dirty(event.date);
      yield state.copyWith(
        regEnd: regEnd,
        status: Formz.validate(
          [
            state.title,
            state.description,
            state.assetId,
            state.optionOne,
            state.optionTwo,
            state.regBegin,
            regEnd,
            state.voteBegin,
            state.voteEnd,
          ],
        ),
      );
    } else if (event is VotingCreationVoteBeginChanged) {
      final voteBegin = DateInput.dirty(event.date);
      yield state.copyWith(
        voteBegin: voteBegin,
        status: Formz.validate(
          [
            state.title,
            state.description,
            state.assetId,
            state.optionOne,
            state.optionTwo,
            state.regBegin,
            state.regEnd,
            voteBegin,
            state.voteEnd,
          ],
        ),
      );
    } else if (event is VotingCreationVoteEndChanged) {
      final voteEnd = DateInput.dirty(event.date);
      yield state.copyWith(
        voteEnd: voteEnd,
        status: Formz.validate(
          [
            state.title,
            state.description,
            state.assetId,
            state.optionOne,
            state.optionTwo,
            state.regBegin,
            state.regEnd,
            state.voteBegin,
            voteEnd,
          ],
        ),
      );
    } else if (event is VotingCreationTitleChanged) {
      final title = TextInput.dirty(event.title);
      yield state.copyWith(
        title: title,
        status: Formz.validate(
          [
            title,
            state.description,
            state.assetId,
            state.optionOne,
            state.optionTwo,
            state.regBegin,
            state.regEnd,
            state.voteBegin,
            state.voteEnd,
          ],
        ),
      );
    } else if (event is VotingCreationDescriptionChanged) {
      final description = TextInput.dirty(event.description);

      yield state.copyWith(
        description: description,
        status: Formz.validate(
          [
            state.title,
            description,
            state.assetId,
            state.optionOne,
            state.optionTwo,
            state.regBegin,
            state.regEnd,
            state.voteBegin,
            state.voteEnd,
          ],
        ),
      );
    } else if (event is VotingCreationOptOneChanged) {
      final optionOne = TextInput.dirty(event.opt);
      yield state.copyWith(
        optionOne: optionOne,
        status: Formz.validate(
          [
            state.title,
            state.description,
            state.assetId,
            optionOne,
            state.optionTwo,
            state.regBegin,
            state.regEnd,
            state.voteBegin,
            state.voteEnd,
          ],
        ),
      );
    } else if (event is VotingCreationOptTwoChanged) {
      final optionTwo = TextInput.dirty(event.opt);
      yield state.copyWith(
        optionTwo: optionTwo,
        status: Formz.validate(
          [
            state.title,
            state.description,
            state.assetId,
            state.optionOne,
            optionTwo,
            state.regBegin,
            state.regEnd,
            state.voteBegin,
            state.voteEnd,
          ],
        ),
      );
    } else if (event is VotingCreationAssetIdChanged) {
      final asset = AssetInput.dirty(event.assetId ?? null);
      yield state.copyWith(
        assetId: asset,
        status: Formz.validate(
          [
            state.title,
            state.description,
            asset,
            state.optionOne,
            state.optionTwo,
            state.regBegin,
            state.regEnd,
            state.voteBegin,
            state.voteEnd,
          ],
        ),
      );
    } else if (event is VotingCreationSubmitted) {
      if (state.status.isValidated) {
        yield state.copyWith(status: FormzStatus.submissionInProgress);
        final seedPhrase = await _accountRepo.account!.seedPhrase;
        final passphrase = seedPhrase.join(' ');
        String regBegin =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(state.regBegin.value!);
        String regEnd =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(state.regEnd.value!);
        String voteBegin =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(state.voteBegin.value!);
        String voteEnd =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(state.voteEnd.value!);
        final voting = jsonEncode({
          'assetId': state.assetId.value!.index.toString(),
          'title': state.title.value,
          'description': state.description.value,
          'options': [state.optionOne.value, state.optionTwo.value],
          'regBegin': regBegin,
          'regEnd': regEnd,
          'voteBegin': voteBegin,
          'voteEnd': voteEnd,
          'passphrase': passphrase
        });
        try {
          RestApiResponse response = await RestApiService.createVoting(voting);
          print(response.message);
          if (response.status != 200)
            yield state.copyWith(status: FormzStatus.submissionFailure);
          else
            yield state.copyWith(status: FormzStatus.submissionSuccess);
        } on Exception catch (e) {
          print(e);
          yield state.copyWith(status: FormzStatus.submissionFailure);
        }
      }
    } else if (event is VotingCreationStarted) {
      final searchResponse = await algorand
          .indexer()
          .assets()
          .whereCreator(_accountRepo.account!.publicAddress)
          .search();
      yield state.copyWith(
        availableAssets: searchResponse.assets,
      );
    }
  }
}
