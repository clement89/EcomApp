import 'dart:convert';

class OrderDetailsModel {
  final String status;
  final String datetime;
  final String orderid;
  final String noitem;
  final String price;
  final String inaam;
  final String building;
  final String name;
  final String phone;
  final String date;
  final String time;
  final String shippingfee;
  final String discount;
  final String discountDisplay;
  final String total;
  final String card;
  final String note;
  final String tax;
  final String shippingid;
  final String increment_id;
  final String email;
  final String baseSubtotal;
  final String customer_id;
  final String createdTime;
  final String grandTotal;
  final String lat;
  final String long;
  final String storeid;
  final String invoiceUrl;
  final String storeCode;
  final String websiteId;

  OrderDetailsModel(
      {this.status,
      this.shippingid,
      this.increment_id,
      this.datetime,
      this.orderid,
      this.noitem,
      this.price,
      this.inaam,
      this.building,
      this.name,
      this.phone,
      this.date,
      this.time,
      this.shippingfee,
      this.discount,
      this.total,
      this.card,
      this.note,
      this.tax,
      this.email,
      this.baseSubtotal,
      this.createdTime,
      this.grandTotal,
      this.customer_id,
      this.lat,
      this.long,
      this.storeid,
      this.invoiceUrl,
      this.storeCode,
      this.discountDisplay,
      this.websiteId});
}

OrderDetails orderDetailsFromJson(String str) =>
    OrderDetails.fromJson(json.decode(str));

class OrderDetails {
  OrderDetails({
    this.entityId,
    this.state,
    this.status,
    this.couponCode,
    this.storeId,
    this.customerId,
    this.baseGrandTotal,
    this.baseShippingAmount,
    this.baseSubtotal,
    this.baseTaxAmount,
    this.baseTaxRefunded,
    this.baseTotalPaid,
    this.grandTotal,
    this.subtotal,
    this.baseSubtotalInclTax,
    this.customerNote,
    this.createdAt,
    this.totalItemCount,
    this.payment,
    this.items,
    this.shippingAddress,
    this.increment_id,
    this.discount_amount,
    this.storeCode,
    this.invoiceUrl,
    this.latitute,
    this.longitude,
    this.websiteId,
    this.taxAmount,
    this.shippingAmount,
    this.appliedCoupon,
  });

  String entityId;
  String state;
  String status;
  dynamic couponCode;
  String storeId;
  String customerId;
  String baseGrandTotal;
  String baseShippingAmount;
  String baseSubtotal;
  String baseTaxAmount;
  dynamic baseTaxRefunded;
  String baseTotalPaid;
  String grandTotal;
  String subtotal;
  String websiteId;
  String baseSubtotalInclTax;
  dynamic customerNote;
  DateTime createdAt;
  String totalItemCount;
  String discount_amount;
  String storeCode;
  Payment payment;
  List<Item> items;
  String increment_id;
  String latitute;
  String longitude;
  ShippingAddress shippingAddress;

  String invoiceUrl;
  String taxAmount;
  String shippingAmount;
  String appliedCoupon;

  PaymentType get paymentType {
    switch (payment.method) {
      case "cashondelivery":
        return PaymentType.cash_on_delivery;
        break;
      case "ngeniusonline":
        return PaymentType.card;
        break;
      default:
        return PaymentType.none;
        break;
    }
  }

