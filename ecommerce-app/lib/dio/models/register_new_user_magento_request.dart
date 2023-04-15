// To parse this JSON data, do
//
//     final registerNewUserMagentoRequest = registerNewUserMagentoRequestFromJson(jsonString);

import 'dart:convert';

RegisterNewUserMagentoRequest registerNewUserMagentoRequestFromJson(String str) => RegisterNewUserMagentoRequest.fromJson(json.decode(str));

String registerNewUserMagentoRequestToJson(RegisterNewUserMagentoRequest data) => json.encode(data.toJson());

class RegisterNewUserMagentoRequest {
  RegisterNewUserMagentoRequest({
    this.customer,
  });

  Customer customer;

  factory RegisterNewUserMagentoRequest.fromJson(Map<String, dynamic> json) => RegisterNewUserMagentoRequest(
    customer: json["customer"] == null ? null : Customer.fromJson(json["customer"]),
  );

  Map<String, dynamic> toJson() => {
    "customer": customer == null ? null : customer.toJson(),
  };
}

class Customer {
  Customer({
    this.email,
    this.name,
    this.mobilenumber,
    this.otp,
  });

  String email;
  String name;
  String mobilenumber;
  int otp;

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    email: json["email"] == null ? null : json["email"],
    name: json["name"] == null ? null : json["name"],
    mobilenumber: json["mobilenumber"] == null ? null : json["mobilenumber"],
    otp: json["otp"] == null ? null : json["otp"],
  );

  Map<String, dynamic> toJson() => {
    "email": email == null ? null : email,
    "name": name == null ? null : name,
    "mobilenumber": mobilenumber == null ? null : mobilenumber,
    "otp": otp == null ? null : otp,
  };
}
