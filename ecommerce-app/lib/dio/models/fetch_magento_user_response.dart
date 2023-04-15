// To parse this JSON data, do
//
//     final fetchUserResponse = fetchUserResponseFromJson(jsonString);

import 'dart:convert';

FetchUserResponse fetchUserResponseFromJson(String str) => FetchUserResponse.fromJson(json.decode(str));

String fetchUserResponseToJson(FetchUserResponse data) => json.encode(data.toJson());

class FetchUserResponse {
  FetchUserResponse({
    this.id,
    this.groupId,
    this.createdAt,
    this.updatedAt,
    this.createdIn,
    this.email,
    this.firstname,
    this.lastname,
    this.dob,
    this.gender,
    this.storeId,
    this.websiteId,
    this.addresses,
    this.disableAutoGroupChange,
    this.extensionAttributes,
    this.customAttributes,
  });

  int id;
  int groupId;
  DateTime createdAt;
  DateTime updatedAt;
  String createdIn;
  String email;
  String firstname;
  String lastname;
  String dob;
  int gender;
  int storeId;
  int websiteId;
  List<dynamic> addresses;
  int disableAutoGroupChange;
  ExtensionAttributes extensionAttributes;
  List<CustomAttribute> customAttributes;

  factory FetchUserResponse.fromJson(Map<String, dynamic> json) => FetchUserResponse(
    id: json["id"] == null ? null : json["id"],
    groupId: json["group_id"] == null ? null : json["group_id"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    createdIn: json["created_in"] == null ? null : json["created_in"],
    email: json["email"] == null ? null : json["email"],
    firstname: json["firstname"] == null ? null : json["firstname"],
    lastname: json["lastname"] == null ? null : json["lastname"],
    dob: json["dob"] == null ? null : json["dob"],
    gender: json["gender"] == null ? null : json["gender"],
    storeId: json["store_id"] == null ? null : json["store_id"],
    websiteId: json["website_id"] == null ? null : json["website_id"],
    addresses: json["addresses"] == null ? null : List<dynamic>.from(json["addresses"].map((x) => x)),
    disableAutoGroupChange: json["disable_auto_group_change"] == null ? null : json["disable_auto_group_change"],
    extensionAttributes: json["extension_attributes"] == null ? null : ExtensionAttributes.fromJson(json["extension_attributes"]),
    customAttributes: json["custom_attributes"] == null ? null : List<CustomAttribute>.from(json["custom_attributes"].map((x) => CustomAttribute.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id == null ? null : id,
    "group_id": groupId == null ? null : groupId,
    "created_at": createdAt == null ? null : createdAt.toIso8601String(),
    "updated_at": updatedAt == null ? null : updatedAt.toIso8601String(),
    "created_in": createdIn == null ? null : createdIn,
    "email": email == null ? null : email,
    "firstname": firstname == null ? null : firstname,
    "lastname": lastname == null ? null : lastname,
    "dob": dob == null ? null : dob,
    "gender": gender == null ? null : gender,
    "store_id": storeId == null ? null : storeId,
    "website_id": websiteId == null ? null : websiteId,
    "addresses": addresses == null ? null : List<dynamic>.from(addresses.map((x) => x)),
    "disable_auto_group_change": disableAutoGroupChange == null ? null : disableAutoGroupChange,
    "extension_attributes": extensionAttributes == null ? null : extensionAttributes.toJson(),
    "custom_attributes": customAttributes == null ? null : List<dynamic>.from(customAttributes.map((x) => x.toJson())),
  };
}

class CustomAttribute {
  CustomAttribute({
    this.attributeCode,
    this.value,
  });

  String attributeCode;
  String value;

  factory CustomAttribute.fromJson(Map<String, dynamic> json) => CustomAttribute(
    attributeCode: json["attribute_code"] == null ? null : json["attribute_code"],
    value: json["value"] == null ? null : json["value"],
  );

  Map<String, dynamic> toJson() => {
    "attribute_code": attributeCode == null ? null : attributeCode,
    "value": value == null ? null : value,
  };
}

class ExtensionAttributes {
  ExtensionAttributes({
    this.isSubscribed,
  });

  bool isSubscribed;

  factory ExtensionAttributes.fromJson(Map<String, dynamic> json) => ExtensionAttributes(
    isSubscribed: json["is_subscribed"] == null ? null : json["is_subscribed"],
  );

  Map<String, dynamic> toJson() => {
    "is_subscribed": isSubscribed == null ? null : isSubscribed,
  };
}
