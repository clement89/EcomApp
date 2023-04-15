import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:Nesto/extensions/number_extension.dart';
import 'package:Nesto/models/order_details.dart' as OD;
import 'package:Nesto/providers/orders_provider.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/services/navigation_service.dart';
import 'package:Nesto/services/notification_service.dart';
import 'package:Nesto/strings.dart' as strings;
import 'package:Nesto/utils/util.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/widgets/optimized_cache_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../service_locator.dart';

final NavigationService _navigation = locator.get<NavigationService>();

class EditProduct extends StatefulWidget {
  const EditProduct({
    Key key,
    @required this.product,
    @required this.startSync,
    @required this.stopSync,
  }) : super(key: key);

  final OD.Item product;
  final Function startSync;
  final Function stopSync;

  @override
  _EditProductState createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(15)),
      height: ScreenUtil().setWidth(100),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.84),
        color: Color(0XFFF5F5F8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ProductImage(
            imageURL: widget.product.itemImage,
          ),
          SizedBox(
            width: ScreenUtil().setWidth(15.0),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: ScreenUtil().setWidth(130),
                child: Text(
                  widget.product?.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 15.47, height: 1.19, color: Color(0XFF111A2C)),
                ),
              ),
              SizedBox(
                height: ScreenUtil().setWidth(5),
              ),
              Text(
                strings.AED +
                    ' ' +
                    double.parse(widget.product?.rowTotalInclTax).twoDecimal(),
                style: TextStyle(
                    color: Color(0XFF00983D),
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(
            width: ScreenUtil().setWidth(15),
          ),
          ProductStepper(
              product: widget.product,
              startSync: widget.startSync,
              stopSync: widget.stopSync),
        ],
      ),
    );
  }
}

class ProductStepper extends StatefulWidget {
  const ProductStepper({
    Key key,
    @required this.product,
    @required this.startSync,
    @required this.stopSync,
  }) : super(key: key);

  final OD.Item product;
  final Function startSync;
  final Function stopSync;

  @override
  _ProductStepperState createState() => _ProductStepperState();
}

class _ProductStepperState extends State<ProductStepper> {
  bool showLoader = false;
  var LAMBDA_ORDER_URL = FlavorConfig.instance.variables["LAMBDA_ORDER_URL"];

  startLoading() => setState(() => showLoader = true);

  stopLoading() => setState(() => showLoader = false);

  // bool get showCouponRemovedAlert {
  //   var provider = Provider.of<OrderProvider>(context, listen: false);
  //   double subTotal = double.parse(provider.currentOrder.baseSubtotal);

  //   double taxExcludedPrice = double.parse(widget.product.basePrice);
  //   double couponMinAmount =
  //       double.parse(((provider.couponMinAmount).toString() ?? "0.00"));
  //   bool isCouponApplied = provider.couponApplied;

  //   log("couponMinAMount: $couponMinAmount");
  //   log("couponApplied: $isCouponApplied");

  //   if (provider.currentOrder.appliedCoupon.isEmpty) {
  //     //since is coupon is already removed from order.
  //     return false;
  //   }

  //   if (double.parse(provider.currentOrder.discount_amount).abs() <= 0) {
  //     //since coupon is already removed from order.
  //     return false;
  //   }

  //   if (subTotal < couponMinAmount) {
  //     // no need to show since coupon is already removed.
  //     return false;
  //   }

  //   if (isCouponApplied) {
  //     if ((subTotal - provider.taxDifference) - taxExcludedPrice <
  //         couponMinAmount) {
  //       //on removing this the coupon will be removed
  //       return true;
  //     } else {
  //       return false;
  //     }
  //   } else {
  //     return false;
  //   }
  // }

  // bool get showCouponRemoveAlertMinMax {
  //   var provider = Provider.of<OrderProvider>(context, listen: false);
  //   double subTotal = double.parse(provider.currentOrder.baseSubtotal);

