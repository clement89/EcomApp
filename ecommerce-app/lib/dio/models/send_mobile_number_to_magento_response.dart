// To parse this JSON data, do
//
//     final sendMobileNumberToMagentoResponse = sendMobileNumberToMagentoResponseFromJson(jsonString);

import 'dart:convert';

List<SendMobileNumberToMagentoResponse> sendMobileNumberToMagentoResponseFromJson(String str) => List<SendMobileNumberToMagentoResponse>.from(json.decode(str).map((x) => SendMobileNumberToMagentoResponse.fromJson(x)));

String sendMobileNumberToMagentoResponseToJson(List<SendMobileNumberToMagentoResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SendMobileNumberToMagentoResponse {
  SendMobileNumberToMagentoResponse({
    this.status,
    this.message,
    this.lambdaCustomerToken,
    this.token,
  });

  String status;
  String message;
  String lambdaCustomerToken;
  String token;

  factory SendMobileNumberToMagentoResponse.fromJson(Map<String, dynamic> json) => SendMobileNumberToMagentoResponse(
    status: json["status"] == null ? null : json["status"],
    message: json["message"] == null ? null : json["message"],
    lambdaCustomerToken: json["lambdaCustomerToken"] == null ? null : json["lambdaCustomerToken"],
    token: json["token"] == null ? null : json["token"],
  );

  Map<String, dynamic> toJson() => {
    "status": status == null ? null : status,
    "message": message == null ? null : message,
    "lambdaCustomerToken": lambdaCustomerToken == null ? null : lambdaCustomerToken,
    "token": token == null ? null : token,
  };
}