  factory OrderDetails.fromJson(Map<String, dynamic> json) => OrderDetails(
        entityId: json["entity_id"],
        state: json["state"],
        status: json["status"],
        couponCode: json["base_discount_amount"],
        storeId: json["store_id"],
        customerId: json["customer_id"],
        baseGrandTotal: json["base_grand_total"],
        baseShippingAmount: json["base_shipping_amount"],
        baseSubtotal: json["base_subtotal"],
        baseTaxAmount: json["base_tax_amount"],
        baseTaxRefunded: json["base_tax_refunded"],
        baseTotalPaid: json["base_total_paid"],
        grandTotal: json["grand_total"],
        subtotal: json["subtotal"],
        discount_amount: json["discount_amount"] ?? '0.00',
        increment_id: json["increment_id"],
        baseSubtotalInclTax: json["base_subtotal_incl_tax"],
        customerNote: json["delivery_notes"],
        createdAt: DateTime.parse(json["created_at"]),
        totalItemCount: json["total_item_count"],
        payment: Payment.fromJson(json["payment"]),
        items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
        shippingAddress: ShippingAddress.fromJson(json["shipping_address"]),
        invoiceUrl: json["invoiceUrl"],
        latitute: json["latitude"],
        longitude: json["longitude"],
        storeCode: json["store_code"],
        websiteId: json["website_id"],
        taxAmount: json["tax_amount"] ?? "0.00",
        shippingAmount: json["shipping_amount"] ?? "0.00",
        appliedCoupon: json["coupon_code"] ?? "",
      );

  factory OrderDetails.removeToOrderDetails(Map<String, dynamic> json) =>
      OrderDetails(
        entityId: json["entity_id"] is String
            ? json["entity_id"]
            : json["entity_id"].toString(),
        state:
            json["state"] is String ? json["state"] : json["state"].toString(),
        status: json["status"] is String
            ? json["status"]
            : json["status"].toString(),
        couponCode: json["base_discount_amount"],
        storeId: json["store_id"] is String
            ? json["store_id"]
            : json["store_id"].toString(),
        customerId: json["customer_id"] is String
            ? json["customer_id"]
            : json["customer_id"].toString(),
        baseGrandTotal: json["base_grand_total"] != null
            ? json["base_grand_total"].toString()
            : "0",
        baseShippingAmount: json["base_shipping_amount"] != null
            ? json["base_shipping_amount"].toString()
            : "0",
        baseSubtotal: json["base_subtotal"] != null
            ? json["base_subtotal"].toString()
            : "0",
        baseTaxAmount: json["base_tax_amount"] is String
            ? json["base_tax_amount"]
            : json["base_tax_amount"].toString(),
        baseTaxRefunded: json["base_tax_refunded"] is String
            ? json["base_tax_refunded"]
            : (json["base_tax_refunded"] ?? 0).toString(),
        baseTotalPaid: json["base_total_paid"] is String
            ? json["base_total_paid"]
            : (json["base_total_paid"] ?? 0).toString(),
        grandTotal:
            json["grand_total"] != null ? json["grand_total"].toString() : "0",
        subtotal: json["subtotal"] != null ? json["subtotal"].toString() : "0",
        discount_amount: json["discount_amount"] is String
            ? (json["discount_amount"] ?? 0).toString()
            : "0",
        increment_id: json["increment_id"] is String
            ? json["increment_id"]
            : json["increment_id"].toString(),
        baseSubtotalInclTax: json["base_subtotal_incl_tax"] is String
            ? json["base_subtotal_incl_tax"]
            : json["base_subtotal_incl_tax"].toString(),
        customerNote: json["delivery_notes"],
        createdAt: DateTime.parse(json["created_at"]),
        totalItemCount: json["total_item_count"] is String
            ? json["total_item_count"]
            : json["total_item_count"].toString(),
        payment: Payment.fromJson(json["payment"]),
        items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
        shippingAddress: ShippingAddress.fromJson(json["shipping_address"]),
        invoiceUrl: json["invoiceUrl"],
        latitute: json["latitude"],
        longitude: json["longitude"],
        storeCode: json["store_code"],
        websiteId: json["website_id"],
        taxAmount: json["tax_amount"] is String
            ? json["tax_amount"]
            : (json["tax_amount"] ?? 0).toString() ?? "0.00",
        shippingAmount: json["shipping_amount"] is String
            ? json["shipping_amount"]
            : (json["shipping_amount"] ?? 0).toString() ?? "0.00",
        appliedCoupon: json["coupon_code"] is String ? json["coupon_code"] : "",
      );
}

