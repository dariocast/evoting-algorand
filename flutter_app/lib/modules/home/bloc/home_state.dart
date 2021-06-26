part of 'home_bloc.dart';

class HomeState extends Equatable {
  final String passphrase;
  // Opted in votings
  final List<Voting> votings;
  final bool loading;

  HomeState({
    this.passphrase = "",
    this.votings = const [],
    this.loading = true,
  });

  @override
  List<Object> get props => [passphrase, votings, loading];

  HomeState copyWith({
    String? passphrase,
    List<Voting>? votings,
    bool? loading,
  }) {
    return HomeState(
      passphrase: passphrase ?? this.passphrase,
      votings: votings ?? this.votings,
      loading: loading ?? true,
    );
  }
}
