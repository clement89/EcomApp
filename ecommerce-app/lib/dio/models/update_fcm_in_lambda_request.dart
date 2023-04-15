// To parse this JSON data, do
//
//     final updateFcmTokenInLambdaRequest = updateFcmTokenInLambdaRequestFromJson(jsonString);

import 'dart:convert';


UpdateFcmTokenInLambdaRequest updateFcmTokenInLambdaRequestFromJson(String str) => UpdateFcmTokenInLambdaRequest.fromJson(json.decode(str));

String updateFcmTokenInLambdaRequestToJson(UpdateFcmTokenInLambdaRequest data) => json.encode(data.toJson());

class UpdateFcmTokenInLambdaRequest {
  UpdateFcmTokenInLambdaRequest({
    this.fcmToken,
  });

  String fcmToken;

  factory UpdateFcmTokenInLambdaRequest.fromJson(Map<String, dynamic> json) => UpdateFcmTokenInLambdaRequest(
    fcmToken: json["fcmToken"] == null ? null : json["fcmToken"],
  );

  Map<String, dynamic> toJson() => {
    "fcmToken": fcmToken == null ? null : fcmToken,
  };
}
