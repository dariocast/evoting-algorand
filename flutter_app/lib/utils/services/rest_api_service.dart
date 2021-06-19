import 'dart:convert';
import 'dart:core';
import 'package:algorand_evoting/constants/api_path.dart';
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
}

class RestApiResponse {
  final String? message;
  final Map? data;
  final int statusCode;
  final String? exception;
  final String? errors;

  RestApiResponse(
      this.message, this.data, this.statusCode, this.exception, this.errors);

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'data': data,
      'statusCode': statusCode,
      'exception': exception,
      'errors': errors,
    };
  }

  factory RestApiResponse.fromMap(Map<String, dynamic> map) {
    return RestApiResponse(
      map['message'],
      map['data'],
      map['statusCode'],
      map['exception'],
      map['errors'],
    );
  }

  String toJson() => json.encode(toMap());

  factory RestApiResponse.fromJson(String source) =>
      RestApiResponse.fromMap(json.decode(source));
}