class Item {
  Item({
    this.itemId,
    this.orderId,
    this.quoteItemId,
    this.storeId,
    this.productId,
    this.sku,
    this.name,
    this.qtyOrdered,
    this.basePrice,
    this.baseOriginalPrice,
    this.taxPercent,
    this.taxAmount,
    this.baseTaxAmount,
    this.basePriceInclTax,
    this.rowTotalInclTax,
    this.articleNumber,
    this.barcode,
    this.shelfNumber,
    this.shelfSortNumber,
    this.discountAmt,
    this.itemImage,
    this.discountPercent,
    this.productType,
    this.minQty,
    this.maxQty,
    this.finalTax,
  });

  String itemId;
  String orderId;
  String quoteItemId;
  String storeId;
  String productId;
  String sku;
  String name;
  String qtyOrdered;
  String basePrice;
  String baseOriginalPrice;
  String taxPercent;
  String taxAmount;
  String baseTaxAmount;
  String basePriceInclTax;
  String rowTotalInclTax;
  String articleNumber;
  String barcode;
  String productType;
  String shelfNumber;
  String discountAmt;
  String shelfSortNumber;
  String itemImage;
  String discountPercent;
  int minQty;
  int maxQty;
  String finalTax;

  factory Item.fromJson(Map<String, dynamic> json) => Item(
      itemId: json["item_id"],
      orderId: json["order_id"],
      quoteItemId: json["quote_item_id"],
      storeId: json["store_id"],
      productId: json["product_id"],
      sku: json["sku"],
      name: json["name"],
      qtyOrdered: json["qty_ordered"],
      basePrice: json["base_price"],
      baseOriginalPrice: json["base_original_price"],
      taxPercent: json["tax_percent"],
      taxAmount: (json["tax_amount"] ?? '0'),
      baseTaxAmount: json["base_tax_amount"],
      basePriceInclTax: json["base_price_incl_tax"],
      rowTotalInclTax: json["row_total_incl_tax"],
      articleNumber: json["article_number"],
      barcode: json["barcode"],
      productType: json["product_type"],
      shelfNumber: json["shelf_number"],
      discountAmt: json['base_discount_amount'],
      itemImage: json["media"] ?? '',
      shelfSortNumber: json["shelf_sort_number"],
      discountPercent: json["discount_percent"] ?? '0.0000',
      minQty: json["min_qty"],
      maxQty: json["max_qty"],
      finalTax: (json["final_tax"] ?? '0'));

  Map<String, dynamic> toReturnJson() => {
        "id": itemId,
        "name": name,
      };
}

class Payment {
  Payment({
    this.method,
  });

  String method;

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        method: json["method"],
      );
}

class ShippingAddress {
  ShippingAddress({
    this.region,
    this.lastname,
    this.street,
    this.city,
    this.email,
    this.telephone,
    this.countryId,
    this.firstname,
    this.deliveryDay,
    this.deliveryHoursFrom,
    this.deliveryMinutesFrom,
    this.deliveryHoursTo,
    this.deliveryMinutesTo,
    this.deliveryComment,
  });

  String region;
  String lastname;
  String street;
  String city;
  String email;
  String telephone;
  String countryId;
  String firstname;
  String deliveryDay;
  String deliveryHoursFrom;
  String deliveryMinutesFrom;
  String deliveryHoursTo;
  String deliveryMinutesTo;
  dynamic deliveryComment;

  factory ShippingAddress.fromJson(Map<String, dynamic> json) =>
      ShippingAddress(
        region: json["region"] ?? "",
        lastname: json["lastname"],
        street: json["street"],
        city: json["city"],
        email: json["email"],
        telephone: json["telephone"],
        countryId: json["country_id"],
        firstname: json["firstname"],
        deliveryDay: json["delivery_day"],
        deliveryHoursFrom: json["delivery_hours_from"],
        deliveryMinutesFrom: json["delivery_minutes_from"],
        deliveryHoursTo: json["delivery_hours_to"],
        deliveryMinutesTo: json["delivery_minutes_to"],
        deliveryComment: json["delivery_comment"],
      );
}

enum PaymentType { cash_on_delivery, card, none }
