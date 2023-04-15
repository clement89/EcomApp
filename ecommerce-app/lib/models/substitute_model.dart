// To parse this JSON data, do
//
//     final substitute = substituteFromJson(jsonString);

import 'dart:convert';
import 'package:http/http.dart';

// Substitute substituteFromJson(String str) =>
//     Substitute.fromJson(json.decode(str));

Substitute substituteFromJson(Response response) =>
    Substitute.fromJson(json.decode(utf8.decode(response.bodyBytes)));

class Substitute {
  Substitute({
    this.data,
    this.message,
    this.source,
    this.success,
  });

  Data data;
  String message;
  String source;
  bool success;

  factory Substitute.fromJson(Map<String, dynamic> json) => Substitute(
        data: Data.fromJson(json["data"]),
        message: json["message"],
        source: json["source"],
        success: json["success"],
      );
}

class Data {
  Data({
    this.singleOrder,
  });

  SubstituteOrder singleOrder;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        singleOrder: SubstituteOrder.fromJson(json["singleOrder"]),
      );

/* Map<String, dynamic> toJson() => {
    "singleOrder": singleOrder.toJson(),
  };*/
}

class SubstituteOrder {
  SubstituteOrder({
    this.items,
    this.id,
    this.salesOrderId,
    this.salesIncrementalId,
    this.paymentStatus,
    this.paymentAmount,
    this.taxAmount,
    this.taxRate,
    this.capturedAmount,
    this.capturedAmountTimestamp,
    this.codType,
    this.timeSlot,
    this.orderCreatedAt,
    this.paymentType,
    this.websiteID,
    this.deliveryFee,
    this.baseDiscountAmount,
    this.baseSubTotal,
    this.itemCount,
  });

  List<ItemSub> items;
  int id;
  String salesOrderId;
  String salesIncrementalId;
  String paymentStatus;
  double paymentAmount;
  double taxAmount;
  int taxRate;
  dynamic capturedAmount;
  dynamic capturedAmountTimestamp;
  String codType;
  String timeSlot;
  String orderCreatedAt;
  String paymentType;
  dynamic websiteID;
  dynamic deliveryFee;
  double baseDiscountAmount;
  double baseSubTotal;
  int itemCount;

  factory SubstituteOrder.fromJson(Map<String, dynamic> json) =>
      SubstituteOrder(
          items:
              List<ItemSub>.from(json["items"].map((x) => ItemSub.fromJson(x))),
          id: json["id"] ?? 0,
          salesOrderId: json["sales_order_id"] ?? "",
          salesIncrementalId: json["sales_incremental_id"] ?? "",
          paymentStatus: json["payment_status"] ?? "",
          paymentAmount: (json["payment_amount"] ?? 0.0).toDouble(),
          taxAmount: (json["tax_amount"] ?? 0).toDouble(),
          taxRate: json["tax_rate"] ?? 0,
          capturedAmount: json["captured_amount"],
          capturedAmountTimestamp: json["captured_amount_timestamp"],
          codType: json["cod_type"] ?? "",
          timeSlot: json["timeSlot"] ?? "",
          orderCreatedAt: json["orderCreatedAt"] ?? "",
          paymentType: json["payment_status"] ?? '',
          websiteID: json["website_id"],
          deliveryFee: json["delivery_fee"] ?? 0.0,
          baseDiscountAmount:
              (json["base_discount_amount"] ?? 0).abs().toDouble() ?? 0.00,
          baseSubTotal: (json["base_subtotal"]).toDouble() ?? 0.00,
          itemCount: json["item_count"] ?? 0);
}

class ItemSub {
  ItemSub({
    this.id,
    this.itemId,
    this.name,
    this.imageUrl,
    this.department,
    this.shelfNumber,
    this.shelfSortNumber,
    this.dfc,
    this.barcode,
    this.price,
    this.qty,
    this.substitutionInitiated,
    this.itemType,
    this.articleNumber,
    this.sku,
    this.quoteId,
    this.orderId,
    this.substutionTimeStamp,
    this.quantityOutOfStock,
    this.taxExcludedPrice,
    this.tax,
    this.discountPercentage,
    this.discountAmount,
    this.baseDiscountAmount,
    this.rowTotalInclTax,
  });

  int id;
  String itemId;
  String name;
  String imageUrl;
  String department;
  dynamic shelfNumber;
  dynamic shelfSortNumber;
  String dfc;
  String barcode;
  double price;
  int qty;
  bool substitutionInitiated;
  String itemType;
  String articleNumber;
  String sku;
  String quoteId;
  int orderId;
  String substutionTimeStamp;
  int quantityOutOfStock;
  double taxExcludedPrice;
  double tax;
  double discountPercentage;
  double discountAmount;
  double baseDiscountAmount;
  double rowTotalInclTax;

  factory ItemSub.fromJson(Map<String, dynamic> json) => ItemSub(
        id: json["id"] ?? 0,
        itemId: json["item_id"] ?? "",
        name: json["name"] ?? "",
        imageUrl: json["image_url"] ?? "",
        department: json["department"] ?? "",
        shelfNumber: json["shelf_number"],
        shelfSortNumber: json["shelf_sort_number"],
        dfc: json["dfc"] ?? "",
        barcode: json["barcode"] ?? "",
        price: (json["price"] ?? 0).toDouble(),
        qty: json["qty"],
        substitutionInitiated: json["substitution_initiated"] ?? false,
        itemType: json["item_type"] ?? "",
        articleNumber: json["article_number"] ?? "",
        sku: json["sku"] ?? "",
        quoteId: json["quote_id"] ?? "",
        orderId: json["orderId"] ?? 0,
        substutionTimeStamp: json["substitution_initiated_timestamp"] ?? '',
        quantityOutOfStock: json["quantity_out_of_stock"] == null
            ? 0
            : json["quantity_out_of_stock"] ?? 0,
        taxExcludedPrice: (json["price_without_tax"] ?? 0).toDouble() ?? 0.00,
        tax: (json["tax_rate"] ?? 0).toDouble() ?? 0,
        discountPercentage: (json["discount_percent"] ?? 0).toDouble() ?? 0.00,
        discountAmount: (json["discount_amount"] ?? 0).toDouble() ?? 0.00,
        baseDiscountAmount:
            (json["base_discount_amount"] ?? 0).toDouble() ?? 0.00,
        rowTotalInclTax: (json["row_total_incl_tax"] ?? 0).toDouble() ?? 0.00,
      );
}
