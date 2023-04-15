// To parse this JSON data, do
//
//     final checkIfUserAreaServiceableResponse = checkIfUserAreaServiceableResponseFromJson(jsonString);

import 'dart:convert';

CheckIfUserAreaServiceableResponse checkIfUserAreaServiceableResponseFromJson(
        String str) =>
    CheckIfUserAreaServiceableResponse.fromJson(json.decode(str));

String checkIfUserAreaServiceableResponseToJson(
        CheckIfUserAreaServiceableResponse data) =>
    json.encode(data.toJson());

class CheckIfUserAreaServiceableResponse {
  CheckIfUserAreaServiceableResponse({
    this.data,
    this.message,
    this.source,
    this.success,
  });

  Data data;
  String message;
  String source;
  bool success;

  factory CheckIfUserAreaServiceableResponse.fromJson(
          Map<String, dynamic> json) =>
      CheckIfUserAreaServiceableResponse(
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
  Data({
    this.isPointInPolygon,
    this.websiteId,
    this.websiteCode,
    this.websiteName,
    this.sapWebsiteId,
    this.stores,
    this.minSubTotal,
    this.shippingCharge,
    this.editOrderMinSubTotal,
  });

  bool isPointInPolygon;
  String websiteId;
  String websiteCode;
  String websiteName;
  String sapWebsiteId;
  List<Store> stores;

  //CJC added
  String minSubTotal;
  String shippingCharge;
  String editOrderMinSubTotal;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        isPointInPolygon:
            json["isPointInPolygon"] == null ? null : json["isPointInPolygon"],
        websiteId: json["website_id"] == null ? null : json["website_id"],
        websiteCode: json["website_code"] == null ? null : json["website_code"],
        websiteName: json["website_name"] == null ? null : json["website_name"],
        sapWebsiteId:
            json["sap_website_id"] == null ? null : json["sap_website_id"],
        stores: json["stores"] == null
            ? null
            : List<Store>.from(json["stores"].map((x) => Store.fromJson(x))),
        minSubTotal: json["min_sub_total"] == null
            ? ''
            : json["min_sub_total"].toString(),
        shippingCharge: json["shipping_charges"] == null
            ? ''
            : json["shipping_charges"].toString(),
        editOrderMinSubTotal: json["edit_order_min_sub_total"] == null
            ? ''
            : json["edit_order_min_sub_total"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "isPointInPolygon": isPointInPolygon == null ? null : isPointInPolygon,
        "website_id": websiteId == null ? null : websiteId,
        "website_code": websiteCode == null ? null : websiteCode,
        "website_name": websiteName == null ? null : websiteName,
        "sap_website_id": sapWebsiteId == null ? null : sapWebsiteId,
        "stores": stores == null
            ? null
            : List<dynamic>.from(stores.map((x) => x.toJson())),
        "min_sub_total": minSubTotal == null ? null : minSubTotal,
        "shipping_charges": shippingCharge == null ? null : shippingCharge,
        "edit_order_min_sub_total":
            editOrderMinSubTotal == null ? null : editOrderMinSubTotal,
      };
}

class Store {
  Store({
    this.storeId,
    this.storeCode,
    this.storeName,
    this.isActive,
  });

  String storeId;
  String storeCode;
  String storeName;
  String isActive;

  factory Store.fromJson(Map<String, dynamic> json) => Store(
        storeId: json["store_id"] == null ? null : json["store_id"],
        storeCode: json["store_code"] == null ? null : json["store_code"],
        storeName: json["store_name"] == null ? null : json["store_name"],
        isActive: json["is_active"] == null ? null : json["is_active"],
      );

  Map<String, dynamic> toJson() => {
        "store_id": storeId == null ? null : storeId,
        "store_code": storeCode == null ? null : storeCode,
        "store_name": storeName == null ? null : storeName,
        "is_active": isActive == null ? null : isActive,
      };
}
