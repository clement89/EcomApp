// To parse this JSON data, do
//
//     final registerNewUserMagentoResponse = registerNewUserMagentoResponseFromJson(jsonString);

import 'dart:convert';

List<RegisterNewUserMagentoResponse> registerNewUserMagentoResponseFromJson(
        String str) =>
    List<RegisterNewUserMagentoResponse>.from(json
        .decode(str)
        .map((x) => RegisterNewUserMagentoResponse.fromJson(x)));

String registerNewUserMagentoResponseToJson(
        List<RegisterNewUserMagentoResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RegisterNewUserMagentoResponse {
  RegisterNewUserMagentoResponse({
    this.status,
    this.token,
    this.lambdaCustomerToken,
  });

  String status;
  String token;
  String lambdaCustomerToken;

  factory RegisterNewUserMagentoResponse.fromJson(Map<String, dynamic> json) =>
      RegisterNewUserMagentoResponse(
        status: (json["status"] ?? ""),
        token: (json["token"] ?? ""),
        lambdaCustomerToken: (json["lambdaCustomerToken"] ?? ""),
      );

  Map<String, dynamic> toJson() => {
        "status": status == null ? null : status,
        "token": token == null ? null : token,
        "lambdaCustomerToken":
            lambdaCustomerToken == null ? null : lambdaCustomerToken,
      };
}
