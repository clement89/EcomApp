// To parse this JSON data, do
//
//     final getMagentoCartResponse = getMagentoCartResponseFromJson(jsonString);

import 'dart:convert';

GetMagentoCartResponse getMagentoCartResponseFromJson(String str) => GetMagentoCartResponse.fromJson(json.decode(str));

String getMagentoCartResponseToJson(GetMagentoCartResponse data) => json.encode(data.toJson());

class GetMagentoCartResponse {
  GetMagentoCartResponse({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.isActive,
    this.isVirtual,
    this.items,
    this.itemsCount,
    this.itemsQty,
    this.customer,
    this.billingAddress,
    this.origOrderId,
    this.currency,
    this.customerIsGuest,
    this.customerNoteNotify,
    this.customerTaxClassId,
    this.storeId,
    this.extensionAttributes,
  });

  int id;
  DateTime createdAt;
  DateTime updatedAt;
  bool isActive;
  bool isVirtual;
  List<Item> items;
  int itemsCount;
  int itemsQty;
  Customer customer;
  BillingAddressClass billingAddress;
  int origOrderId;
  Currency currency;
  bool customerIsGuest;
  bool customerNoteNotify;
  int customerTaxClassId;
  int storeId;
  GetMagentoCartResponseExtensionAttributes extensionAttributes;

