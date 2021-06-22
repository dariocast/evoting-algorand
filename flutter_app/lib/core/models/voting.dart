import 'dart:convert';

import 'package:equatable/equatable.dart';

class Voting extends Equatable {
  final String votingId;
  final List<String> options;
  final String title;
  final String? description;
  final DateTime regBegin;
  final DateTime regEnd;
  final DateTime voteBegin;
  final DateTime voteEnd;
  final int numSubscribers;
  final String requiredAsset;
  final String creator;

  Voting(
      this.votingId,
      this.options,
      this.title,
      this.description,
      this.regBegin,
      this.regEnd,
      this.voteBegin,
      this.voteEnd,
      this.numSubscribers,
      this.requiredAsset,
      this.creator);

  @override
  List<Object> get props {
    return [
      votingId,
      options,
      title,
      description ?? "",
      regBegin,
      regEnd,
      voteBegin,
      voteEnd,
      numSubscribers,
      requiredAsset,
      creator,
    ];
  }

  Map<String, dynamic> toMap() {
    return {
      'votingId': votingId,
      'options': options,
      'title': title,
      'description': description,
      'regBegin': regBegin.millisecondsSinceEpoch,
      'regEnd': regEnd.millisecondsSinceEpoch,
      'voteBegin': voteBegin.millisecondsSinceEpoch,
      'voteEnd': voteEnd.millisecondsSinceEpoch,
      'numSubscribers': numSubscribers,
      'requiredAsset': requiredAsset,
      'creator': creator,
    };
  }

  factory Voting.fromMap(Map<String, dynamic> map) {
    return Voting(
      map['votingId'],
      List<String>.from(map['options']),
      map['title'],
      map['description'],
      DateTime.parse(map['regBegin']),
      DateTime.parse(map['regEnd']),
      DateTime.parse(map['voteBegin']),
      DateTime.parse(map['voteEnd']),
      map['numSubscribers'],
      map['requiredAsset'],
      map['creator'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Voting.fromJson(String source) => Voting.fromMap(json.decode(source));
}
