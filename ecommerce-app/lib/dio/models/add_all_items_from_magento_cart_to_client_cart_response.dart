// To parse this JSON data, do
//
//     final addAllItemsInMagentoCartToClientCartResponse = addAllItemsInMagentoCartToClientCartResponseFromJson(jsonString);

import 'dart:convert';

List<AddAllItemsInMagentoCartToClientCartResponse> addAllItemsInMagentoCartToClientCartResponseFromJson(String str) => List<AddAllItemsInMagentoCartToClientCartResponse>.from(json.decode(str).map((x) => AddAllItemsInMagentoCartToClientCartResponse.fromJson(x)));

String addAllItemsInMagentoCartToClientCartResponseToJson(List<AddAllItemsInMagentoCartToClientCartResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AddAllItemsInMagentoCartToClientCartResponse {
  AddAllItemsInMagentoCartToClientCartResponse({
    this.storeId,
    this.entityId,
    this.attributeSetId,
    this.typeId,
    this.sku,
    this.hasOptions,
    this.requiredOptions,
    this.createdAt,
    this.updatedAt,
    this.shelfNumber,
    this.optionsContainer,
    this.status,
    this.msrpDisplayActualPriceType,
    this.giftMessageAvailable,
    this.swatchImage,
    this.articleNumber,
    this.barcode,
    this.mwDeliveryTimeFrom,
    this.sapCategoryId,
    this.urlKey,
    this.shelfSortNumber,
    this.sapDivisionNum,
    this.sapDistributionChannel,
    this.sapQtyNumerator,
    this.sapQtyDenominator,
    this.nestoBrands,
    this.nestoPromotions,
    this.baseUnitOfMeasure,
    this.sellingOptions,
    this.thumbnail,
    this.visibility,
    this.quantityAndStockStatus,
    this.taxClassId,
    this.smallImage,
    this.amrolepermissionsOwner,
    this.amxnotifHideAlert,
    this.image,
    this.mwDeliveryTimeEnabled,
    this.name,
    this.price,
    this.mwDeliveryTimeVisible,
    this.options,
    this.mediaGallery,
    this.extensionAttributes,
    this.tierPrice,
    this.tierPriceChanged,
    this.categoryIds,
    this.isSalable,
    this.backorderStatus,
    this.salableQty,
    this.maxQty,
    this.minQty,
    this.taxPercentage,
    this.taxIncludedPrice,
    this.taxIncludedSpecialPrice,
    this.weight,
    this.searchKeywords,
  });

  String storeId;
  String entityId;
  String attributeSetId;
  String typeId;
  String sku;
  String hasOptions;
  String requiredOptions;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic shelfNumber;
  String optionsContainer;
  String status;
  String msrpDisplayActualPriceType;
  String giftMessageAvailable;
  String swatchImage;
  String articleNumber;
  String barcode;
  String mwDeliveryTimeFrom;
  String sapCategoryId;
  String urlKey;
  dynamic shelfSortNumber;
  String sapDivisionNum;
  String sapDistributionChannel;
  String sapQtyNumerator;
  String sapQtyDenominator;
  String nestoBrands;
  String nestoPromotions;
  String baseUnitOfMeasure;
  String sellingOptions;
  String thumbnail;
  String visibility;
  QuantityAndStockStatus quantityAndStockStatus;
  String taxClassId;
  String smallImage;
  String amrolepermissionsOwner;
  String amxnotifHideAlert;
  String image;
  String mwDeliveryTimeEnabled;
  String name;
  String price;
  String mwDeliveryTimeVisible;
  List<dynamic> options;
  MediaGallery mediaGallery;
  ExtensionAttributes extensionAttributes;
  List<dynamic> tierPrice;
  int tierPriceChanged;
  List<String> categoryIds;
  int isSalable;
  int backorderStatus;
  int salableQty;
  int maxQty;
  int minQty;
  String taxPercentage;
  String taxIncludedPrice;
  String taxIncludedSpecialPrice;
  String weight;
  String searchKeywords;

  factory AddAllItemsInMagentoCartToClientCartResponse.fromJson(Map<String, dynamic> json) => AddAllItemsInMagentoCartToClientCartResponse(
    storeId: json["store_id"] == null ? null : json["store_id"],
    entityId: json["entity_id"] == null ? null : json["entity_id"],
    attributeSetId: json["attribute_set_id"] == null ? null : json["attribute_set_id"],
    typeId: json["type_id"] == null ? null : json["type_id"],
    sku: json["sku"] == null ? null : json["sku"],
    hasOptions: json["has_options"] == null ? null : json["has_options"],
    requiredOptions: json["required_options"] == null ? null : json["required_options"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    shelfNumber: json["shelf_number"],
    optionsContainer: json["options_container"] == null ? null : json["options_container"],
    status: json["status"] == null ? null : json["status"],
    msrpDisplayActualPriceType: json["msrp_display_actual_price_type"] == null ? null : json["msrp_display_actual_price_type"],
    giftMessageAvailable: json["gift_message_available"] == null ? null : json["gift_message_available"],
    swatchImage: json["swatch_image"] == null ? null : json["swatch_image"],
    articleNumber: json["article_number"] == null ? null : json["article_number"],
    barcode: json["barcode"] == null ? null : json["barcode"],
    mwDeliveryTimeFrom: json["mw_delivery_time_from"] == null ? null : json["mw_delivery_time_from"],
    sapCategoryId: json["sap_category_id"] == null ? null : json["sap_category_id"],
    urlKey: json["url_key"] == null ? null : json["url_key"],
    shelfSortNumber: json["shelf_sort_number"],
    sapDivisionNum: json["sap_division_num"] == null ? null : json["sap_division_num"],
    sapDistributionChannel: json["sap_distribution_channel"] == null ? null : json["sap_distribution_channel"],
    sapQtyNumerator: json["sap_qty_numerator"] == null ? null : json["sap_qty_numerator"],
    sapQtyDenominator: json["sap_qty_denominator"] == null ? null : json["sap_qty_denominator"],
    nestoBrands: json["nesto_brands"] == null ? null : json["nesto_brands"],
    nestoPromotions: json["nesto_promotions"] == null ? null : json["nesto_promotions"],
    baseUnitOfMeasure: json["base_unit_of_measure"] == null ? null : json["base_unit_of_measure"],
    sellingOptions: json["selling_options"] == null ? null : json["selling_options"],
    thumbnail: json["thumbnail"] == null ? null : json["thumbnail"],
    visibility: json["visibility"] == null ? null : json["visibility"],
    quantityAndStockStatus: json["quantity_and_stock_status"] == null ? null : QuantityAndStockStatus.fromJson(json["quantity_and_stock_status"]),
    taxClassId: json["tax_class_id"] == null ? null : json["tax_class_id"],
    smallImage: json["small_image"] == null ? null : json["small_image"],
    amrolepermissionsOwner: json["amrolepermissions_owner"] == null ? null : json["amrolepermissions_owner"],
    amxnotifHideAlert: json["amxnotif_hide_alert"] == null ? null : json["amxnotif_hide_alert"],
    image: json["image"] == null ? null : json["image"],
    mwDeliveryTimeEnabled: json["mw_delivery_time_enabled"] == null ? null : json["mw_delivery_time_enabled"],
    name: json["name"] == null ? null : json["name"],
    price: json["price"] == null ? null : json["price"],
    mwDeliveryTimeVisible: json["mw_delivery_time_visible"] == null ? null : json["mw_delivery_time_visible"],
    options: json["options"] == null ? null : List<dynamic>.from(json["options"].map((x) => x)),
    mediaGallery: json["media_gallery"] == null ? null : MediaGallery.fromJson(json["media_gallery"]),
    extensionAttributes: json["extension_attributes"] == null ? null : ExtensionAttributes.fromJson(json["extension_attributes"]),
    tierPrice: json["tier_price"] == null ? null : List<dynamic>.from(json["tier_price"].map((x) => x)),
    tierPriceChanged: json["tier_price_changed"] == null ? null : json["tier_price_changed"],
    categoryIds: json["category_ids"] == null ? null : List<String>.from(json["category_ids"].map((x) => x)),
    isSalable: json["is_salable"] == null ? null : json["is_salable"],
    backorderStatus: json["backorderStatus"] == null ? null : json["backorderStatus"],
    salableQty: json["salable_qty"] == null ? null : json["salable_qty"],
    maxQty: json["max_qty"] == null ? null : json["max_qty"],
    minQty: json["min_qty"] == null ? null : json["min_qty"],
    taxPercentage: json["tax_percentage"] == null ? null : json["tax_percentage"],
    taxIncludedPrice: json["tax_included_price"] == null ? null : json["tax_included_price"],
    taxIncludedSpecialPrice: json["tax_included_special_price"] == null ? null : json["tax_included_special_price"],
    weight: json["weight"] == null ? null : json["weight"],
    searchKeywords: json["search_keywords"] == null ? null : json["search_keywords"],
  );

  Map<String, dynamic> toJson() => {
    "store_id": storeId == null ? null : storeId,
    "entity_id": entityId == null ? null : entityId,
    "attribute_set_id": attributeSetId == null ? null : attributeSetId,
    "type_id": typeId == null ? null : typeId,
    "sku": sku == null ? null : sku,
    "has_options": hasOptions == null ? null : hasOptions,
    "required_options": requiredOptions == null ? null : requiredOptions,
    "created_at": createdAt == null ? null : createdAt.toIso8601String(),
    "updated_at": updatedAt == null ? null : updatedAt.toIso8601String(),
    "shelf_number": shelfNumber,
    "options_container": optionsContainer == null ? null : optionsContainer,
    "status": status == null ? null : status,
    "msrp_display_actual_price_type": msrpDisplayActualPriceType == null ? null : msrpDisplayActualPriceType,
    "gift_message_available": giftMessageAvailable == null ? null : giftMessageAvailable,
    "swatch_image": swatchImage == null ? null : swatchImage,
    "article_number": articleNumber == null ? null : articleNumber,
    "barcode": barcode == null ? null : barcode,
    "mw_delivery_time_from": mwDeliveryTimeFrom == null ? null : mwDeliveryTimeFrom,
    "sap_category_id": sapCategoryId == null ? null : sapCategoryId,
    "url_key": urlKey == null ? null : urlKey,
    "shelf_sort_number": shelfSortNumber,
    "sap_division_num": sapDivisionNum == null ? null : sapDivisionNum,
    "sap_distribution_channel": sapDistributionChannel == null ? null : sapDistributionChannel,
    "sap_qty_numerator": sapQtyNumerator == null ? null : sapQtyNumerator,
    "sap_qty_denominator": sapQtyDenominator == null ? null : sapQtyDenominator,
    "nesto_brands": nestoBrands == null ? null : nestoBrands,
    "nesto_promotions": nestoPromotions == null ? null : nestoPromotions,
    "base_unit_of_measure": baseUnitOfMeasure == null ? null : baseUnitOfMeasure,
    "selling_options": sellingOptions == null ? null : sellingOptions,
    "thumbnail": thumbnail == null ? null : thumbnail,
    "visibility": visibility == null ? null : visibility,
    "quantity_and_stock_status": quantityAndStockStatus == null ? null : quantityAndStockStatus.toJson(),
    "tax_class_id": taxClassId == null ? null : taxClassId,
    "small_image": smallImage == null ? null : smallImage,
    "amrolepermissions_owner": amrolepermissionsOwner == null ? null : amrolepermissionsOwner,
    "amxnotif_hide_alert": amxnotifHideAlert == null ? null : amxnotifHideAlert,
    "image": image == null ? null : image,
    "mw_delivery_time_enabled": mwDeliveryTimeEnabled == null ? null : mwDeliveryTimeEnabled,
    "name": name == null ? null : name,
    "price": price == null ? null : price,
    "mw_delivery_time_visible": mwDeliveryTimeVisible == null ? null : mwDeliveryTimeVisible,
    "options": options == null ? null : List<dynamic>.from(options.map((x) => x)),
    "media_gallery": mediaGallery == null ? null : mediaGallery.toJson(),
    "extension_attributes": extensionAttributes == null ? null : extensionAttributes.toJson(),
    "tier_price": tierPrice == null ? null : List<dynamic>.from(tierPrice.map((x) => x)),
    "tier_price_changed": tierPriceChanged == null ? null : tierPriceChanged,
    "category_ids": categoryIds == null ? null : List<dynamic>.from(categoryIds.map((x) => x)),
    "is_salable": isSalable == null ? null : isSalable,
    "backorderStatus": backorderStatus == null ? null : backorderStatus,
    "salable_qty": salableQty == null ? null : salableQty,
    "max_qty": maxQty == null ? null : maxQty,
    "min_qty": minQty == null ? null : minQty,
    "tax_percentage": taxPercentage == null ? null : taxPercentage,
    "tax_included_price": taxIncludedPrice == null ? null : taxIncludedPrice,
    "tax_included_special_price": taxIncludedSpecialPrice == null ? null : taxIncludedSpecialPrice,
    "weight": weight == null ? null : weight,
    "search_keywords": searchKeywords == null ? null : searchKeywords,
  };
}

class ExtensionAttributes {
  ExtensionAttributes();

  factory ExtensionAttributes.fromJson(Map<String, dynamic> json) => ExtensionAttributes(
  );

  Map<String, dynamic> toJson() => {
  };
}

class MediaGallery {
  MediaGallery({
    this.images,
    this.values,
  });

  dynamic images;
  List<dynamic> values;

  factory MediaGallery.fromJson(Map<String, dynamic> json) => MediaGallery(
    images: json["images"],
    values: json["values"] == null ? null : List<dynamic>.from(json["values"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "images": images,
    "values": values == null ? null : List<dynamic>.from(values.map((x) => x)),
  };
}

class ImagesClass {
  ImagesClass({
    this.the218,
  });

  The218 the218;

  factory ImagesClass.fromJson(Map<String, dynamic> json) => ImagesClass(
    the218: json["218"] == null ? null : The218.fromJson(json["218"]),
  );

  Map<String, dynamic> toJson() => {
    "218": the218 == null ? null : the218.toJson(),
  };
}

class The218 {
  The218({
    this.valueId,
    this.file,
    this.mediaType,
    this.entityId,
    this.label,
    this.position,
    this.disabled,
    this.labelDefault,
    this.positionDefault,
    this.disabledDefault,
    this.videoProvider,
    this.videoUrl,
    this.videoTitle,
    this.videoDescription,
    this.videoMetadata,
    this.videoProviderDefault,
    this.videoUrlDefault,
    this.videoTitleDefault,
    this.videoDescriptionDefault,
    this.videoMetadataDefault,
  });

  String valueId;
  String file;
  String mediaType;
  String entityId;
  dynamic label;
  String position;
  String disabled;
  dynamic labelDefault;
  String positionDefault;
  String disabledDefault;
  dynamic videoProvider;
  dynamic videoUrl;
  dynamic videoTitle;
  dynamic videoDescription;
  dynamic videoMetadata;
  dynamic videoProviderDefault;
  dynamic videoUrlDefault;
  dynamic videoTitleDefault;
  dynamic videoDescriptionDefault;
  dynamic videoMetadataDefault;

  factory The218.fromJson(Map<String, dynamic> json) => The218(
    valueId: json["value_id"] == null ? null : json["value_id"],
    file: json["file"] == null ? null : json["file"],
    mediaType: json["media_type"] == null ? null : json["media_type"],
    entityId: json["entity_id"] == null ? null : json["entity_id"],
    label: json["label"],
    position: json["position"] == null ? null : json["position"],
    disabled: json["disabled"] == null ? null : json["disabled"],
    labelDefault: json["label_default"],
    positionDefault: json["position_default"] == null ? null : json["position_default"],
    disabledDefault: json["disabled_default"] == null ? null : json["disabled_default"],
    videoProvider: json["video_provider"],
    videoUrl: json["video_url"],
    videoTitle: json["video_title"],
    videoDescription: json["video_description"],
    videoMetadata: json["video_metadata"],
    videoProviderDefault: json["video_provider_default"],
    videoUrlDefault: json["video_url_default"],
    videoTitleDefault: json["video_title_default"],
    videoDescriptionDefault: json["video_description_default"],
    videoMetadataDefault: json["video_metadata_default"],
  );

  Map<String, dynamic> toJson() => {
    "value_id": valueId == null ? null : valueId,
    "file": file == null ? null : file,
    "media_type": mediaType == null ? null : mediaType,
    "entity_id": entityId == null ? null : entityId,
    "label": label,
    "position": position == null ? null : position,
    "disabled": disabled == null ? null : disabled,
    "label_default": labelDefault,
    "position_default": positionDefault == null ? null : positionDefault,
    "disabled_default": disabledDefault == null ? null : disabledDefault,
    "video_provider": videoProvider,
    "video_url": videoUrl,
    "video_title": videoTitle,
    "video_description": videoDescription,
    "video_metadata": videoMetadata,
    "video_provider_default": videoProviderDefault,
    "video_url_default": videoUrlDefault,
    "video_title_default": videoTitleDefault,
    "video_description_default": videoDescriptionDefault,
    "video_metadata_default": videoMetadataDefault,
  };
}

class QuantityAndStockStatus {
  QuantityAndStockStatus({
    this.isInStock,
    this.qty,
  });

  bool isInStock;
  int qty;

  factory QuantityAndStockStatus.fromJson(Map<String, dynamic> json) => QuantityAndStockStatus(
    isInStock: json["is_in_stock"] == null ? null : json["is_in_stock"],
    qty: json["qty"] == null ? null : json["qty"],
  );

  Map<String, dynamic> toJson() => {
    "is_in_stock": isInStock == null ? null : isInStock,
    "qty": qty == null ? null : qty,
  };
}