  //   double taxExcludedPrice = double.parse(widget.product.basePrice);
  //   double couponMinAmount =
  //       double.parse(((provider.couponMinAmount).toString() ?? "0.00"));
  //   bool isCouponApplied = provider.couponApplied;

  //   if (provider.currentOrder.appliedCoupon.isEmpty) {
  //     //since is coupon is already removed from order.
  //     return false;
  //   }

  //   if (double.parse(provider.currentOrder.discount_amount).abs() <= 0) {
  //     //since coupon is already removed from order.
  //     return false;
  //   }

  //   if (subTotal < couponMinAmount) {
  //     // no need to show since coupon is already removed.
  //     return false;
  //   }

  //   if (isCouponApplied) {
  //     int maxQty = widget.product.maxQty;

  //     if ((subTotal - (taxExcludedPrice * maxQty)) < couponMinAmount) {
  //       //on removing this the coupon will be removed
  //       return true;
  //     } else {
  //       return false;
  //     }
  //   } else {
  //     return false;
  //   }
  // }

  increaseQuantity({OD.Item product, int updateQty}) async {
    var provider = Provider.of<OrderProvider>(context, listen: false);
    String queryParams = await getQueryParams() ?? "";

    if (showLoader) {
      return;
    }
    startLoading();
    widget.startSync();
    try {
      var url = LAMBDA_ORDER_URL + "/v2/update/edit" + queryParams;
      print("URL: $url");

      var payload = {
        "sales_incremental_id": provider.currentOrder.increment_id,
        "sales_order_id": provider.currentOrder.entityId,
        "item_id": product.itemId,
        "item_sku": product.sku,
        "item_qty":
            updateQty ?? double.parse(widget.product.qtyOrdered).toInt() + 1,
        "store_id": product.storeId,
      };

      print("PAYLOAD: $payload");

      var headers = {
        "Content-Type": "application/json",
        "access-token": getLambdaToken() ?? ""
      };

      print("headers: $headers");

      log("PAYLOAD: $payload", name: "edit_increase");
      var encodedJson = jsonEncode(payload);

      var response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: encodedJson,
      );
      var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
      print("RESPONSE: $decodedResponse");

      if (response.statusCode == 200) {
        // await provider.myorderdetails(provider.currentOrder.entityId);
        var orderDetails =
            OD.OrderDetails.removeToOrderDetails(decodedResponse["data"]);

        print("========================>");
        print("orderDetails: $orderDetails");
        print("<========================");

        provider.currentOrder = orderDetails;
        stopLoading();
        widget.stopSync();
        //firebase analytics logging
        firebaseAnalytics.editOrderIncrease(
          itemId: product.itemId,
          sku: product.sku,
          price: double.tryParse(product.basePriceInclTax),
          currency: "AED",
          orderID: provider.currentOrder.entityId,
          incrementalID: provider.currentOrder.increment_id,
        );
        showSuccess(
            _navigation.navigatorKey.currentContext, strings.ORDER_UPDATED);
      } else {
        var message = decodedResponse["message"] ??
            strings.SOMETHING_WENT_WRONG_WITH_EXCLAMATION;
        stopLoading();
        widget.stopSync();
        if (response.statusCode.isServerErr() ?? false) {
          throw Exception(strings.SOMETHING_WENT_WRONG);
        } else
          throw Exception("$message");
      }
    } on SocketException catch (_) {
      stopLoading();
      widget.stopSync();
      showError(_navigation.navigatorKey.currentContext,
          strings.PLEASE_CHECK_YOUR_NETWORK_CONNECTION);
    } catch (e) {
      log(e.toString());
      stopLoading();
      widget.stopSync();
      showError(
          _navigation.navigatorKey.currentContext,
          e?.message != null
              ? e?.message
              : strings.SOMETHING_WENT_WRONG_WITH_EXCLAMATION);
    }
  }

  decreaseQuantity({OD.Item product, int updateQty}) async {
    var provider = Provider.of<OrderProvider>(context, listen: false);
    String queryParams = await getQueryParams() ?? "";

    if (showLoader) {
      return;
    }
    var qty = double.parse(widget.product.qtyOrdered).toInt();
    bool isRemoveItem = qty == 1 ? true : false;

    if (qty < 1) {
      //dont delete
      log("cannot delete since quantity is 0");
      return;
    }
    startLoading();
    widget.startSync();
    try {
      var url = LAMBDA_ORDER_URL +
          "/v2/update/" +
          (isRemoveItem ? "remove" : "edit") +
          queryParams;
      print("URL: $url");
      var payload = {
        "sales_incremental_id": provider.currentOrder.increment_id,
        "sales_order_id": provider.currentOrder.entityId,
        "item_id": product.itemId,
        "item_sku": product.sku,
        "item_qty": isRemoveItem
            ? 0
            : updateQty ?? double.parse(widget.product.qtyOrdered).toInt() - 1,
        "store_id": product.storeId,
      };

      var headers = {
        "Content-Type": "application/json",
        "access-token": getLambdaToken() ?? ""
      };

      // print("headers: $headers");

      print("PAYLOAD: $payload");
      var encodedJson = jsonEncode(payload);
      var response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: encodedJson,
      );

      var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
      log("RESPONSE: $decodedResponse", name: "decrease_quantity");

      if (response.statusCode == 200) {
        // await provider.myorderdetails(provider.currentOrder.entityId);
        var orderDetails =
            OD.OrderDetails.removeToOrderDetails(decodedResponse["data"]);

        print("========================>");
        print("orderDetails: $orderDetails");
        print("<========================");

        provider.currentOrder = orderDetails;
        stopLoading();
        widget.stopSync();
        firebaseAnalytics.editOrderDecrease(
          quantity: 1,
          sku: product.sku,
          price: double.tryParse(product.basePriceInclTax),
          currency: "AED",
          orderID: provider?.detailstest?.orderid,
          incrementalID: provider?.detailstest?.increment_id,
        );
        showSuccess(
            _navigation.navigatorKey.currentContext, strings.ORDER_UPDATED);
      } else {
        var message = decodedResponse["message"] ??
            strings.SOMETHING_WENT_WRONG_WITH_EXCLAMATION;
        stopLoading();
        widget.stopSync();
        if (response.statusCode.isServerErr() ?? false) {
          throw Exception(strings.SOMETHING_WENT_WRONG);
        } else
          throw Exception("$message");
      }
    } on SocketException catch (_) {
      stopLoading();
      widget.stopSync();
      showError(_navigation.navigatorKey.currentContext,
          strings.PLEASE_CHECK_YOUR_NETWORK_CONNECTION);
    } catch (e) {
      log(e.toString());
      stopLoading();
      widget.stopSync();
      showError(
          _navigation.navigatorKey.currentContext,
          e?.message != null
              ? e?.message
              : strings.SOMETHING_WENT_WRONG_WITH_EXCLAMATION);
    }
  }

  showRemoveAlertDialog() {
    notificationServices.showCustomDialog(
        title: strings.DELETE_PRODUCT,
        description: strings.PRODUCT_DELETE_DESCRIPTION,
        negativeText: strings.NO,
        positiveText: strings.REMOVE,
        action: () => decreaseQuantity(product: widget.product));
  }

  showDecrementQtyAlert() {
    notificationServices.showCustomDialog(
        title: strings.CHANGE_QUANTITY,
        description:
            "Maximum quantity allowed for this item is ${widget?.product?.maxQty ?? 0}" +
                '. Do you want to update quantity from ${double.parse(widget?.product?.qtyOrdered).toInt()} to ${widget.product.maxQty} ? ',
        negativeText: strings.NO,
        positiveText: strings.YES,
        action: () => decreaseQuantity(
            product: widget.product, updateQty: widget.product.maxQty));
  }

  showIncrementQtyAlert() {
    notificationServices.showCustomDialog(
        title: strings.CHANGE_QUANTITY,
        description:
            "Minimum quantity required for this item is ${widget?.product?.minQty ?? 0}. " +
                "Do you want to update quantity from ${double.parse(widget?.product?.qtyOrdered).toInt()} to ${widget.product.minQty} ?",
        negativeText: strings.NO,
        positiveText: strings.YES,
        action: () => increaseQuantity(
            product: widget.product, updateQty: widget.product.minQty));
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      child: SizedBox(
        height: ScreenUtil().setWidth(50),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            color: Colors.white,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () {
                      var provider =
                          Provider.of<OrderProvider>(context, listen: false);

                      int qty = double.parse(widget.product.qtyOrdered).toInt();
                      bool showMinAlert = (double.parse(
                                      provider.currentOrder.baseSubtotal) -
                                  double.parse(widget.product.basePrice)) <
                              double.parse(provider.editOrderMinSubTotal ?? '0')
                          ? true
                          : false;
                      if (showMinAlert) {
                        showError(
                            _navigation.navigatorKey.currentContext,
                            strings.MINIMUM_SUBTOTAL_OF_AED +
                                double.parse(provider.editOrderMinSubTotal)
                                    .twoDecimal() +
                                strings.IS_REQUIRED_IN_ORDER);
                        return;
                      }
                      if (qty <= 1) {
                        showRemoveAlertDialog();
                        return;
                      }

                      if (qty - 1 <= widget.product.maxQty) {
                        if (qty - 1 >= widget.product.minQty) {
                          //proceed with order update and decrement
                          //order/update with existing_qty - 1
                          decreaseQuantity(product: widget.product);
                        } else {
                          if (qty - 1 == 0) {
                            //remove the item
                            showRemoveAlertDialog();
                          } else
                            showError(_navigation.navigatorKey.currentContext,
                                "Minimum quantity for this item is ${widget.product.minQty}");
                        }
                      } else {
                        showDecrementQtyAlert();
                      }
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Center(
                          child: Icon(
                        Icons.remove,
                        color: values.NESTO_GREEN,
                      )),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    color: Colors.transparent,
                    child: Center(
                        child: !showLoader
                            ? FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  double.parse(widget.product.qtyOrdered)
                                      .toInt()
                                      .toString(),
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black),
                                ),
                              )
                            : SizedBox(
                                height: ScreenUtil().setWidth(17),
                                width: ScreenUtil().setWidth(17),
                                child: CircularProgressIndicator(
                                  valueColor: new AlwaysStoppedAnimation<Color>(
                                      values.NESTO_GREEN),
                                  strokeWidth: ScreenUtil().setWidth(3),
                                ),
                              )),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () {
                      int qty = double.parse(widget.product.qtyOrdered).toInt();

                      if (qty + 1 > widget.product.maxQty) {
                        //show alert Maximum quantity allowed is max_qty
                        showError(_navigation.navigatorKey.currentContext,
                            "Maximum quantity allowed for this order is ${widget.product.maxQty}");
                      } else {
                        //order update
                        if (qty + 1 < widget.product.minQty) {
                          //show alert dialog minimum quantity required is min_qty.
                          //Do yo want to update the qty to min_qty
                          //order/update with min_qty
                          showIncrementQtyAlert();
                        } else {
                          //order_update existing_qty + 1
                          increaseQuantity(
                            product: widget.product,
                          );
                        }
                      }
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Center(
                          child: Icon(
                        Icons.add,
                        color: values.NESTO_GREEN,
                      )),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProductImage extends StatelessWidget {
  const ProductImage({
    Key key,
    @required this.imageURL,
  }) : super(key: key);

  final String imageURL;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ScreenUtil().setWidth(70),
      width: ScreenUtil().setWidth(70),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.0),
        child: FittedBox(
          fit: BoxFit.fitWidth,
          child: ImageWidget(
              fadeInDuration: Duration(milliseconds: 1),
              maxWidthDiskCache: 900,
              maxHeightDiskCache: 900,
              imageUrl: imageURL),
        ),
      ),
    );
  }
}

extension serverErr on int {
  bool isServerErr() => (this ~/ 100) == 5;
}
