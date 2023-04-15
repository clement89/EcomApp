import 'dart:convert';
// To parse this JSON data, do
//
//     final shippingEstimation = shippingEstimationFromJson(jsonString);

ShippingEstimation shippingEstimationFromJson(String str) =>
    ShippingEstimation.fromJson(json.decode(str));

class ShippingEstimation {
  ShippingEstimation({
    this.minSubTotal,
    this.shippingCharges,
    this.couponMinAmount,
    this.couponType,
    this.couponApplied,
    this.editOrderMinSubTotal,
    this.shippingChargeLimit,
  });

  String minSubTotal;
  String shippingCharges;
  String couponMinAmount;
  String couponType;
  String editOrderMinSubTotal;
  String shippingChargeLimit;
  bool couponApplied;

  factory ShippingEstimation.fromJson(Map<String, dynamic> json) =>
      ShippingEstimation(
        minSubTotal:
            json["minSubTotal"] != null ? json["minSubTotal"].toString() : "0",
        shippingCharges: json["shippingCharges"] != null
            ? json["shippingCharges"].toString()
            : '0',
        couponMinAmount: json["couponMinAmount"] != null
            ? json["couponMinAmount"].toString()
            : '0',
        couponType:
            json["couponType"] != null ? json["couponType"].toString() : '0',
        couponApplied: json["couponApplied"] ?? false,
        editOrderMinSubTotal: json["editOrderMinSubTotal"] ?? "0",
        shippingChargeLimit: json["shippingChargeLimit"] ?? "0",
      );
}
