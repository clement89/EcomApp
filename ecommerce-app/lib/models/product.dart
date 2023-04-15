import 'package:Nesto/models/main_category.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_flavor/flutter_flavor.dart';

class Product with ChangeNotifier {
  //Values which cannot be changed
  final String sku, name, brand, imageURL, description;
  final int id,
      weight,
      status,
      catIndexPosition,
      backOrderStatus,
      quantityMagento,
      minimumQuantity;
  final double taxIncludedPrice,
      taxIncludedSpecialPrice,
      tax,
      rating,
      taxExcludedPrice,
      taxExcludedSpecialPrice,
      crossPrice;
  final List imageUrls;
  final bool inStock, productInStockMagento;
  final MainCategory mainCategory, subCategory;
  final DateTime saleStartDate, saleEndDate;

  double get priceWithTax {
    //Check if there is a special price
    if (taxIncludedSpecialPrice != 0) {
      //Validate special price dates
      if (saleStartDate != null && saleEndDate != null) {
        DateTime now = DateTime.now();
        if (now.isAfter(saleStartDate) && now.isBefore(saleEndDate)) {
          return taxIncludedSpecialPrice;
        }
      }
    }
    //Return taxIncludedPrice price if any condition fails
    return taxIncludedPrice;
  }

  double get priceWithoutTax {
    //Check if there is a special price
    if (taxExcludedSpecialPrice != 0) {
      //Validate special price dates
      if (saleStartDate != null && saleEndDate != null) {
        DateTime now = DateTime.now();
        if (now.isAfter(saleStartDate) && now.isBefore(saleEndDate)) {
          return taxExcludedSpecialPrice;
        }
      }
    }
    //Return taxExcludedPrice price if any condition fails
    return taxExcludedPrice;
  }

  bool get isSpecialPriceAvailable {
    if (taxIncludedSpecialPrice != 0) {
      //Validate special price dates
      if (saleStartDate != null && saleEndDate != null) {
        DateTime now = DateTime.now();
        if (now.isAfter(saleStartDate) && now.isBefore(saleEndDate)) {
          return true;
        }
      }
    }
    //Return taxIncludedPrice price if any condition fails
    return false;
  }

  double get discount {
    if (taxIncludedSpecialPrice == 0)
      return 0;
    else {
      var discount = 0.0;
      if (crossPrice == null || crossPrice == 0) {
        discount =
            ((taxIncludedPrice - taxIncludedSpecialPrice) / taxIncludedPrice) *
                100;
      } else {
        discount = ((crossPrice - taxIncludedSpecialPrice) / crossPrice) * 100;
      }
      return discount;
    }
  }

  bool get isBackOrder {
    return backOrderStatus == 1 ? true : false;
  }

  Product({
    @required this.sku,
    @required this.id,
    @required this.status,
    @required this.weight,
    @required this.name,
    @required this.description,
    @required this.brand,
    @required this.imageURL,
    @required this.rating,
    @required this.inStock,
    @required this.productInStockMagento,
    @required this.quantityMagento,
    @required this.mainCategory,
    @required this.imageUrls,
    @required this.subCategory,
    @required this.taxExcludedPrice,
    @required this.taxExcludedSpecialPrice,
    @required this.taxIncludedPrice,
    @required this.taxIncludedSpecialPrice,
    @required this.tax,
    @required this.saleStartDate,
    @required this.saleEndDate,
    @required this.catIndexPosition,
    @required this.crossPrice,
    @required this.backOrderStatus,
    @required this.minimumQuantity
  });

