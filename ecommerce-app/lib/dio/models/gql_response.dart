// To parse this JSON data, do
//
//     final gqlResponse = gqlResponseFromJson(jsonString);

import 'dart:convert';

GqlResponse gqlResponseFromJson(String str) => GqlResponse.fromJson(json.decode(str));

String gqlResponseToJson(GqlResponse data) => json.encode(data.toJson());

class GqlResponse {
  GqlResponse({
    this.data,
  });

  Data data;

  factory GqlResponse.fromJson(Map<String, dynamic> json) => GqlResponse(
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? null : data.toJson(),
  };
}

class Data {
  Data({
    this.cart,
  });

  Cart cart;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    cart: json["cart"] == null ? null : Cart.fromJson(json["cart"]),
  );

  Map<String, dynamic> toJson() => {
    "cart": cart == null ? null : cart.toJson(),
  };
}

class Cart {
  Cart({
    this.email,
    this.billingAddress,
    this.shippingAddresses,
    this.items,
    this.availablePaymentMethods,
    this.selectedPaymentMethod,
    this.appliedCoupons,
    this.prices,
  });

  String email;
  dynamic billingAddress;
  List<dynamic> shippingAddresses;
  List<dynamic> items;
  List<PaymentMethod> availablePaymentMethods;
  PaymentMethod selectedPaymentMethod;
  dynamic appliedCoupons;
  Prices prices;

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
    email: json["email"] == null ? null : json["email"],
    billingAddress: json["billing_address"],
    shippingAddresses: json["shipping_addresses"] == null ? null : List<dynamic>.from(json["shipping_addresses"].map((x) => x)),
    items: json["items"] == null ? null : List<dynamic>.from(json["items"].map((x) => x)),
    availablePaymentMethods: json["available_payment_methods"] == null ? null : List<PaymentMethod>.from(json["available_payment_methods"].map((x) => PaymentMethod.fromJson(x))),
    selectedPaymentMethod: json["selected_payment_method"] == null ? null : PaymentMethod.fromJson(json["selected_payment_method"]),
    appliedCoupons: json["applied_coupons"],
    prices: json["prices"] == null ? null : Prices.fromJson(json["prices"]),
  );

  Map<String, dynamic> toJson() => {
    "email": email == null ? null : email,
    "billing_address": billingAddress,
    "shipping_addresses": shippingAddresses == null ? null : List<dynamic>.from(shippingAddresses.map((x) => x)),
    "items": items == null ? null : List<dynamic>.from(items.map((x) => x)),
    "available_payment_methods": availablePaymentMethods == null ? null : List<dynamic>.from(availablePaymentMethods.map((x) => x.toJson())),
    "selected_payment_method": selectedPaymentMethod == null ? null : selectedPaymentMethod.toJson(),
    "applied_coupons": appliedCoupons,
    "prices": prices == null ? null : prices.toJson(),
  };
}

class PaymentMethod {
  PaymentMethod({
    this.code,
    this.title,
  });

  String code;
  String title;

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => PaymentMethod(
    code: json["code"] == null ? null : json["code"],
    title: json["title"] == null ? null : json["title"],
  );

  Map<String, dynamic> toJson() => {
    "code": code == null ? null : code,
    "title": title == null ? null : title,
  };
}

class Prices {
  Prices({
    this.grandTotal,
  });

  GrandTotal grandTotal;

  factory Prices.fromJson(Map<String, dynamic> json) => Prices(
    grandTotal: json["grand_total"] == null ? null : GrandTotal.fromJson(json["grand_total"]),
  );

  Map<String, dynamic> toJson() => {
    "grand_total": grandTotal == null ? null : grandTotal.toJson(),
  };
}

class GrandTotal {
  GrandTotal({
    this.value,
    this.currency,
  });

  int value;
  String currency;

  factory GrandTotal.fromJson(Map<String, dynamic> json) => GrandTotal(
    value: json["value"] == null ? null : json["value"],
    currency: json["currency"] == null ? null : json["currency"],
  );

  Map<String, dynamic> toJson() => {
    "value": value == null ? null : value,
    "currency": currency == null ? null : currency,
  };
}
