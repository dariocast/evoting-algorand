import 'dart:async';
import 'dart:convert';

import 'package:algorand_evoting/core/account_repository/account_repository.dart';
import 'package:algorand_evoting/core/models/models.dart';
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
    if (event is VotingDetailOptedIn) {
    } else if (event is VotingDetailVoted) {}
  }
}
