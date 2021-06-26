part of 'voting_detail_bloc.dart';

class VotingDetailState extends Equatable {
  final Voting voting;
  final bool optedIn;
  final bool voted;

  const VotingDetailState({
    required this.voting,
    this.optedIn = false,
    this.voted = false,
  });

  @override
  List<Object> get props => [voting, optedIn, voted];

  Map<String, dynamic> toMap() {
    return {
      'voting': voting.toMap(),
      'optedIn': optedIn,
      'voted': voted,
    };
  }

  factory VotingDetailState.fromMap(Map<String, dynamic> map) {
    return VotingDetailState(
      voting: Voting.fromMap(map['voting']),
      optedIn: map['optedIn'],
      voted: map['voted'],
    );
  }

  String toJson() => json.encode(toMap());

  factory VotingDetailState.fromJson(String source) =>
      VotingDetailState.fromMap(json.decode(source));

  VotingDetailState copyWith({
    Voting? voting,
    bool? optedIn,
    bool? voted,
  }) {
    return VotingDetailState(
      voting: voting ?? this.voting,
      optedIn: optedIn ?? this.optedIn,
      voted: voted ?? this.voted,
    );
  }
}
