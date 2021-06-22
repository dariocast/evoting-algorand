import 'dart:async';

import 'package:algorand_evoting/modules/voting_creation/models/models.dart';
import 'package:algorand_evoting/modules/voting_creation/models/text_input.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

part 'voting_creation_event.dart';
part 'voting_creation_state.dart';

class VotingCreationBloc
    extends Bloc<VotingCreationEvent, VotingCreationState> {
  VotingCreationBloc() : super(VotingCreationState());

  @override
  Stream<VotingCreationState> mapEventToState(
    VotingCreationEvent event,
  ) async* {
    // TODO: implement mapEventToState
  }
}
