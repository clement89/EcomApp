import 'dart:convert';

class OrderListModel {
  final String status;
  final String datetime;
  final String orderid;
  final String noitem;
  final String price;
  final String title;
  final String shoppingid;
  final String increment_id;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderListModel(
      this.status,
      this.shoppingid,
      this.increment_id,
      this.datetime,
      this.orderid,
      this.noitem,
      this.price,
      this.title,
      this.createdAt,
      this.updatedAt);
}

// To parse this JSON data, do
//
//     final orderList = orderListFromJson(jsonString);

List<OrderList> orderListFromJson(String str) =>
    List<OrderList>.from(json.decode(str).map((x) => OrderList.fromJson(x)));

class OrderList {
  OrderList({
    this.orders,
  });

  List<Order> orders;

  factory OrderList.fromJson(Map<String, dynamic> json) => OrderList(
        orders: List<Order>.from(json["orders"].map((x) => Order.fromJson(x))),
      );
}

class Order {
  Order({
    this.entityId,
    this.state,
    this.status,
    this.baseGrandTotal,
    this.createdAt,
    this.updatedAt,
    this.totalItemCount,
    this.shippingAddressId,
    this.incrementId,
    this.items,
  });

  String entityId;
  String state;
  String status;
  String baseGrandTotal;
  DateTime createdAt;
  DateTime updatedAt;
  String totalItemCount;
  String shippingAddressId;
  String incrementId;
  List<dynamic> items;

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        entityId: json["entity_id"],
        state: json["state"],
        status: json["status"] ?? "",
        baseGrandTotal: json["base_grand_total"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        totalItemCount: json["total_item_count"],
        shippingAddressId: json["shipping_address_id"],
        incrementId: json["increment_id"],
        items: List<dynamic>.from(json["items"].map((x) => x)),
      );
}
