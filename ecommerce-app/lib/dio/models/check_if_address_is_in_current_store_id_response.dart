// To parse this JSON data, do
//
//     final checkIfAddressIsInCurrentStoreIdResponse = checkIfAddressIsInCurrentStoreIdResponseFromJson(jsonString);

import 'dart:convert';

CheckIfAddressIsInCurrentStoreIdResponse checkIfAddressIsInCurrentStoreIdResponseFromJson(String str) => CheckIfAddressIsInCurrentStoreIdResponse.fromJson(json.decode(str));

String checkIfAddressIsInCurrentStoreIdResponseToJson(CheckIfAddressIsInCurrentStoreIdResponse data) => json.encode(data.toJson());

class CheckIfAddressIsInCurrentStoreIdResponse {
  CheckIfAddressIsInCurrentStoreIdResponse({
    this.data,
    this.message,
    this.source,
    this.success,
  });

  Data data;
  String message;
  String source;
  bool success;

  factory CheckIfAddressIsInCurrentStoreIdResponse.fromJson(Map<String, dynamic> json) => CheckIfAddressIsInCurrentStoreIdResponse(
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
  });

  bool isPointInPolygon;
  String websiteId;
  String websiteCode;
  String websiteName;
  String sapWebsiteId;
  List<Store> stores;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    isPointInPolygon: json["isPointInPolygon"] == null ? null : json["isPointInPolygon"],
    websiteId: json["website_id"] == null ? null : json["website_id"],
    websiteCode: json["website_code"] == null ? null : json["website_code"],
    websiteName: json["website_name"] == null ? null : json["website_name"],
    sapWebsiteId: json["sap_website_id"] == null ? null : json["sap_website_id"],
    stores: json["stores"] == null ? null : List<Store>.from(json["stores"].map((x) => Store.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "isPointInPolygon": isPointInPolygon == null ? null : isPointInPolygon,
    "website_id": websiteId == null ? null : websiteId,
    "website_code": websiteCode == null ? null : websiteCode,
    "website_name": websiteName == null ? null : websiteName,
    "sap_website_id": sapWebsiteId == null ? null : sapWebsiteId,
    "stores": stores == null ? null : List<dynamic>.from(stores.map((x) => x.toJson())),
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
