// To parse this JSON data, do
//
//     final loginRequest = loginRequestFromJson(jsonString);

import 'dart:convert';

SampleRequest loginRequestFromJson(String str) => SampleRequest.fromJson(json.decode(str));

String loginRequestToJson(SampleRequest data) => json.encode(data.toJson());

class SampleRequest {
  SampleRequest({
    this.password,
    this.username,
  });

  final String password;
  final String username;

  factory SampleRequest.fromJson(Map<String, dynamic> json) => SampleRequest(
    password: json["password"] == null ? null : json["password"],
    username: json["username"] == null ? null : json["username"],
  );

  Map<String, dynamic> toJson() => {
    "password": password == null ? null : password,
    "username": username == null ? null : username,
  };
}
