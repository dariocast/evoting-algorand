part of 'voting_creation_bloc.dart';

class VotingCreationState extends Equatable {
  final AssetInput assetId;
  final List<Asset>? availableAssets;
  final TextInput description;
  final TextInput title;
  final TextInput optionOne;
  final TextInput optionTwo;
  final DateInput regBegin;
  final DateInput regEnd;
  final DateInput voteBegin;
  final DateInput voteEnd;
  final FormzStatus status;

  const VotingCreationState({
    this.status = FormzStatus.pure,
    this.availableAssets,
    this.assetId = const AssetInput.pure(),
    this.description = const TextInput.pure(),
    this.title = const TextInput.pure(),
    this.optionOne = const TextInput.pure(),
    this.optionTwo = const TextInput.pure(),
    this.regBegin = const DateInput.pure(),
    this.regEnd = const DateInput.pure(),
    this.voteBegin = const DateInput.pure(),
    this.voteEnd = const DateInput.pure(),
  });

  @override
  List<Object?> get props => [
        title,
        description,
        optionOne,
        optionTwo,
        assetId,
        regBegin,
        regEnd,
        voteBegin,
        voteEnd,
        availableAssets,
        status,
      ];

  VotingCreationState copyWith({
    AssetInput? assetId,
    TextInput? description,
    TextInput? title,
    TextInput? optionOne,
    TextInput? optionTwo,
    DateInput? regBegin,
    DateInput? regEnd,
    DateInput? voteBegin,
    DateInput? voteEnd,
    List<Asset>? availableAssets,
    FormzStatus? status,
  }) {
    return VotingCreationState(
      assetId: assetId ?? this.assetId,
      description: description ?? this.description,
      title: title ?? this.title,
      optionOne: optionOne ?? this.optionOne,
      optionTwo: optionTwo ?? this.optionTwo,
      regBegin: regBegin ?? this.regBegin,
      regEnd: regEnd ?? this.regEnd,
      voteBegin: voteBegin ?? this.voteBegin,
      voteEnd: voteEnd ?? this.voteEnd,
      availableAssets: availableAssets ?? this.availableAssets,
      status: status ?? this.status,
    );
  }
}
