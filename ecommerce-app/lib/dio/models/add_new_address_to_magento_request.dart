// To parse this JSON data, do
//
//     final addNewAddressToMagento = addNewAddressToMagentoFromJson(jsonString);

import 'dart:convert';

AddNewAddressToMagentoRequest addNewAddressToMagentoFromJson(String str) => AddNewAddressToMagentoRequest.fromJson(json.decode(str));

String addNewAddressToMagentoToJson(AddNewAddressToMagentoRequest data) => json.encode(data.toJson());

class AddNewAddressToMagentoRequest {
  AddNewAddressToMagentoRequest({
    this.customer,
  });

  Customers customer;

  factory AddNewAddressToMagentoRequest.fromJson(Map<String, dynamic> json) => AddNewAddressToMagentoRequest(
    customer: json["customer"] == null ? null : Customers.fromJson(json["customer"]),
  );

  Map<String, dynamic> toJson() => {
    "customer": customer == null ? null : customer.toJson(),
  };
}

class Customers {
  Customers({
    this.email,
    this.firstname,
    this.lastname,
    this.websiteId,
    this.addresses,
    this.customAttributes,
  });

  String email;
  String firstname;
  String lastname;
  int websiteId;
  List<Address> addresses;
  List<CustomAttribute> customAttributes;

  factory Customers.fromJson(Map<String, dynamic> json) => Customers(
    email: json["email"] == null ? null : json["email"],
    firstname: json["firstname"] == null ? null : json["firstname"],
    lastname: json["lastname"] == null ? null : json["lastname"],
    websiteId: json["website_id"] == null ? null : json["website_id"],
    addresses: json["addresses"] == null ? null : List<Address>.from(json["addresses"].map((x) => Address.fromJson(x))),
    customAttributes: json["custom_attributes"] == null ? null : List<CustomAttribute>.from(json["custom_attributes"].map((x) => CustomAttribute.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "email": email == null ? null : email,
    "firstname": firstname == null ? null : firstname,
    "lastname": lastname == null ? null : lastname,
    "website_id": websiteId == null ? null : websiteId,
    "addresses": addresses == null ? null : List<dynamic>.from(addresses.map((x) => x.toJson())),
    "custom_attributes": customAttributes == null ? null : List<dynamic>.from(customAttributes.map((x) => x.toJson())),
  };
}

class Address {
  Address({
    this.customerId,
    this.region,
    this.regionId,
    this.countryId,
    this.street,
    this.telephone,
    this.postcode,
    this.city,
    this.firstname,
    this.lastname,
    this.defaultShipping,
    this.defaultBilling,
  });

  int customerId;
  Region region;
  dynamic regionId;
  String countryId;
  List<String> street;
  String telephone;
  String postcode;
  String city;
  String firstname;
  String lastname;
  bool defaultShipping;
  bool defaultBilling;

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    customerId: json["customer_id"] == null ? null : json["customer_id"],
    region: json["region"] == null ? null : Region.fromJson(json["region"]),
    regionId: json["region_id"],
    countryId: json["country_id"] == null ? null : json["country_id"],
    street: json["street"] == null ? null : List<String>.from(json["street"].map((x) => x)),
    telephone: json["telephone"] == null ? null : json["telephone"],
    postcode: json["postcode"] == null ? null : json["postcode"],
    city: json["city"] == null ? null : json["city"],
    firstname: json["firstname"] == null ? null : json["firstname"],
    lastname: json["lastname"] == null ? null : json["lastname"],
    defaultShipping: json["default_shipping"] == null ? null : json["default_shipping"],
    defaultBilling: json["default_billing"] == null ? null : json["default_billing"],
  );

  Map<String, dynamic> toJson() => {
    "customer_id": customerId == null ? null : customerId,
    "region": region == null ? null : region.toJson(),
    "region_id": regionId,
    "country_id": countryId == null ? null : countryId,
    "street": street == null ? null : List<dynamic>.from(street.map((x) => x)),
    "telephone": telephone == null ? null : telephone,
    "postcode": postcode == null ? null : postcode,
    "city": city == null ? null : city,
    "firstname": firstname == null ? null : firstname,
    "lastname": lastname == null ? null : lastname,
    "default_shipping": defaultShipping == null ? null : defaultShipping,
    "default_billing": defaultBilling == null ? null : defaultBilling,
  };
}

class Region {
  Region({
    this.regionCode,
    this.region,
    this.regionId,
  });

  dynamic regionCode;
  String region;
  dynamic regionId;

  factory Region.fromJson(Map<String, dynamic> json) => Region(
    regionCode: json["region_code"],
    region: json["region"] == null ? null : json["region"],
    regionId: json["region_id"],
  );

  Map<String, dynamic> toJson() => {
    "region_code": regionCode,
    "region": region == null ? null : region,
    "region_id": regionId,
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
