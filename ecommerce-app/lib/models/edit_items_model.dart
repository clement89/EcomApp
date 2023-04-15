class EditItemsModel {
  final String img;
  final String itemid;
  int count;
  final String itemname;
  String price;
  String taxCalculatedPrice;
  String tax;
  final String shipping;
  String coupon;
  final String quote_item_id;
  final String article_number;
  final String shelf_number;
  final String shelf_sort_number;
  final String product_id;
  final String product_type;
  final String sku;
  final String discountPercentage;
  bool stockList;
  String taxPercentage;
  String baseprice;
  String taxCalculatedWithOutDiscount;
  final String barcode;
  final String rowTotel;
  String subTotel;

  EditItemsModel(
      {this.quote_item_id,
      this.article_number,
      this.barcode,
      this.shelf_number,
      this.shelf_sort_number,
      this.product_id,
      this.product_type,
      this.sku,
      this.count,
      this.itemname,
      this.price,
      this.img,
      this.tax,
      this.taxCalculatedPrice,
      this.taxCalculatedWithOutDiscount,
      this.taxPercentage,
      this.shipping,
      this.coupon,
      this.itemid,
      this.stockList,
      this.baseprice,
      this.subTotel,
      this.discountPercentage,
      this.rowTotel});
}

/*

EditOrder editOrderFromJson(String str) => EditOrder.fromJson(json.decode(str));


class EditOrder {
  EditOrder({
    this.items,
  });

  List<Item> items;

  factory EditOrder.fromJson(Map<String, dynamic> json) => EditOrder(
    items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
  );
}

class Item {
  Item({
    this.itemId,
    this.orderId,
    this.quoteItemId,
    this.storeId,
    this.productId,
    this.productType,
    this.weight,
    this.sku,
    this.name,
    this.qtyOrdered,
    this.basePrice,
    this.baseOriginalPrice,
    this.taxAmount,
    this.baseTaxAmount,
    this.taxPercent,
    this.baseTaxInvoiced,
    this.baseDiscountAmount,
    this.baseRowTotal,
    this.priceInclTax,
    this.basePriceInclTax,
    this.rowTotalInclTax,
    this.baseRowTotalInclTax,
    this.articleNumber,
    this.barcode,
    this.shelfNumber,
    this.shelfSortNumber,
  });

  String itemId;
  String orderId;
  String quoteItemId;
  String storeId;
  String productId;
  String productType;
  dynamic weight;
  String sku;
  String name;
  String qtyOrdered;
  String basePrice;
  String baseOriginalPrice;
  String taxAmount;
  String baseTaxAmount;
  String taxPercent;
  String baseTaxInvoiced;
  String baseDiscountAmount;
  String baseRowTotal;
  String priceInclTax;
  String basePriceInclTax;
  String rowTotalInclTax;
  String baseRowTotalInclTax;
  String articleNumber;
  String barcode;
  dynamic shelfNumber;
  dynamic shelfSortNumber;

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    itemId: json["item_id"],
    orderId: json["order_id"],
    quoteItemId: json["quote_item_id"],
    storeId: json["store_id"],
    productId: json["product_id"],
    productType: json["product_type"],
    weight: json["weight"],
    sku: json["sku"],
    name: json["name"],
    qtyOrdered: json["qty_ordered"],
    basePrice: json["base_price"],
    baseOriginalPrice: json["base_original_price"],
    taxAmount: json["tax_amount"],
    baseTaxAmount: json["base_tax_amount"],
    taxPercent: json["tax_percent"],
    baseTaxInvoiced: json["base_tax_invoiced"],
    baseDiscountAmount: json["base_discount_amount"],
    baseRowTotal: json["base_row_total"],
    priceInclTax: json["price_incl_tax"],
    basePriceInclTax: json["base_price_incl_tax"],
    rowTotalInclTax: json["row_total_incl_tax"],
    baseRowTotalInclTax: json["base_row_total_incl_tax"],
    articleNumber: json["article_number"],
    barcode: json["barcode"],
    shelfNumber: json["shelf_number"],
    shelfSortNumber: json["shelf_sort_number"],);
}

*/
