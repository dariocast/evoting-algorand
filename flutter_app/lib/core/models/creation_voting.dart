import 'package:equatable/equatable.dart';

class CreationVoting extends Equatable {
  final int assetId;
  final String title;
  final String description;
  final List<String> options;
  final String regBegin;
  final String regEnd;
  final String voteBegin;
  final String voteEnd;

  CreationVoting(this.assetId, this.title, this.description, this.options,
      this.regBegin, this.regEnd, this.voteBegin, this.voteEnd);

  @override
  List<Object?> get props => [assetId];
}
