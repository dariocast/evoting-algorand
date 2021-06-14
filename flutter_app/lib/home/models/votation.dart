import 'dart:convert';

import 'package:equatable/equatable.dart';

class Voting extends Equatable {
  final List<String> options;
  final String question;
  final String? description;

  Voting({required this.options, required this.question, this.description});

  @override
  List<Object> get props => [options, question, description ?? ''];

  Voting copyWith({
    List<String>? options,
    String? question,
    String? description,
  }) {
    return Voting(
      options: options ?? this.options,
      question: question ?? this.question,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'options': options,
      'question': question,
      'description': description,
    };
  }

  factory Voting.fromMap(Map<String, dynamic> map) {
    return Voting(
      options: List<String>.from(map['options']),
      question: map['question'],
      description: map['description'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Voting.fromJson(String source) => Voting.fromMap(json.decode(source));
}
