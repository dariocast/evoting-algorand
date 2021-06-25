part of 'voting_creation_bloc.dart';

abstract class VotingCreationEvent extends Equatable {
  const VotingCreationEvent();

  @override
  List<Object?> get props => [];
}

class VotingCreationStarted extends VotingCreationEvent {}

class VotingCreationAssetIdChanged extends VotingCreationEvent {
  final Asset? assetId;

  const VotingCreationAssetIdChanged(this.assetId);

  @override
  List<Object?> get props => [assetId];
}

class VotingCreationTitleChanged extends VotingCreationEvent {
  final String title;

  const VotingCreationTitleChanged(this.title);

  @override
  List<Object> get props => [title];
}

class VotingCreationDescriptionChanged extends VotingCreationEvent {
  final String description;

  const VotingCreationDescriptionChanged(this.description);

  @override
  List<Object> get props => [description];
}

class VotingCreationOptOneChanged extends VotingCreationEvent {
  final String opt;

  const VotingCreationOptOneChanged(this.opt);

  @override
  List<Object> get props => [opt];
}

class VotingCreationOptTwoChanged extends VotingCreationEvent {
  final String opt;

  const VotingCreationOptTwoChanged(this.opt);

  @override
  List<Object> get props => [opt];
}

class VotingCreationRegBeginChanged extends VotingCreationEvent {
  final DateTime date;

  const VotingCreationRegBeginChanged(this.date);

  @override
  List<Object> get props => [date];
}

class VotingCreationRegEndChanged extends VotingCreationEvent {
  final DateTime date;

  const VotingCreationRegEndChanged(this.date);

  @override
  List<Object> get props => [date];
}

class VotingCreationVoteBeginChanged extends VotingCreationEvent {
  final DateTime date;

  const VotingCreationVoteBeginChanged(this.date);

  @override
  List<Object> get props => [date];
}

class VotingCreationVoteEndChanged extends VotingCreationEvent {
  final DateTime date;

  const VotingCreationVoteEndChanged(this.date);

  @override
  List<Object> get props => [date];
}

class VotingCreationSubmitted extends VotingCreationEvent {
  const VotingCreationSubmitted();
}
