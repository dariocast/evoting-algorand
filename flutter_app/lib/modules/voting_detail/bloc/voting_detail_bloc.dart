import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'voting_detail_event.dart';
part 'voting_detail_state.dart';

class VotingDetailBloc extends Bloc<VotingDetailEvent, VotingDetailState> {
  VotingDetailBloc() : super(VotingDetailInitial());

  @override
  Stream<VotingDetailState> mapEventToState(
    VotingDetailEvent event,
  ) async* {
    // TODO: implement mapEventToState
  }
}
