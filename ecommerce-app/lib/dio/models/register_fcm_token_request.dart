// To parse this JSON data, do
//
//     final registerFcmTokenInLambdaRequest = registerFcmTokenInLambdaRequestFromJson(jsonString);

import 'dart:convert';

RegisterFcmTokenInLambdaRequest registerFcmTokenInLambdaRequestFromJson(String str) => RegisterFcmTokenInLambdaRequest.fromJson(json.decode(str));

String registerFcmTokenInLambdaRequestToJson(RegisterFcmTokenInLambdaRequest data) => json.encode(data.toJson());

class RegisterFcmTokenInLambdaRequest {
  RegisterFcmTokenInLambdaRequest({
    this.customerId,
    this.customerFirstName,
    this.customerLastName,
    this.customerEmail,
    this.customerPhoneNumber,
    this.customerFcmToken,
  });

  String customerId;
  String customerFirstName;
  String customerLastName;
  String customerEmail;
  String customerPhoneNumber;
  String customerFcmToken;

  factory RegisterFcmTokenInLambdaRequest.fromJson(Map<String, dynamic> json) => RegisterFcmTokenInLambdaRequest(
    customerId: json["customer_id"] == null ? null : json["customer_id"],
    customerFirstName: json["customer_first_name"] == null ? null : json["customer_first_name"],
    customerLastName: json["customer_last_name"] == null ? null : json["customer_last_name"],
    customerEmail: json["customer_email"] == null ? null : json["customer_email"],
    customerPhoneNumber: json["customer_phone_number"] == null ? null : json["customer_phone_number"],
    customerFcmToken: json["customer_fcm_token"] == null ? null : json["customer_fcm_token"],
  );

  Map<String, dynamic> toJson() => {
    "customer_id": customerId == null ? null : customerId,
    "customer_first_name": customerFirstName == null ? null : customerFirstName,
    "customer_last_name": customerLastName == null ? null : customerLastName,
    "customer_email": customerEmail == null ? null : customerEmail,
    "customer_phone_number": customerPhoneNumber == null ? null : customerPhoneNumber,
    "customer_fcm_token": customerFcmToken == null ? null : customerFcmToken,
  };
}
