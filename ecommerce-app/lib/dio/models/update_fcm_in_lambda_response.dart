// To parse this JSON data, do
//
//     final updateFcmTokenInLambdaResponse = updateFcmTokenInLambdaResponseFromJson(jsonString);

import 'dart:convert';

UpdateFcmTokenInLambdaResponse updateFcmTokenInLambdaResponseFromJson(String str) => UpdateFcmTokenInLambdaResponse.fromJson(json.decode(str));

String updateFcmTokenInLambdaResponseToJson(UpdateFcmTokenInLambdaResponse data) => json.encode(data.toJson());

class UpdateFcmTokenInLambdaResponse {
  UpdateFcmTokenInLambdaResponse({
    this.data,
    this.message,
    this.source,
    this.success,
  });

  Data data;
  String message;
  String source;
  bool success;

  factory UpdateFcmTokenInLambdaResponse.fromJson(Map<String, dynamic> json) => UpdateFcmTokenInLambdaResponse(
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    message: json["message"] == null ? null : json["message"],
    source: json["source"] == null ? null : json["source"],
    success: json["success"] == null ? null : json["success"],
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? null : data.toJson(),
    "message": message == null ? null : message,
    "source": source == null ? null : source,
    "success": success == null ? null : success,
  };
}

class Data {
  Data();

  factory Data.fromJson(Map<String, dynamic> json) => Data(
  );

  Map<String, dynamic> toJson() => {
  };
}
