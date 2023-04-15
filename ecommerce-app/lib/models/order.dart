class SingleOrder {
  SingleOrder(
      {this.entityId,
      this.state,
      this.status,
      this.baseGrandTotal,
      this.createdAt,
      this.totalItemCount,
      this.shipping_address_id,
      this.increment_id});

  String entityId;
  String state;
  String status;
  String baseGrandTotal;
  DateTime createdAt;
  String totalItemCount;
  String shipping_address_id;
  String increment_id;

  factory SingleOrder.fromJson(Map<String, dynamic> json) => SingleOrder(
      entityId: json["entity_id"],
      state: json["state"],
      status: json["status"],
      baseGrandTotal: json["base_grand_total"],
      createdAt: DateTime.parse(json["created_at"]),
      totalItemCount: json["total_item_count"],
      shipping_address_id: json['shipping_address_id'],
      increment_id: json['increment_id']);

  Map<String, dynamic> toJson() => {
        "entity_id": entityId,
        "state": state,
        "status": status,
        "base_grand_total": baseGrandTotal,
        "created_at": createdAt.toIso8601String(),
        "total_item_count": totalItemCount,
        "shipping_address_id": shipping_address_id,
        "increment_id": increment_id,
      };
}
