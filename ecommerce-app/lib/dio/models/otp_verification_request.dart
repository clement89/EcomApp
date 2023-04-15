// To parse this JSON data, do
//
//     final otpVerificationRequest = otpVerificationRequestFromJson(jsonString);

import 'dart:convert';

OtpVerificationRequest otpVerificationRequestFromJson(String str) => OtpVerificationRequest.fromJson(json.decode(str));

String otpVerificationRequestToJson(OtpVerificationRequest data) => json.encode(data.toJson());

class OtpVerificationRequest {
  OtpVerificationRequest({
    this.customer,
  });

  CustomerDetails customer;

  factory OtpVerificationRequest.fromJson(Map<String, dynamic> json) => OtpVerificationRequest(
    customer: json["customer"] == null ? null : CustomerDetails.fromJson(json["customer"]),
  );

  Map<String, dynamic> toJson() => {
    "customer": customer == null ? null : customer.toJson(),
  };
}

class CustomerDetails {
  CustomerDetails({
    this.mobilenumber,
    this.otp,
  });

  String mobilenumber;
  String otp;

  factory CustomerDetails.fromJson(Map<String, dynamic> json) => CustomerDetails(
    mobilenumber: json["mobilenumber"] == null ? null : json["mobilenumber"],
    otp: json["otp"] == null ? null : json["otp"],
  );

  Map<String, dynamic> toJson() => {
    "mobilenumber": mobilenumber == null ? null : mobilenumber,
    "otp": otp == null ? null : otp,
  };
}
