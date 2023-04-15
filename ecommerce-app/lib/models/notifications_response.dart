// To parse this JSON data, do
//
//     final notificationsCallResponse = notificationsCallResponseFromJson(jsonString);

import 'dart:convert';

NotificationsCallResponse notificationsCallResponseFromJson(String str) =>
    NotificationsCallResponse.fromJson(json.decode(str));

String notificationsCallResponseToJson(NotificationsCallResponse data) =>
    json.encode(data.toJson());

class NotificationsCallResponse {
  NotificationsCallResponse({
    this.data,
    this.message,
    this.source,
    this.success,
  });

  List<Datum> data;
  String message;
  String source;
  bool success;

  factory NotificationsCallResponse.fromJson(Map<String, dynamic> json) =>
      NotificationsCallResponse(
        data: json["data"] == null
            ? null
            : List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
        message: json["message"] == null ? null : json["message"],
        source: json["source"] == null ? null : json["source"],
        success: json["success"] == null ? null : json["success"],
      );

  Map<String, dynamic> toJson() => {
        "data": data == null
            ? null
            : List<dynamic>.from(data.map((x) => x.toJson())),
        "message": message == null ? null : message,
        "source": source == null ? null : source,
        "success": success == null ? null : success,
      };
}

class Datum {
  Datum({
    this.data,
    this.id,
    this.title,
    this.body,
    this.image,
    this.seen,
    this.seenTimestamp,
    this.userId,
    this.role,
    this.deleted,
    this.deletedTimestamp,
    this.createdAt,
    this.updatedAt,
  });

  Data data;
  int id;
  String title;
  String body;
  dynamic image;
  bool seen;
  dynamic seenTimestamp;
  int userId;
  Role role;
  bool deleted;
  dynamic deletedTimestamp;
  DateTime createdAt;
  DateTime updatedAt;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        id: json["id"] == null ? null : json["id"],
        title: json["title"] == null ? null : json["title"],
        body: json["body"] == null ? null : json["body"],
        image: json["image"],
        seen: json["seen"] == null ? null : json["seen"],
        seenTimestamp: json["seen_timestamp"],
        userId: json["user_id"] == null ? null : json["user_id"],
        role: json["role"] == null ? null : roleValues.map[json["role"]],
        deleted: json["deleted"] == null ? null : json["deleted"],
        deletedTimestamp: json["deleted_timestamp"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "data": data == null ? null : data.toJson(),
        "id": id == null ? null : id,
        "title": title == null ? null : title,
        "body": body == null ? null : body,
        "image": image,
        "seen": seen == null ? null : seen,
        "seen_timestamp": seenTimestamp,
        "user_id": userId == null ? null : userId,
        "role": role == null ? null : roleValues.reverse[role],
        "deleted": deleted == null ? null : deleted,
        "deleted_timestamp": deletedTimestamp,
        "createdAt": createdAt == null ? null : createdAt.toIso8601String(),
        "updatedAt": updatedAt == null ? null : updatedAt.toIso8601String(),
      };
}

class Data {
  Data({
    this.action,
    this.value,
    this.salesIncrementalId,
  });

  String action;
  Value value;
  String salesIncrementalId;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        action: json["action"] == null ? null : json["action"],
        value: json["value"] == null ? null : Value.fromJson(json["value"]),
        salesIncrementalId: json["sales_incremental_id"] == null
            ? null
            : json["sales_incremental_id"],
      );

  Map<String, dynamic> toJson() => {
        "action": action == null ? null : action,
        "value": value == null ? null : value.toJson(),
        "sales_incremental_id":
            salesIncrementalId == null ? null : salesIncrementalId,
      };
}

class Value {
  Value({
    this.orderId,
    this.cutoffTime,
    this.categoryId,
    this.categoryOfferName,
    this.productSku,
    this.itemIdLambda,
    this.itemTypeLambda,
    this.itemIdMagento,
  });

  dynamic orderId;
  DateTime cutoffTime;
  String categoryId;
  String categoryOfferName;
  String productSku;
  int itemIdLambda;
  String itemTypeLambda;
  String itemIdMagento;

  factory Value.fromJson(Map<String, dynamic> json) => Value(
        orderId: json["order_id"],
        cutoffTime: json["cutoff_time"] == null
            ? null
            : DateTime.parse(json["cutoff_time"]),
        categoryId: json["category_id"] == null ? null : json["category_id"],
        categoryOfferName: json["category/offer_name"] == null
            ? null
            : json["category/offer_name"],
        productSku: json["product_sku"] == null ? null : json["product_sku"],
        itemIdLambda:
            json["item_id_lambda"] == null ? null : json["item_id_lambda"],
        itemTypeLambda:
            json["item_type_lambda"] == null ? null : json["item_type_lambda"],
        itemIdMagento:
            json["item_id_magento"] == null ? null : json["item_id_magento"],
      );

  Map<String, dynamic> toJson() => {
        "order_id": orderId,
        "cutoffTime": cutoffTime == null ? null : cutoffTime.toIso8601String(),
        "category_id": categoryId == null ? null : categoryId,
        "category/offer_name":
            categoryOfferName == null ? null : categoryOfferName,
        "product_sku": productSku == null ? null : productSku,
        "item_id_lambda": itemIdLambda == null ? null : itemIdLambda,
        "item_type_lambda": itemTypeLambda == null ? null : itemTypeLambda,
        "item_id_magento": itemIdMagento == null ? null : itemIdMagento,
      };
}

enum Role { CUSTOMER }

final roleValues = EnumValues({"customer": Role.CUSTOMER});

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}
