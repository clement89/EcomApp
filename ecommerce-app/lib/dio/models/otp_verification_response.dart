// To parse this JSON data, do
//
//     final otpVerificationResponse = otpVerificationResponseFromJson(jsonString);

import 'dart:convert';

List<OtpVerificationResponse> otpVerificationResponseFromJson(String str) =>
    List<OtpVerificationResponse>.from(
        json.decode(str).map((x) => OtpVerificationResponse.fromJson(x)));

String otpVerificationResponseToJson(List<OtpVerificationResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class OtpVerificationResponse {
  OtpVerificationResponse(
      {this.status,
      this.verify,
      this.registerCustomer,
      this.token,
      this.lambdaCustomerToken});

  String status;
  bool verify;
  bool registerCustomer;
  String token;
  String lambdaCustomerToken;

  factory OtpVerificationResponse.fromJson(Map<String, dynamic> json) =>
      OtpVerificationResponse(
        status: (json["status"] ?? ""),
        verify: (json["verify"] ?? false),
        registerCustomer: (json["registerCustomer"] ?? false),
        token: (json["token"] ?? "").toString(),
        lambdaCustomerToken: (json["lambdaCustomerToken"] ?? "").toString(),
      );

  Map<String, dynamic> toJson() => {
        "status": status == null ? null : status,
        "verify": verify == null ? null : verify,
        "registerCustomer": registerCustomer == null ? null : registerCustomer,
        "token": token == null ? null : token,
        "lambdaCustomerToken":
            lambdaCustomerToken == null ? null : lambdaCustomerToken,
      };
}
