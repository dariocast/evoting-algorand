import 'dart:convert';
import 'dart:core';
import 'package:algorand_evoting/constants/api_path.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;

class RestApiService {
  static Future<RestApiResponse> getAllVoting() async {
    final response = await http.get(Uri.parse(votingEndpoint));
    return RestApiResponse.fromJson(response.body);
  }

  static Future<RestApiResponse> getVoting(String id) async {
    final response = await http.get(Uri.parse(votingEndpoint + '/$id'));
    return RestApiResponse.fromJson(response.body);
  }

  static Future<RestApiResponse> deleteVoting(
    String id,
    String passphrase,
  ) async {
    final response = await http.delete(
      Uri.parse(votingEndpoint + '/$id'),
      body: {'passphrase': passphrase},
    );
    return RestApiResponse.fromJson(response.body);
  }

  static Future<RestApiResponse> createVoting(Map voting) async {
    final response = await http.post(
      Uri.parse(votingEndpoint),
      body: voting,
    );
    return RestApiResponse.fromJson(response.body);
  }

  static Future<RestApiResponse> registerForVoting(
    String id,
    String passphrase,
  ) async {
    final response = await http.post(
      Uri.parse(votingOptInEndpoint + '/$id'),
      body: {'passphrase': passphrase},
    );
    return RestApiResponse.fromJson(response.body);
  }

  static Future<RestApiResponse> voteForVoting(
    String id,
    String passphrase,
    String choice,
  ) async {
    final response = await http.post(
      Uri.parse(votingOptInEndpoint + '/$id'),
      body: {'passphrase': passphrase, 'choice': choice},
    );
    return RestApiResponse.fromJson(response.body);
  }
}

class RestApiResponse extends Equatable {
  final String? message;
  final dynamic data;
  final int status;
  final String? exception;
  final String? errors;

  RestApiResponse(
      this.message, this.data, this.status, this.exception, this.errors);

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'data': data,
      'statusCode': status,
      'exception': exception,
      'errors': errors,
    };
  }

  factory RestApiResponse.fromMap(Map<String, dynamic> map) {
    return RestApiResponse(
      map['message'],
      map['data'],
      map['status'],
      map['exception'],
      map['errors'],
    );
  }

  String toJson() => json.encode(toMap());

  factory RestApiResponse.fromJson(String source) =>
      RestApiResponse.fromMap(json.decode(source));

  @override
  List<Object?> get props => [message, data, status, exception, errors];

  @override
  bool? get stringify => true;
}

enum RestApiOperation {
  create,
  get,
  delete,
  register,
  vote,
}

class RestApiException {
  final String message;

  RestApiException({required this.message});
}
