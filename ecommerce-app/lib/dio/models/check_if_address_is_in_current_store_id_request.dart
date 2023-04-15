// To parse this JSON data, do
//
//     final checkIfUserAreaServiceable = checkIfUserAreaServiceableFromJson(jsonString);

import 'dart:convert';

import 'package:meta/meta.dart';

CheckIIfAddressIsInCurrentStoreIdRequest checkIfUserAreaServiceableFromJson(String str) => CheckIIfAddressIsInCurrentStoreIdRequest.fromJson(json.decode(str));

String checkIfUserAreaServiceableToJson(CheckIIfAddressIsInCurrentStoreIdRequest data) => json.encode(data.toJson());

class CheckIIfAddressIsInCurrentStoreIdRequest {
  CheckIIfAddressIsInCurrentStoreIdRequest({
    @required this.userLat,
    @required this.userLn,
  });

  double userLat;
  double userLn;

  factory CheckIIfAddressIsInCurrentStoreIdRequest.fromJson(Map<String, dynamic> json) => CheckIIfAddressIsInCurrentStoreIdRequest(
    userLat: json["userLat"].toDouble,
    userLn: json["userLn"].toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "userLat": userLat,
    "userLn": userLn,
  };
}
