part of 'voting_detail_bloc.dart';

abstract class VotingDetailEvent extends Equatable {
  const VotingDetailEvent();

  @override
  List<Object> get props => [];
}

class VotingDetailOptedIn extends VotingDetailEvent {}

class VotingDetailVoted extends VotingDetailEvent {
  final String choice;

  VotingDetailVoted(this.choice);

  @override
  List<Object> get props => [choice];
}
