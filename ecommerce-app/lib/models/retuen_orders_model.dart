import 'dart:convert';

class ReturnOrderModel {
  final int count;
  final String itemname;
  final String itemid;
  final String tax;
  String price;
  final String shipping;
  final String coupon;
  final String quote_item_id;
  final String article_number;
  final String shelf_number;
  final String shelf_sort_number;
  final String product_id;
  final String product_type;
  final String sku;
  final String image;
  final String rawtotel;

  ReturnOrderModel(
      {this.shipping,
      this.coupon,
      this.quote_item_id,
      this.article_number,
      this.shelf_number,
      this.shelf_sort_number,
      this.product_id,
      this.product_type,
      this.sku,
      this.count,
      this.itemname,
      this.price,
      this.itemid,
      this.rawtotel,
      this.image,
      this.tax});
}

// To parse this JSON data, do
//
//     final sendreturnorder = sendreturnorderFromJson(jsonString);

//SEND DATA PODO CLASS

Sendreturnorder sendreturnorderFromJson(String str) =>
    Sendreturnorder.fromJson(json.decode(str));

String sendreturnorderToJson(Sendreturnorder data) =>
    json.encode(data.toJson());

class Sendreturnorder {
  Sendreturnorder({
    this.salesOrderId,
    this.items,
    this.orderKind,
    this.returnReason,
    this.customerid,
    this.cancellationType,
  });

  String salesOrderId;
  List<ItemValue> items;
  String orderKind;
  String returnReason;
  String cancellationType;
  String customerid;

  factory Sendreturnorder.fromJson(Map<String, dynamic> json) =>
      Sendreturnorder(
        salesOrderId: json["sales_order_id"],
        items: List<ItemValue>.from(
            json["items"].map((x) => ItemValue.fromJson(x))),
        orderKind: json["order_kind"],
        cancellationType: json["cancellation_type"],
        customerid: json["customer_id"]
      );

  Map<String, dynamic> toJson() => {
        "sales_order_id": salesOrderId,
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
        "order_kind": orderKind,
        "return_reason": returnReason,
        "cancellation_type": cancellationType,
        "customer_id":customerid
      };
}

class ItemValue {
  ItemValue({
    this.id,
    this.quoteId,
    this.sku,
    this.articleNumber,
    this.department,
    this.name,
    this.shelfNumber,
    this.shelfSortNumber,
    this.qty,
    this.price,
    this.dfc,
    this.imageUrl,
  });

  String id;
  String quoteId;
  String sku;
  String articleNumber;
  String department;
  String name;
  String shelfNumber;
  String shelfSortNumber;
  int qty;
  double price;
  String dfc;
  dynamic imageUrl;

  factory ItemValue.fromJson(Map<String, dynamic> json) => ItemValue(
        id: json["id"],
        quoteId: json["quote_id"],
        sku: json["sku"],
        articleNumber: json["article_number"],
        department: json["department"],
        name: json["name"],
        shelfNumber: json["shelf_number"],
        shelfSortNumber: json["shelf_sort_number"],
        qty: json["qty"],
        price: json["price"],
        dfc: json["dfc"],
        imageUrl: json["image_url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "quote_id": quoteId,
        "sku": sku,
        "article_number": articleNumber,
        "department": department,
        "name": name,
        "shelf_number": shelfNumber,
        "shelf_sort_number": shelfSortNumber,
        "qty": qty,
        "price": price,
        "dfc": dfc,
        "image_url": imageUrl,
      };
}