  factory GetMagentoCartResponse.fromJson(Map<String, dynamic> json) => GetMagentoCartResponse(
    id: json["id"] == null ? null : json["id"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    isActive: json["is_active"] == null ? null : json["is_active"],
    isVirtual: json["is_virtual"] == null ? null : json["is_virtual"],
    items: json["items"] == null ? null : List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
    itemsCount: json["items_count"] == null ? null : json["items_count"],
    itemsQty: json["items_qty"] == null ? null : json["items_qty"],
    customer: json["customer"] == null ? null : Customer.fromJson(json["customer"]),
    billingAddress: json["billing_address"] == null ? null : BillingAddressClass.fromJson(json["billing_address"]),
    origOrderId: json["orig_order_id"] == null ? null : json["orig_order_id"],
    currency: json["currency"] == null ? null : Currency.fromJson(json["currency"]),
    customerIsGuest: json["customer_is_guest"] == null ? null : json["customer_is_guest"],
    customerNoteNotify: json["customer_note_notify"] == null ? null : json["customer_note_notify"],
    customerTaxClassId: json["customer_tax_class_id"] == null ? null : json["customer_tax_class_id"],
    storeId: json["store_id"] == null ? null : json["store_id"],
    extensionAttributes: json["extension_attributes"] == null ? null : GetMagentoCartResponseExtensionAttributes.fromJson(json["extension_attributes"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id == null ? null : id,
    "created_at": createdAt == null ? null : createdAt.toIso8601String(),
    "updated_at": updatedAt == null ? null : updatedAt.toIso8601String(),
    "is_active": isActive == null ? null : isActive,
    "is_virtual": isVirtual == null ? null : isVirtual,
    "items": items == null ? null : List<dynamic>.from(items.map((x) => x.toJson())),
    "items_count": itemsCount == null ? null : itemsCount,
    "items_qty": itemsQty == null ? null : itemsQty,
    "customer": customer == null ? null : customer.toJson(),
    "billing_address": billingAddress == null ? null : billingAddress.toJson(),
    "orig_order_id": origOrderId == null ? null : origOrderId,
    "currency": currency == null ? null : currency.toJson(),
    "customer_is_guest": customerIsGuest == null ? null : customerIsGuest,
    "customer_note_notify": customerNoteNotify == null ? null : customerNoteNotify,
    "customer_tax_class_id": customerTaxClassId == null ? null : customerTaxClassId,
    "store_id": storeId == null ? null : storeId,
    "extension_attributes": extensionAttributes == null ? null : extensionAttributes.toJson(),
  };
}

class BillingAddressClass {
  BillingAddressClass({
    this.id,
    this.region,
    this.regionId,
    this.regionCode,
    this.countryId,
    this.street,
    this.telephone,
    this.postcode,
    this.city,
    this.firstname,
    this.lastname,
    this.customerId,
    this.email,
    this.sameAsBilling,
    this.customerAddressId,
    this.saveInAddressBook,
    this.extensionAttributes,
  });

  int id;
  String region;
  int regionId;
  dynamic regionCode;
  String countryId;
  List<String> street;
  String telephone;
  String postcode;
  String city;
  String firstname;
  String lastname;
  int customerId;
  String email;
  int sameAsBilling;
  int customerAddressId;
  int saveInAddressBook;
  BillingAddressExtensionAttributes extensionAttributes;

  factory BillingAddressClass.fromJson(Map<String, dynamic> json) => BillingAddressClass(
    id: json["id"] == null ? null : json["id"],
    region: json["region"] == null ? null : json["region"],
    regionId: json["region_id"] == null ? null : json["region_id"],
    regionCode: json["region_code"],
    countryId: json["country_id"] == null ? null : json["country_id"],
    street: json["street"] == null ? null : List<String>.from(json["street"].map((x) => x)),
    telephone: json["telephone"] == null ? null : json["telephone"],
    postcode: json["postcode"] == null ? null : json["postcode"],
    city: json["city"] == null ? null : json["city"],
    firstname: json["firstname"] == null ? null : json["firstname"],
    lastname: json["lastname"] == null ? null : json["lastname"],
    customerId: json["customer_id"] == null ? null : json["customer_id"],
    email: json["email"] == null ? null : json["email"],
    sameAsBilling: json["same_as_billing"] == null ? null : json["same_as_billing"],
    customerAddressId: json["customer_address_id"] == null ? null : json["customer_address_id"],
    saveInAddressBook: json["save_in_address_book"] == null ? null : json["save_in_address_book"],
    extensionAttributes: json["extension_attributes"] == null ? null : BillingAddressExtensionAttributes.fromJson(json["extension_attributes"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id == null ? null : id,
    "region": region == null ? null : region,
    "region_id": regionId == null ? null : regionId,
    "region_code": regionCode,
    "country_id": countryId == null ? null : countryId,
    "street": street == null ? null : List<dynamic>.from(street.map((x) => x)),
    "telephone": telephone == null ? null : telephone,
    "postcode": postcode == null ? null : postcode,
    "city": city == null ? null : city,
    "firstname": firstname == null ? null : firstname,
    "lastname": lastname == null ? null : lastname,
    "customer_id": customerId == null ? null : customerId,
    "email": email == null ? null : email,
    "same_as_billing": sameAsBilling == null ? null : sameAsBilling,
    "customer_address_id": customerAddressId == null ? null : customerAddressId,
    "save_in_address_book": saveInAddressBook == null ? null : saveInAddressBook,
    "extension_attributes": extensionAttributes == null ? null : extensionAttributes.toJson(),
  };
}

class BillingAddressExtensionAttributes {
  BillingAddressExtensionAttributes({
    this.deliveryHoursFrom,
    this.deliveryMinutesFrom,
    this.deliveryHoursTo,
    this.deliveryMinutesTo,
    this.deliveryTime,
  });

  String deliveryHoursFrom;
  String deliveryMinutesFrom;
  String deliveryHoursTo;
  String deliveryMinutesTo;
  String deliveryTime;

  factory BillingAddressExtensionAttributes.fromJson(Map<String, dynamic> json) => BillingAddressExtensionAttributes(
    deliveryHoursFrom: json["delivery_hours_from"] == null ? null : json["delivery_hours_from"],
    deliveryMinutesFrom: json["delivery_minutes_from"] == null ? null : json["delivery_minutes_from"],
    deliveryHoursTo: json["delivery_hours_to"] == null ? null : json["delivery_hours_to"],
    deliveryMinutesTo: json["delivery_minutes_to"] == null ? null : json["delivery_minutes_to"],
    deliveryTime: json["delivery_time"] == null ? null : json["delivery_time"],
  );

  Map<String, dynamic> toJson() => {
    "delivery_hours_from": deliveryHoursFrom == null ? null : deliveryHoursFrom,
    "delivery_minutes_from": deliveryMinutesFrom == null ? null : deliveryMinutesFrom,
    "delivery_hours_to": deliveryHoursTo == null ? null : deliveryHoursTo,
    "delivery_minutes_to": deliveryMinutesTo == null ? null : deliveryMinutesTo,
    "delivery_time": deliveryTime == null ? null : deliveryTime,
  };
}

class Currency {
  Currency({
    this.globalCurrencyCode,
    this.baseCurrencyCode,
    this.storeCurrencyCode,
    this.quoteCurrencyCode,
    this.storeToBaseRate,
    this.storeToQuoteRate,
    this.baseToGlobalRate,
    this.baseToQuoteRate,
  });

  String globalCurrencyCode;
  String baseCurrencyCode;
  String storeCurrencyCode;
  String quoteCurrencyCode;
  int storeToBaseRate;
  int storeToQuoteRate;
  int baseToGlobalRate;
  int baseToQuoteRate;

  factory Currency.fromJson(Map<String, dynamic> json) => Currency(
    globalCurrencyCode: json["global_currency_code"] == null ? null : json["global_currency_code"],
    baseCurrencyCode: json["base_currency_code"] == null ? null : json["base_currency_code"],
    storeCurrencyCode: json["store_currency_code"] == null ? null : json["store_currency_code"],
    quoteCurrencyCode: json["quote_currency_code"] == null ? null : json["quote_currency_code"],
    storeToBaseRate: json["store_to_base_rate"] == null ? null : json["store_to_base_rate"],
    storeToQuoteRate: json["store_to_quote_rate"] == null ? null : json["store_to_quote_rate"],
    baseToGlobalRate: json["base_to_global_rate"] == null ? null : json["base_to_global_rate"],
    baseToQuoteRate: json["base_to_quote_rate"] == null ? null : json["base_to_quote_rate"],
  );

  Map<String, dynamic> toJson() => {
    "global_currency_code": globalCurrencyCode == null ? null : globalCurrencyCode,
    "base_currency_code": baseCurrencyCode == null ? null : baseCurrencyCode,
    "store_currency_code": storeCurrencyCode == null ? null : storeCurrencyCode,
    "quote_currency_code": quoteCurrencyCode == null ? null : quoteCurrencyCode,
    "store_to_base_rate": storeToBaseRate == null ? null : storeToBaseRate,
    "store_to_quote_rate": storeToQuoteRate == null ? null : storeToQuoteRate,
    "base_to_global_rate": baseToGlobalRate == null ? null : baseToGlobalRate,
    "base_to_quote_rate": baseToQuoteRate == null ? null : baseToQuoteRate,
  };
}

class Customer {
  Customer({
    this.id,
    this.groupId,
    this.defaultBilling,
    this.defaultShipping,
    this.createdAt,
    this.updatedAt,
    this.createdIn,
    this.email,
    this.firstname,
    this.lastname,
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
  String defaultBilling;
  String defaultShipping;
  DateTime createdAt;
  DateTime updatedAt;
  String createdIn;
  String email;
  String firstname;
  String lastname;
  int gender;
  int storeId;
  int websiteId;
  List<AddressElement> addresses;
  int disableAutoGroupChange;
  CustomerExtensionAttributes extensionAttributes;
  List<CustomAttribute> customAttributes;

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    id: json["id"] == null ? null : json["id"],
    groupId: json["group_id"] == null ? null : json["group_id"],
    defaultBilling: json["default_billing"] == null ? null : json["default_billing"],
    defaultShipping: json["default_shipping"] == null ? null : json["default_shipping"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    createdIn: json["created_in"] == null ? null : json["created_in"],
    email: json["email"] == null ? null : json["email"],
    firstname: json["firstname"] == null ? null : json["firstname"],
    lastname: json["lastname"] == null ? null : json["lastname"],
    gender: json["gender"] == null ? null : json["gender"],
    storeId: json["store_id"] == null ? null : json["store_id"],
    websiteId: json["website_id"] == null ? null : json["website_id"],
    addresses: json["addresses"] == null ? null : List<AddressElement>.from(json["addresses"].map((x) => AddressElement.fromJson(x))),
    disableAutoGroupChange: json["disable_auto_group_change"] == null ? null : json["disable_auto_group_change"],
    extensionAttributes: json["extension_attributes"] == null ? null : CustomerExtensionAttributes.fromJson(json["extension_attributes"]),
    customAttributes: json["custom_attributes"] == null ? null : List<CustomAttribute>.from(json["custom_attributes"].map((x) => CustomAttribute.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id == null ? null : id,
    "group_id": groupId == null ? null : groupId,
    "default_billing": defaultBilling == null ? null : defaultBilling,
    "default_shipping": defaultShipping == null ? null : defaultShipping,
    "created_at": createdAt == null ? null : createdAt.toIso8601String(),
    "updated_at": updatedAt == null ? null : updatedAt.toIso8601String(),
    "created_in": createdIn == null ? null : createdIn,
    "email": email == null ? null : email,
    "firstname": firstname == null ? null : firstname,
    "lastname": lastname == null ? null : lastname,
    "gender": gender == null ? null : gender,
    "store_id": storeId == null ? null : storeId,
    "website_id": websiteId == null ? null : websiteId,
    "addresses": addresses == null ? null : List<dynamic>.from(addresses.map((x) => x.toJson())),
    "disable_auto_group_change": disableAutoGroupChange == null ? null : disableAutoGroupChange,
    "extension_attributes": extensionAttributes == null ? null : extensionAttributes.toJson(),
    "custom_attributes": customAttributes == null ? null : List<dynamic>.from(customAttributes.map((x) => x.toJson())),
  };
}

class AddressElement {
  AddressElement({
    this.id,
    this.customerId,
    this.region,
    this.regionId,
    this.countryId,
    this.street,
    this.telephone,
    this.city,
    this.firstname,
    this.lastname,
    this.customAttributes,
    this.postcode,
    this.defaultShipping,
    this.defaultBilling,
  });

  int id;
  int customerId;
  Region region;
  int regionId;
  String countryId;
  List<String> street;
  String telephone;
  String city;
  String firstname;
  String lastname;
  List<CustomAttribute> customAttributes;
  String postcode;
  bool defaultShipping;
  bool defaultBilling;

  factory AddressElement.fromJson(Map<String, dynamic> json) => AddressElement(
    id: json["id"] == null ? null : json["id"],
    customerId: json["customer_id"] == null ? null : json["customer_id"],
    region: json["region"] == null ? null : Region.fromJson(json["region"]),
    regionId: json["region_id"] == null ? null : json["region_id"],
    countryId: json["country_id"] == null ? null : json["country_id"],
    street: json["street"] == null ? null : List<String>.from(json["street"].map((x) => x)),
    telephone: json["telephone"] == null ? null : json["telephone"],
    city: json["city"] == null ? null : json["city"],
    firstname: json["firstname"] == null ? null : json["firstname"],
    lastname: json["lastname"] == null ? null : json["lastname"],
    customAttributes: json["custom_attributes"] == null ? null : List<CustomAttribute>.from(json["custom_attributes"].map((x) => CustomAttribute.fromJson(x))),
    postcode: json["postcode"] == null ? null : json["postcode"],
    defaultShipping: json["default_shipping"] == null ? null : json["default_shipping"],
    defaultBilling: json["default_billing"] == null ? null : json["default_billing"],
  );

  Map<String, dynamic> toJson() => {
    "id": id == null ? null : id,
    "customer_id": customerId == null ? null : customerId,
    "region": region == null ? null : region.toJson(),
    "region_id": regionId == null ? null : regionId,
    "country_id": countryId == null ? null : countryId,
    "street": street == null ? null : List<dynamic>.from(street.map((x) => x)),
    "telephone": telephone == null ? null : telephone,
    "city": city == null ? null : city,
    "firstname": firstname == null ? null : firstname,
    "lastname": lastname == null ? null : lastname,
    "custom_attributes": customAttributes == null ? null : List<dynamic>.from(customAttributes.map((x) => x.toJson())),
    "postcode": postcode == null ? null : postcode,
    "default_shipping": defaultShipping == null ? null : defaultShipping,
    "default_billing": defaultBilling == null ? null : defaultBilling,
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

class Region {
  Region({
    this.regionCode,
    this.region,
    this.regionId,
  });

  String regionCode;
  String region;
  int regionId;

  factory Region.fromJson(Map<String, dynamic> json) => Region(
    regionCode: json["region_code"] == null ? null : json["region_code"],
    region: json["region"] == null ? null : json["region"],
    regionId: json["region_id"] == null ? null : json["region_id"],
  );

  Map<String, dynamic> toJson() => {
    "region_code": regionCode == null ? null : regionCode,
    "region": region == null ? null : region,
    "region_id": regionId == null ? null : regionId,
  };
}

class CustomerExtensionAttributes {
  CustomerExtensionAttributes({
    this.isSubscribed,
  });

  bool isSubscribed;

  factory CustomerExtensionAttributes.fromJson(Map<String, dynamic> json) => CustomerExtensionAttributes(
    isSubscribed: json["is_subscribed"] == null ? null : json["is_subscribed"],
  );

  Map<String, dynamic> toJson() => {
    "is_subscribed": isSubscribed == null ? null : isSubscribed,
  };
}

class GetMagentoCartResponseExtensionAttributes {
  GetMagentoCartResponseExtensionAttributes({
    this.shippingAssignments,
  });

  List<ShippingAssignment> shippingAssignments;

  factory GetMagentoCartResponseExtensionAttributes.fromJson(Map<String, dynamic> json) => GetMagentoCartResponseExtensionAttributes(
    shippingAssignments: json["shipping_assignments"] == null ? null : List<ShippingAssignment>.from(json["shipping_assignments"].map((x) => ShippingAssignment.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "shipping_assignments": shippingAssignments == null ? null : List<dynamic>.from(shippingAssignments.map((x) => x.toJson())),
  };
}

class ShippingAssignment {
  ShippingAssignment({
    this.shipping,
    this.items,
  });

  Shipping shipping;
  List<Item> items;

  factory ShippingAssignment.fromJson(Map<String, dynamic> json) => ShippingAssignment(
    shipping: json["shipping"] == null ? null : Shipping.fromJson(json["shipping"]),
    items: json["items"] == null ? null : List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "shipping": shipping == null ? null : shipping.toJson(),
    "items": items == null ? null : List<dynamic>.from(items.map((x) => x.toJson())),
  };
}

class Item {
  Item({
    this.itemId,
    this.sku,
    this.qty,
    this.name,
    this.price,
    this.productType,
    this.quoteId,
    this.extensionAttributes,
  });

  int itemId;
  String sku;
  int qty;
  String name;
  int price;
  String productType;
  String quoteId;
  ItemExtensionAttributes extensionAttributes;

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    itemId: json["item_id"] == null ? null : json["item_id"],
    sku: json["sku"] == null ? null : json["sku"],
    qty: json["qty"] == null ? null : json["qty"],
    name: json["name"] == null ? null : json["name"],
    price: json["price"] == null ? null : json["price"],
    productType: json["product_type"] == null ? null : json["product_type"],
    quoteId: json["quote_id"] == null ? null : json["quote_id"],
    extensionAttributes: json["extension_attributes"] == null ? null : ItemExtensionAttributes.fromJson(json["extension_attributes"]),
  );

  Map<String, dynamic> toJson() => {
    "item_id": itemId == null ? null : itemId,
    "sku": sku == null ? null : sku,
    "qty": qty == null ? null : qty,
    "name": name == null ? null : name,
    "price": price == null ? null : price,
    "product_type": productType == null ? null : productType,
    "quote_id": quoteId == null ? null : quoteId,
    "extension_attributes": extensionAttributes == null ? null : extensionAttributes.toJson(),
  };
}

class ItemExtensionAttributes {
  ItemExtensionAttributes({
    this.finalTax,
    this.rowTotal,
    this.discountAmount,
  });

  double finalTax;
  int rowTotal;
  int discountAmount;

  factory ItemExtensionAttributes.fromJson(Map<String, dynamic> json) => ItemExtensionAttributes(
    finalTax: json["final_tax"] == null ? null : json["final_tax"].toDouble(),
    rowTotal: json["row_total"] == null ? null : json["row_total"],
    discountAmount: json["discount_amount"] == null ? null : json["discount_amount"],
  );

  Map<String, dynamic> toJson() => {
    "final_tax": finalTax == null ? null : finalTax,
    "row_total": rowTotal == null ? null : rowTotal,
    "discount_amount": discountAmount == null ? null : discountAmount,
  };
}

class Shipping {
  Shipping({
    this.address,
    this.method,
  });

  BillingAddressClass address;
  dynamic method;

  factory Shipping.fromJson(Map<String, dynamic> json) => Shipping(
    address: json["address"] == null ? null : BillingAddressClass.fromJson(json["address"]),
    method: json["method"],
  );

  Map<String, dynamic> toJson() => {
    "address": address == null ? null : address.toJson(),
    "method": method,
  };
}
