// To parse this JSON data, do
//
//     final headerModel = headerModelFromJson(jsonString);

import 'dart:convert';

HeaderModel headerModelFromJson(String str) =>
    HeaderModel.fromJson(json.decode(str));

String headerModelToJson(HeaderModel data) => json.encode(data.toJson());

class HeaderModel {
  HeaderModel({
    this.authorization,
    this.accessToken,
  });

  String authorization;
  String accessToken;

  factory HeaderModel.fromJson(Map<String, dynamic> json) => HeaderModel(
        authorization:
            json["Authorization"] == null ? null : json["Authorization"],
      );

  Map<String, dynamic> toJson() => {
        "Authorization": authorization == null ? null : authorization,
      };
}
