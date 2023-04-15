import 'dart:convert' as convert;
import 'dart:convert';
import 'dart:developer';
import 'package:Nesto/strings.dart' as strings;
import 'package:Nesto/dio/utils/urls.dart';
import 'package:Nesto/models/order_details.dart';
import 'package:Nesto/models/product.dart';
import 'package:Nesto/models/substitute_model.dart';
import 'package:Nesto/models/substitutesuggestion.dart';
import 'package:Nesto/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SubstitutionProvider with ChangeNotifier {
  List<ItemSub> itemsToSubstitute = [];
  SubstituteOrder substituteOrder;
  List<Product> itemSuggestions = [];
  DateTime _cuttOffTime;
  bool isSubstitutionOngoing = false;
  int _outOfStockItemID;
  ItemSub outOfStockItem;
  double _outOfStockAmount = 0;

  var shippingLimit = 0.0;
  var shippingCharge = 0.0;
  var couponDiscountLimit = 0.0;
  bool couponApplied = false;
  String appliedCouponCode = "";
  String couponType = '';

  OrderDetails _currentOrder;

  set outOfStockAmount(double value) {
    _outOfStockAmount = value ?? 0;
  }

  set currentOrder(value) {
    _currentOrder = value;
    notifyListeners();
  }

  OrderDetails get currentOrder {
    return _currentOrder;
  }

  double get cartSubTotal {
    return double.parse(currentOrder?.subtotal ?? "0");
  }

  double get vat {
    return double.parse(currentOrder?.taxAmount ?? "0");
  }

  bool get showCouponAlert {
    return double.parse(currentOrder.baseSubtotal) < couponDiscountLimit;
  }

  set subStatus(bool value) {
    isSubstitutionOngoing = value ?? false;
  }

  set cuttOffTime(DateTime value) {
    log("set cuttOff: $value");
    _cuttOffTime = value;
    // notifyListeners();
  }

  set outOfStockItemID(value) {
    log("set outOfStockItemID: $value");
    _outOfStockItemID = value;
  }

  bool get subStatus {
    return isSubstitutionOngoing;
  }

  int get cuttOff {
    var currentTime = DateTime.now();
    int secs = _cuttOffTime.difference(currentTime).inSeconds;
    return secs;
  }

  Future getOrderDetails() async {
    var url = MAGENTO_BASE_URL +
        "/V1/customapi/orders/${substituteOrder.salesOrderId}";
    var headers = {"Authorization": 'Bearer ' + getAuthToken()};

    log("URL: $url", name: "my_order_details");
    log("HEADER: $headers", name: "my_order_details");

    var response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    var decodedResponse = convert.jsonDecode(response.body);
    // log("RESPONSE: $decodedResponse", name: "my_order_details");

    if (response.statusCode == 200) {
      currentOrder = orderDetailsFromJson(response.body);
    } else {
      throw Exception(decodedResponse["message"] ??
          strings.SOMETHING_WENT_WRONG_WITH_EXCLAMATION);
    }
  }

  double get total {
    return double.parse(currentOrder.baseGrandTotal);
  }

  bool get isShippingApplicable {
    bool _isShipppingApplied = false;
    double _shippingAmount =
        double.parse(currentOrder?.shippingAmount ?? '0').abs();
    if (_shippingAmount > 0) {
      _isShipppingApplied = true;
      return _isShipppingApplied;
    } else
      return _isShipppingApplied;
  }

  Future getSubstituteSuggestions() async {
    var queryParams = await getQueryParams() ?? "";
    var _queryParms =
        queryParams.isNotEmpty ? queryParams.toString().substring(1) : "";

    var itemId = outOfStockItem.id;
    var type = outOfStockItem.itemType;
    final substitutesuggestionurl = LAMBDA_SUBSTITUTE_URL +
        '/substitute/$itemId?item_type=$type&' +
        _queryParms;

    var headers = {
      "Content-Type": "application/json",
      "access-token": getLambdaToken() ?? ""
    };

    print("===============================>");
    print("URL: " + substitutesuggestionurl);
    print("<===============================");

    final response = await http.get(
      Uri.parse(substitutesuggestionurl),
      headers: headers,
    );

    print("===============================>");
    print("STATUS: ${response.statusCode}");
    print("<===============================");

    if (response.statusCode == 200) {
      // print("===============================>");
      // print("STATUS: ${response.body}");
      // print("<===============================");

      final substituteSuggestion = substitutesuggestionFromJson(response);
      itemSuggestions = substituteSuggestion.data.items;

      print("===============================>");
      print("SUGGESTIONS LEN: ${itemSuggestions.length}");
      print("<===============================");

      notifyListeners();
    } else {
      var decodedResponse = convert.jsonDecode(response.body);
      throw Exception(decodedResponse["message"] ??
          strings.SOMETHING_WENT_WRONG_WITH_EXCLAMATION);
    }
  }

  double get calculateOutOfStockTotal {
    return _outOfStockAmount;
  }

  bool get isCouponApplicable {
    double _subTotal = double.parse(currentOrder.baseSubtotal);

    if (!couponApplied) {
      return false;
    } else {
      if (_subTotal >= couponDiscountLimit) {
        return true;
      } else {
        return false;
      }
    }
  }

  void clearCart() {
    itemsToSubstitute.clear();
    itemSuggestions.clear();
  }

  bool isPresentInCart(Product product) {
    List<Item> items = currentOrder.items;
    bool isPresent = items.any((item) => item.sku == product.sku);
    log("isPresent: $isPresent" + "${product.name}");
    return isPresent;
  }

  double currentQuantity(Product product) {
    List<Item> items = currentOrder.items;

    Item _product = items.singleWhere((item) => item.sku == product.sku,
        orElse: () => null);
    log(
      "_product: ${_product.name ?? "not_found"} || ${_product.qtyOrdered}",
      name: "current_quantity",
    );
    if (_product != null) {
      return double.parse(_product.qtyOrdered);
    } else {
      return 0;
    }
  }

  Future getShippingLimit() async {
    log("entered shipping");
    var salesIncrementalId = substituteOrder?.salesIncrementalId;
    log(
      "salesIncrementalId: $salesIncrementalId",
    );
    final url = MAGENTO_BASE_URL +
        "/V1/shippingDetails?websiteId=${substituteOrder?.websiteID}&orderId=${substituteOrder?.salesIncrementalId}";
    final headers = {
      "Content-Type": "application/json",
    };

    log("URL: $url", name: "getShippingLimit");
    log("HEADER: $headers", name: "getShippingLimit");
    // logNestoCustom(message: "URL: $url", logType: LogType.debug);
    // logNestoCustom(message: "HEADER: $headers", logType: LogType.debug);

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    var decodedResponse = convert.jsonDecode(response?.body);
    log("shippingBodyDecoded: $decodedResponse");

    if (response.statusCode == 200) {
      log("response is 200");
      var minSubTotal =
          convert.jsonDecode(decodedResponse)["minSubTotal"] ?? "0";
      var shippingChargeLimit =
          convert.jsonDecode(decodedResponse)["shippingChargeLimit"] ?? "0";
      var shippingCharges =
          convert.jsonDecode(decodedResponse)["shippingCharges"] ?? "0";
      var couponLimit =
          convert.jsonDecode(decodedResponse)["couponMinAmount"] ?? "0";
      couponApplied =
          convert.jsonDecode(decodedResponse)["couponApplied"] ?? false;
      appliedCouponCode =
          convert.jsonDecode(decodedResponse)["appliedCouponCode"] ?? "--";
      couponType = convert.jsonDecode(decodedResponse)["couponType"] ?? "--";

      log("minSubTotal: $minSubTotal", name: "minSubTotal");
      log("shippingCharges: $shippingCharges", name: "shippingCharges");

      shippingLimit = double.parse(shippingChargeLimit) ?? 0.0;
      shippingCharge = double.parse(shippingCharges) ?? 0.0;
      couponDiscountLimit = double.parse(couponLimit) ?? 0.0;

      log("shippingLimit: $shippingLimit");
      log("shippingCharge: $shippingCharge");
      log("couponApplied: $couponApplied");
      log("couponDiscountLimit: $couponDiscountLimit");
      log("couponType: $couponType");
    } else {
      throw Exception(decodedResponse["message"] ??
          strings.SOMETHING_WENT_WRONG_WITH_EXCLAMATION);
    }
  }

  Future getOrderSubstitute(String orderid) async {
    var queryParams = await getQueryParams() ?? "";

    final orderurl = LAMBDA_SUBSTITUTE_URL + "/order/" + orderid + queryParams;
    log(orderurl, name: 'getOrderSubstitute');

    var headers = {
      "Content-Type": "application/json",
      "access-token": getLambdaToken() ?? ""
    };

    final response = await http.get(
      Uri.parse(orderurl),
      headers: headers,
    );
    log('STATUS: ${response.statusCode.toString()}',
        name: 'getOrderSubstitute');

    if (response.statusCode == 200) {
      final substitute = substituteFromJson(response);

      substituteOrder = substitute.data.singleOrder;
      log("substituteOrder: \n$substituteOrder", name: 'getOrderSubstitute');

      List<ItemSub> items = substituteOrder.items;

      var filteritems = items.where((item) => (item.substitutionInitiated));
      itemsToSubstitute = [...filteritems];

      if (itemsToSubstitute.isEmpty) {
        throw Exception(strings.SUBSTITUTION_HAS_BEEN_ALREADY_DONE + '!');
      }

      outOfStockItem = itemsToSubstitute.singleWhere(
          (stockItem) => stockItem.id == _outOfStockItemID,
          orElse: () => null);

      if (outOfStockItem != null) {
        log("item is present");
        await getShippingLimit();
        // notifyListeners();
      } else {
        throw Exception(strings.SUBSTITUTION_HAS_BEEN_ALREADY_DONE);
      }
    } else {
      var decodedResponse = convert.jsonDecode(response.body);
      throw Exception(decodedResponse["message"] ??
          strings.SOMETHING_WENT_WRONG_WITH_EXCLAMATION);
    }
  }

  double get substitutesAdded {
    double total = 0;
    List<String> previousOrderSkus =
        List.from(substituteOrder.items.map((item) => item.sku));
    log("previousOrderItems: $previousOrderSkus", name: "substitutesAdded");
    List<String> currentOrderSkus =
        List.from(currentOrder.items.map((item) => item.sku));
    log("currentOrderItesm: $currentOrderSkus", name: "substitutesAdded");
    currentOrderSkus.removeWhere((item) => previousOrderSkus.contains(item));
    log("newSkus: $currentOrderSkus");
    List<Item> substitutesAdded = currentOrder.items
        .where((item) => currentOrderSkus.contains(item.sku))
        .toList();
    log("new substitutes added ${substitutesAdded.length}");
    substitutesAdded.forEach((product) {
      log("${product.name} price: ${product.rowTotalInclTax}");
      total += double.parse(product.rowTotalInclTax ?? 0);
    });
    log("new substitutes added: $total");
    return total;
  }

  removeOutOfStock() async {
    var queryParams = await getQueryParams() ?? "";

    var url = LAMBDA_SUBSTITUTE_URL + "/substitution/v2/perform" + queryParams;

    var headers = {
      "Content-Type": "application/json",
      "access-token": getLambdaToken() ?? ""
    };

    var payload = {
      "original_item_id": outOfStockItem.id,
      "item_type": outOfStockItem.itemType,
      "original_item_existing_qty":
          (outOfStockItem.qty - outOfStockItem.quantityOutOfStock),
    };

    final response = await http.post(Uri.parse(url),
        headers: headers, body: convert.jsonEncode(payload));
    var decodedResponse = convert.jsonDecode(utf8.decode(response.bodyBytes));

    log("RESPONSE: $decodedResponse", name: "remove_out_of_stock");
    if (response.statusCode == 200) {
      var data = decodedResponse["data"];
      print("==============>");
      print("data: $data");
      print("<==============");
      outOfStockAmount = (data["out_of_stock_item_value"] ?? 0).toDouble();
      // await getOrderDetails();
      var orderDetails =
          OrderDetails.removeToOrderDetails(decodedResponse["data"]);

      print("========================>");
      print("orderDetails: $orderDetails");
      print("<========================");

      currentOrder = orderDetails;
    } else {
      throw Exception(decodedResponse["message"] ??
          strings.SOMETHING_WENT_WRONG_WITH_EXCLAMATION);
    }
  }

  addToCart(Product product) async {
    var queryParams = await getQueryParams() ?? "";
    log("adding to cart");
    var uri = LAMBDA_SUBSTITUTE_URL + "/substitution/v2/add" + queryParams;

    var headers = {
      "Content-Type": "application/json",
      "access-token": getLambdaToken() ?? ""
    };

    var payload = {
      "original_item_id": outOfStockItem.id,
      "item_type": outOfStockItem.itemType,
      "new_item": {
        "sku": product.sku,
        "qty": 1,
        "product_id": product?.id.toString() ?? ""
      }
    };

    var response = await http.post(Uri.parse(uri),
        headers: headers, body: convert.jsonEncode(payload));
    var decodedResponse = convert.jsonDecode(utf8.decode(response.bodyBytes));

    log("RESPONSE: $decodedResponse", name: "add_to_cart");

    if (response.statusCode == 200) {
      log("item added to cart", name: "add_to_cart");
      // await getOrderDetails();
      var orderDetails =
          OrderDetails.removeToOrderDetails(decodedResponse["data"]);

      print("========================>");
      print("orderDetails: $orderDetails");
      print("<========================");

      currentOrder = orderDetails;
    } else {
      throw Exception(decodedResponse["message"] ??
          strings.SOMETHING_WENT_WRONG_WITH_EXCLAMATION);
    }
  }

  increaseQuantity(Product product) async {
    var queryParams = await getQueryParams() ?? "";

    log("SKU: ${product.sku}");
    Item _product =
        currentOrder.items.singleWhere((item) => item.sku == product.sku);
    var url = LAMBDA_ORDER_URL + "/v2/update/edit" + queryParams;

    var headers = {
      "Content-Type": "application/json",
      "access-token": getLambdaToken() ?? ""
    };

    var payload = {
      "sales_incremental_id": currentOrder.increment_id,
      "sales_order_id": currentOrder.entityId,
      "item_id": _product.itemId,
      "item_sku": _product.sku,
      "item_qty": double.parse(_product.qtyOrdered).toInt() + 1,
      "store_id": _product.storeId,
    };

    log("URL: $url", name: "increase_quantity");
    log("PAYLOAD: $payload", name: "increase_quantity");

    var response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: convert.jsonEncode(payload),
    );
    var decodedResponse = convert.jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200) {
      // await getOrderDetails();
      var orderDetails =
          OrderDetails.removeToOrderDetails(decodedResponse["data"]);

      print("========================>");
      print("orderDetails: $orderDetails");
      print("<========================");

      currentOrder = orderDetails;
    } else {
      throw Exception(decodedResponse["message"] ??
          strings.SOMETHING_WENT_WRONG_WITH_EXCLAMATION);
    }
  }

  decreaseQuantity(Product product) async {
    var queryParams = await getQueryParams() ?? "";

    log("SKU: ${product.sku}", name: "decrease_quantity_provider");
    Item _product =
        currentOrder.items.singleWhere((item) => item.sku == product.sku);

    var qty = double.parse(_product.qtyOrdered).toInt();
    bool isRemoveItem = qty == 1 ? true : false;

    var url = LAMBDA_ORDER_URL +
        "/v2/update/" +
        (isRemoveItem ? "remove" : "edit") +
        queryParams;

    var headers = {
      "Content-Type": "application/json",
      "access-token": getLambdaToken() ?? ""
    };

    var payload = {
      "sales_incremental_id": currentOrder.increment_id,
      "sales_order_id": currentOrder.entityId,
      "item_id": _product.itemId,
      "item_sku": _product.sku,
      "item_qty":
          isRemoveItem ? 0 : double.parse(_product.qtyOrdered).toInt() - 1,
      "store_id": _product.storeId,
    };

    log("URL: $url", name: "decrease_quantity");
    log("PAYLOAD: $payload", name: "decrease_quantity");

    var response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: convert.jsonEncode(payload),
    );
    var decodedResponse = convert.jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200) {
      // await getOrderDetails();
      var orderDetails =
          OrderDetails.removeToOrderDetails(decodedResponse["data"]);

      print("========================>");
      print("orderDetails: $orderDetails");
      print("<========================");

      currentOrder = orderDetails;
    } else {
      throw Exception(decodedResponse["message"] ??
          strings.SOMETHING_WENT_WRONG_WITH_EXCLAMATION);
    }
  }
}
