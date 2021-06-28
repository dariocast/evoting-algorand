part of 'voting_detail_bloc.dart';

class VotingDetailState extends Equatable {
  final Voting voting;
  final bool optedIn;
  final bool voted;
  final bool loading;
  final String assetName;

  const VotingDetailState({
    required this.voting,
    this.optedIn = false,
    this.voted = false,
    this.loading = true,
    this.assetName = '',
  });

  @override
  List<Object> get props => [voting, optedIn, voted, loading];

  Map<String, dynamic> toMap() {
    return {
      'voting': voting.toMap(),
      'optedIn': optedIn,
      'voted': voted,
      'loading': loading,
      'assetName': assetName,
    };
  }

  factory VotingDetailState.fromMap(Map<String, dynamic> map) {
    return VotingDetailState(
      voting: Voting.fromMap(map['voting']),
      optedIn: map['optedIn'],
      voted: map['voted'],
      loading: map['loading'],
      assetName: map['assetName'],
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
    String? assetName,
  }) {
    return VotingDetailState(
      voting: voting ?? this.voting,
      optedIn: optedIn ?? this.optedIn,
      voted: voted ?? this.voted,
      loading: loading ?? this.loading,
      assetName: assetName ?? this.assetName,
    );
  }
}
