part of 'home_bloc.dart';

class HomeState extends Equatable {
  final String passphrase;
  final List<Voting> votings;
  final bool loading;
  final List<SimpleAsset> assets;

  HomeState({
    this.passphrase = "",
    this.votings = const [],
    this.loading = true,
    this.assets = const [],
  });

  @override
  List<Object> get props => [passphrase, votings, assets, loading];

  HomeState copyWith({
    String? passphrase,
    List<Voting>? votings,
    List<SimpleAsset>? assets,
    bool? loading,
  }) {
    return HomeState(
      passphrase: passphrase ?? this.passphrase,
      votings: votings ?? this.votings,
      assets: assets ?? this.assets,
      loading: loading ?? true,
    );
  }
}
