// To parse this JSON data, do
//
//     final checkIfUserAreaServiceable = checkIfUserAreaServiceableFromJson(jsonString);

import 'dart:convert';

import 'package:meta/meta.dart';

CheckIfUserAreaServiceableRequest checkIfUserAreaServiceableFromJson(String str) => CheckIfUserAreaServiceableRequest.fromJson(json.decode(str));

String checkIfUserAreaServiceableToJson(CheckIfUserAreaServiceableRequest data) => json.encode(data.toJson());

class CheckIfUserAreaServiceableRequest {
  CheckIfUserAreaServiceableRequest({
    @required this.userLat,
    @required this.userLn,
  });

  double userLat;
  double userLn;

  factory CheckIfUserAreaServiceableRequest.fromJson(Map<String, dynamic> json) => CheckIfUserAreaServiceableRequest(
    userLat: json["userLat"].toDouble,
    userLn: json["userLn"].toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "userLat": userLat,
    "userLn": userLn,
  };
}
