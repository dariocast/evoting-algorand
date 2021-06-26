part of 'voting_detail_bloc.dart';

class VotingDetailState extends Equatable {
  final Voting voting;
  final bool optedIn;
  final bool voted;
  final bool loading;

  const VotingDetailState({
    required this.voting,
    this.optedIn = false,
    this.voted = false,
    this.loading = true,
  });

  @override
  List<Object> get props => [voting, optedIn, voted, loading];

  Map<String, dynamic> toMap() {
    return {
      'voting': voting.toMap(),
      'optedIn': optedIn,
      'voted': voted,
      'loading': loading,
    };
  }

  factory VotingDetailState.fromMap(Map<String, dynamic> map) {
    return VotingDetailState(
      voting: Voting.fromMap(map['voting']),
      optedIn: map['optedIn'],
      voted: map['voted'],
      loading: map['loading'],
    );
  }

  String toJson() => json.encode(toMap());

  factory VotingDetailState.fromJson(String source) =>
      VotingDetailState.fromMap(json.decode(source));

  VotingDetailState copyWith({
    Voting? voting,
    bool? optedIn,
    bool? voted,
    bool? loading,
  }) {
    return VotingDetailState(
      voting: voting ?? this.voting,
      optedIn: optedIn ?? this.optedIn,
      voted: voted ?? this.voted,
      loading: loading ?? this.loading,
    );
  }
}
