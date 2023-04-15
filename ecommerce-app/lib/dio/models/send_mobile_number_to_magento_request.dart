// To parse this JSON data, do
//
//     final sendMobileNumberToMagentoRequest = sendMobileNumberToMagentoRequestFromJson(jsonString);

import 'dart:convert';

SendMobileNumberToMagentoRequest sendMobileNumberToMagentoRequestFromJson(String str) => SendMobileNumberToMagentoRequest.fromJson(json.decode(str));

String sendMobileNumberToMagentoRequestToJson(SendMobileNumberToMagentoRequest data) => json.encode(data.toJson());

class SendMobileNumberToMagentoRequest {
  SendMobileNumberToMagentoRequest({
    this.mobilenumber,
  });

  String mobilenumber;

  factory SendMobileNumberToMagentoRequest.fromJson(Map<String, dynamic> json) => SendMobileNumberToMagentoRequest(
    mobilenumber: json["mobilenumber"] == null ? null : json["mobilenumber"],
  );

  Map<String, dynamic> toJson() => {
    "mobilenumber": mobilenumber == null ? null : mobilenumber,
  };
}
