class CompletedOrderListModel {
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

  CompletedOrderListModel({
    this.status,
    this.shoppingid,
    this.increment_id,
    this.datetime,
    this.orderid,
    this.noitem,
    this.price,
    this.title,
    this.createdAt,
    this.updatedAt,
  });
}
