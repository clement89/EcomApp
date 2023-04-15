// To parse this JSON data, do
//
//     final sentsubstitute = sentsubstituteFromJson(jsonString);
import 'dart:convert';

String sentsubstituteToJson(Sentsubstitute data) => json.encode(data.toJson());

class Sentsubstitute {
  Sentsubstitute({
    this.originalItemId,
    this.itemType,
    this.originalItemExistingQty,
    this.newItems,
  });

  int originalItemId;
  String itemType;
  int originalItemExistingQty;
  List<SubstituteCartItem> newItems;

  Map<String, dynamic> toJson() => {
        "original_item_id": originalItemId,
        "item_type": itemType,
        "original_item_existing_qty": originalItemExistingQty,
        "new_items": List<dynamic>.from(newItems.map((x) => x.toJson())),
      };
}

class SubstituteCartItem {
  SubstituteCartItem({
    this.id,
    this.qty,
    this.name,
    this.position,
    this.dfc,
    this.department,
    this.price,
    this.sku,
    this.priceWithoutTax,
    this.tax,
  });

  int id;
  int qty;
  String name;
  String position;
  String dfc;
  String sku;
  String department;
  double price;
  double priceWithoutTax;
  double tax;

  Map<String, dynamic> toJson() => {
        "id": id,
        "qty": qty,
        "name": name,
        "position": position,
        "dfc": dfc,
        "department": department,
        "price": price,
        "sku": sku
      };
}
