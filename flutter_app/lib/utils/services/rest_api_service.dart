import 'dart:convert';
import 'dart:core';
import 'package:algorand_evoting/constants/api_path.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;

class RestApiService {
  static Future<RestApiResponse> getAllVoting() async {
    try {
      final response = await http.get(Uri.parse(votingEndpoint));
      return RestApiResponse.fromJson(response.body);
    } catch (e) {
      print(e);
      return RestApiResponse.httpFailure(500, e.toString());
    }
  }

  static Future<RestApiResponse> getVoting(String id) async {
    try {
      final response = await http.get(Uri.parse(votingEndpoint + '/$id'));
      return RestApiResponse.fromJson(response.body);
    } catch (e) {
      print(e);
      return RestApiResponse.httpFailure(500, e.toString());
    }
  }

  static Future<RestApiResponse> deleteVoting(
    String id,
    String passphrase,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse(votingEndpoint + '/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'passphrase': passphrase}),
      );
      return RestApiResponse.fromJson(response.body);
    } catch (e) {
      print(e);
      return RestApiResponse.httpFailure(500, e.toString());
    }
  }

  static Future<RestApiResponse> createVoting(String encodedVoting) async {
    try {
      final response = await http.post(
        Uri.parse(votingEndpoint),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: encodedVoting,
      );
      return RestApiResponse.fromJson(response.body);
    } catch (e) {
      print(e);
      return RestApiResponse.httpFailure(500, e.toString());
    }
  }

  static Future<RestApiResponse> registerForVoting(
    String id,
    String passphrase,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(votingOptInEndpoint + '/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'passphrase': passphrase}),
      );
      return RestApiResponse.fromJson(response.body);
    } catch (e) {
      print(e);
      return RestApiResponse.httpFailure(500, e.toString());
    }
  }

  static Future<RestApiResponse> voteForVoting(
    String id,
    String passphrase,
    String choice,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(votingVoteEndpoint + '/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'passphrase': passphrase, 'choice': choice}),
      );
      return RestApiResponse.fromJson(response.body);
    } catch (e) {
      print(e);
      return RestApiResponse.httpFailure(500, e.toString());
    }
  }

  static Future<RestApiResponse> votingLocalState(
    String id,
    String address,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(votingStateEndpoint + '/$id/$address'),
      );
      return RestApiResponse.fromJson(response.body);
    } catch (e) {
      print(e);
      return RestApiResponse.httpFailure(500, e.toString());
    }
  }

  static Future<RestApiResponse> votingGlobalState(String id) async {
    try {
      final response = await http.get(
        Uri.parse(votingStateEndpoint + '/$id'),
      );
      return RestApiResponse.fromJson(response.body);
    } catch (e) {
      print(e);
      return RestApiResponse.httpFailure(500, e.toString());
    }
  }
}

class RestApiResponse extends Equatable {
  final String? message;
  final dynamic data;
  final int status;
  final String? exception;
  final String? errors;

  RestApiResponse(
      {this.message,
      this.data,
      this.status = 200,
      this.exception,
      this.errors});

  RestApiResponse.httpFailure(int status, String exception)
      : this(status: status, exception: exception);

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
      message: map['message'],
      data: map['data'],
      status: map['status'],
      exception: map['exception'],
      errors: map['errors'],
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