  static fromJson(json, bool single) {
    var status = int.parse(json["status"]);
    if (status == null) status = 0;

    final String _productImageBaseUrl =
        FlavorConfig.instance.variables["PRODUCT_IMAGE_BASE_URL"];

    List<Product> loadedProducts = [];

    //logNesto("BATMAN:"+json.keys.toList().toString());

    if (status == 1) {
      if (json["type_id"] == "simple") {
        //Get the prices
        var taxIncludedPrice = json["tax_included_price"];
        var taxIncludedSpecialPrice = json["tax_included_special_price"];
        var tax = json["tax_percentage"];

        var taxExcludedPrice = json["price"];
        var taxExcludedSpecialPrice = json["special_price"];
        var crossPrice = json["cross_price"];

        //logNesto("REAL PRICE ${json["name"]}:"+price.toString());

        var mediaGalleryEntries =
            json["media_gallery_entries"] as List<dynamic>;

        List<String> loadedImageUrls = [];
        // mediaGalleryEntries.forEach((mediaElement) {
        //   if(mediaElement["media_type"] == "image"){
        //     var url = values.IMAGE_BASE_URL + mediaElement["file"];
        //     if(json["name"].contains("Suriyan")) logNesto("IMAGE URL:"+url);
        //     loadedImageUrls.add(url);
        //   }
        // });

        var imageElement = json["image"];
        var imageUrl;

        if (imageElement != null) {
          if (!json["image"].contains("http")) {
            imageUrl = _productImageBaseUrl + json["image"];
          } else {
            imageUrl = json["image"];
          }
        } else {
          imageUrl = _productImageBaseUrl + "/nesto.jpg";
        }

        //Check product stock
        //Calculate stock data
        // var stockJson = json["quantity_and_stock_status"];
        // bool stock = stockJson["is_in_stock"];
        // int quantity = stockJson["qty"];
        var salableJson = json["is_salable"];
        int backOrderStatus = json["backorderStatus"] is int
            ? json["backorderStatus"]
            : int.parse(json["backorderStatus"] ?? "0");
        int salable;

        if (salableJson is int)
          salable = salableJson;
        else
          salable = int.parse(salableJson);

          int minimumQuantity = json['min_qty'] ?? 1;

        bool isInStock = (salable > 0);
        bool productInStockMagento =
            json["quantity_and_stock_status"]["is_in_stock"];
        int quantityMagento = json["quantity_and_stock_status"]["qty"];
        //Check sale date
        var saleStartString = json["special_from_date"];
        var saleEndString = json["special_to_date"];

        DateTime saleStartDate, saleEndDate;

        if (saleStartString != null && saleEndString != null) {
          saleStartDate = DateTime.parse(saleStartString);
          saleEndDate = DateTime.parse(saleEndString);
        }

        //Cat position index
        var catPosition = json["cat_index_position"];

        int catIndex = 0;

        if (catPosition != null) catIndex = int.parse(catPosition);

        //Price check
        var price = double.parse(json["price"]);

        if (price != 0) {
          loadedProducts.add(Product(
              id: int.parse(json["entity_id"]),
              sku: json["sku"],
              name: json["name"],
              taxIncludedPrice:
                  taxIncludedPrice != null ? double.parse(taxIncludedPrice) : 0,
              taxIncludedSpecialPrice: taxIncludedSpecialPrice != null
                  ? double.parse(taxIncludedSpecialPrice)
                  : 0,
              crossPrice: crossPrice != null ? double.parse(crossPrice) : 0,
              tax: tax != null ? double.parse(tax) : 0,
              status: int.parse(json["status"]),
              description: json["description"],
              brand: "Nesto",
              inStock: isInStock,
              productInStockMagento: productInStockMagento,
              quantityMagento: quantityMagento,
              minimumQuantity: minimumQuantity,
              backOrderStatus: backOrderStatus,
              weight: 0,
              taxExcludedPrice:
                  taxExcludedPrice != null ? double.parse(taxExcludedPrice) : 0,
              taxExcludedSpecialPrice: taxExcludedSpecialPrice != null
                  ? double.parse(taxExcludedSpecialPrice)
                  : 0,
              rating: 5,
              imageUrls: loadedImageUrls,
              imageURL: imageUrl,
              saleStartDate: saleStartDate,
              saleEndDate: saleEndDate,
              catIndexPosition: catIndex,
              mainCategory: MainCategory(name: json["name"]),
              subCategory: MainCategory(name: json["name"])));
        }
      } else {
        List<dynamic> configurableChildren = json["configurable_child_data"];

        if (configurableChildren != null) {
          configurableChildren.forEach((json) {
            //Get the prices
            var taxIncludedPrice = json["tax_included_price"];
            var taxIncludedSpecialPrice = json["tax_included_special_price"];
            var tax = json["tax_percentage"];

            var taxExcludedPrice = json["price"];
            var taxExcludedSpecialPrice = json["special_price"];
            var crossPrice = json["cross_price"];

            //logNesto("CONFIGURABLE PRODUCT PRICE:"+json["price"]);
            // logNesto("CONFIGURABLE PRODUCT TIP PRICE:"+json["tax_included_price"]);
            // logNesto("CONFIGURABLE PRODUCT TISP PRICE:"+json["tax_included_special_price"]);

            //logNesto("REAL PRICE ${json["name"]}:"+price.toString());

            var mediaGalleryEntries =
                json["media_gallery_entries"] as List<dynamic>;

            List<String> loadedImageUrls = [];
            // mediaGalleryEntries.forEach((mediaElement) {
            //   if(mediaElement["media_type"] == "image"){
            //     var url = values.IMAGE_BASE_URL + mediaElement["file"];
            //     if(json["name"].contains("Suriyan")) logNesto("IMAGE URL:"+url);
            //     loadedImageUrls.add(url);
            //   }
            // });

            var imageElement = json["image"];
            var imageUrl;

            if (imageElement != null) {
              if (!json["image"].contains("http")) {
                imageUrl = _productImageBaseUrl + json["image"];
              } else {
                imageUrl = json["image"];
              }
            } else {
              imageUrl = _productImageBaseUrl + "/nesto.jpg";
            }

            //Check product stock
            //Calculate stock data
            // var stockJson = json["quantity_and_stock_status"];
            // bool stock = stockJson["is_in_stock"];
            // int quantity = stockJson["qty"];
            var salableJson = json["is_salable"];
            int backOrderStatus = json["backorderStatus"] is int
                ? json["backorderStatus"]
                : int.parse(json["backorderStatus"] ?? "0");

            int salable;

            if (salableJson is int)
              salable = salableJson;
            else
              salable = int.parse(salableJson);

              int minimumQuantity = json['min_qty'] ?? 1;

            bool isInStock = (salable > 0);
            bool productInStockMagento =
                json["quantity_and_stock_status"]["is_in_stock"];
            int quantityMagento = json["quantity_and_stock_status"]["qty"];

            //Check sale date
            var saleStartString = json["special_from_date"];
            var saleEndString = json["special_to_date"];

            DateTime saleStartDate, saleEndDate;

            if (saleStartString != null && saleEndString != null) {
              saleStartDate = DateTime.parse(saleStartString);
              saleEndDate = DateTime.parse(saleEndString);
            }

            //Cat position index
            var catPosition = json["cat_index_position"];

            int catIndex = 0;

            if (catPosition != null) catIndex = int.parse(catPosition);

            //Price check
            var price = double.parse(json["price"]);

            if (double.parse(taxIncludedPrice) != 0 && price != 0) {
              loadedProducts.add(Product(
                  id: int.parse(json["entity_id"]),
                  sku: json["sku"],
                  name: json["name"],
                  taxIncludedPrice: taxIncludedPrice != null
                      ? double.parse(taxIncludedPrice)
                      : 0,
                  taxIncludedSpecialPrice: taxIncludedSpecialPrice != null
                      ? double.parse(taxIncludedSpecialPrice)
                      : 0,
                  crossPrice: crossPrice != null ? double.parse(crossPrice) : 0,
                  tax: tax != null ? double.parse(tax) : 0,
                  status: int.parse(json["status"]),
                  //TODO:REMOVE DUMMY VALUES
                  //price: 10,
                  description: json["description"],
                  brand: "Nesto",
                  inStock: isInStock,
                  productInStockMagento: productInStockMagento,
                  quantityMagento: quantityMagento,
                  minimumQuantity: minimumQuantity,
                  backOrderStatus: backOrderStatus,
                  weight: 0,
                  taxExcludedPrice: taxExcludedPrice != null
                      ? double.parse(taxExcludedPrice)
                      : 0,
                  taxExcludedSpecialPrice: taxExcludedSpecialPrice != null
                      ? double.parse(taxExcludedSpecialPrice)
                      : 0,
                  rating: 5,
                  imageUrls: loadedImageUrls,
                  imageURL: imageUrl,
                  saleStartDate: saleStartDate,
                  saleEndDate: saleEndDate,
                  catIndexPosition: catIndex,
                  mainCategory: MainCategory(name: json["name"]),
                  subCategory: MainCategory(name: json["name"])));
            }
          });
        }
      }
    }

    if (loadedProducts.isNotEmpty) if (single)
      return loadedProducts.first;
    else
      return loadedProducts;
    else
      return null;
  }
}
