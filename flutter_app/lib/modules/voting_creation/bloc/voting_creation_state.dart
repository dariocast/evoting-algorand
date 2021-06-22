part of 'voting_creation_bloc.dart';

class VotingCreationState extends Equatable {
  final TextInput assetId;
  final TextInput description;
  final TextInput title;
  final List<TextInput> options;
  final DateInput regBegin;
  final DateInput regEnd;
  final DateInput voteBegin;
  final DateInput voteEnd;
  final FormzStatus status;

  const VotingCreationState({
    this.status = FormzStatus.pure,
    this.assetId = const TextInput.pure(),
    this.description = const TextInput.pure(),
    this.title = const TextInput.pure(),
    this.options = const [],
    this.regBegin = const DateInput.pure(),
    this.regEnd = const DateInput.pure(),
    this.voteBegin = const DateInput.pure(),
    this.voteEnd = const DateInput.pure(),
  });

  @override
  List<Object?> get props => [
        title,
        description,
        options,
        assetId,
        regBegin,
        regEnd,
        voteBegin,
        voteEnd
      ];

  VotingCreationState copyWith({
    TextInput? assetId,
    TextInput? description,
    TextInput? title,
    List<TextInput>? options,
    DateInput? regBegin,
    DateInput? regEnd,
    DateInput? voteBegin,
    DateInput? voteEnd,
  }) {
    return VotingCreationState(
      assetId: assetId ?? this.assetId,
      description: description ?? this.description,
      title: title ?? this.title,
      options: options ?? this.options,
      regBegin: regBegin ?? this.regBegin,
      regEnd: regEnd ?? this.regEnd,
      voteBegin: voteBegin ?? this.voteBegin,
      voteEnd: voteEnd ?? this.voteEnd,
    );
  }
}
