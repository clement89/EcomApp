import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:Nesto/extensions/number_extension.dart';
import 'package:Nesto/models/order_details.dart' as OD;
import 'package:Nesto/providers/orders_provider.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/services/notification_service.dart';
import 'package:Nesto/strings.dart' as strings;
import 'package:Nesto/utils/util.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/widgets/coupon_applied_banner_widget.dart';
import 'package:Nesto/widgets/dynamic_homepage_widgets/edit_loader_widget.dart';
import 'package:Nesto/widgets/edge_cases/connection_lost.dart';
import 'package:Nesto/widgets/edit_screen_widgets/bottom_container_edit.dart';
import 'package:Nesto/widgets/edit_screen_widgets/edit_product.dart';
import 'package:Nesto/widgets/edit_screen_widgets/total_container_edit.dart';
import 'package:Nesto/widgets/headers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class EditOrder extends StatefulWidget {
  static String routeName = "edit_order_screen";

  const EditOrder({Key key}) : super(key: key);

  @override
  _EditOrder createState() => _EditOrder();
}

class _EditOrder extends State<EditOrder> {
  Future _future;
  bool _editSyncLoader = false;

  startEditSync() => setState(() => _editSyncLoader = true);

  stopEditSync() => setState(() => _editSyncLoader = false);

  callEstimation() async {
    var provider = Provider.of<OrderProvider>(context, listen: false);
    try {
      await provider.shippingEstimation(provider.currentOrder.entityId);
    } catch (e) {
      log(e.toString());
    }
  }

  // bool showCouponRemovedAlert(OD.Item product) {
  //   var provider = Provider.of<OrderProvider>(context, listen: false);
  //   double subTotal = double.parse(provider.currentOrder.baseSubtotal);

  //   double taxExcludedPrice = double.parse(product?.basePrice ?? '0') *
  //       double.parse(product?.qtyOrdered ?? '0');
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

  showAlertDialog(OD.Item product) {
    var provider = Provider.of<OrderProvider>(context, listen: false);

    bool showMinAlert = (double.parse(provider.currentOrder.baseSubtotal) -
                (double.parse(product.basePrice) *
                    double.parse(product.qtyOrdered))) <
            double.parse(provider.editOrderMinSubTotal ?? '0')
        ? true
        : false;

    print("======================>");
    print(
        "showMinAlert: ${(double.parse(product.basePrice) * double.parse(product.qtyOrdered))}");
    print("<=======================");

    if (showMinAlert) {
      showError(
          context,
          strings.MINIMUM_SUBTOTAL_OF_AED +
              double.parse(provider.editOrderMinSubTotal).twoDecimal() +
              strings.IS_REQUIRED_IN_ORDER);
      return;
    } else
      notificationServices.showCustomDialog(
          title: strings.DELETE_PRODUCT,
          description: strings.PRODUCT_DELETE_DESCRIPTION,
          negativeText: strings.NO,
          positiveText: strings.REMOVE,
          action: () {
            removeItem(product);
            return Future.value(true);
          });
  }

  removeItem(OD.Item product) async {
    var provider = Provider.of<OrderProvider>(context, listen: false);
    String queryParams = await getQueryParams() ?? "";

    var qty = double.parse(product.qtyOrdered).toInt();
    if (qty < 1) {
      //dont delete
      return;
    }
    startEditSync();
    try {
      var LAMBDA_ORDER_URL =
          FlavorConfig.instance.variables["LAMBDA_ORDER_URL"];
      var url = LAMBDA_ORDER_URL + "/v2/update/remove" + queryParams;
      // print("URL: $url");
      var payload = {
        "sales_incremental_id": provider.currentOrder.increment_id,
        "sales_order_id": provider.currentOrder.entityId,
        "item_id": product.itemId,
        "item_sku": product.sku,
        // "item_qty": 0,
        "store_id": product.storeId,
      };

      var headers = {
        "Content-Type": "application/json",
        "access-token": getLambdaToken() ?? ""
      };

      // print("headers: $headers");

      print("========================>");
      print("orderDetails: $payload");
      print("<========================");

      var encodedJson = jsonEncode(payload);
      var response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: encodedJson,
      );

      var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
      print("========================>");
      print("RESPONSE: $decodedResponse");
      print("<========================");

      if (response.statusCode == 200) {
        logNestoCustom(
            message: decodedResponse.toString(), logType: LogType.warning);
        var orderDetails =
            OD.OrderDetails.removeToOrderDetails(decodedResponse["data"]);

        print("========================>");
        print("orderDetails: $orderDetails");
        print("<========================");

        provider.currentOrder = orderDetails;
        stopEditSync();
        firebaseAnalytics.editOrderDecrease(
          quantity: 0,
          sku: product.sku,
          price: double.tryParse(product.basePriceInclTax),
          currency: "AED",
          orderID: provider?.detailstest?.orderid,
          incrementalID: provider?.detailstest?.increment_id,
        );
        showSuccess(context, strings.ORDER_UPDATED);
      } else {
        stopEditSync();

        print("========================>");
        print("REPONSE WAS NOT 200");
        print("<========================");

        if (response.statusCode.isServerErr() ?? false) {
          throw Exception(strings.SOMETHING_WENT_WRONG);
        } else {
          var message =
              decodedResponse["message"] ?? strings.SOMETHING_WENT_WRONG;
          throw Exception("$message");
        }
      }
    } on SocketException catch (_) {
      stopEditSync();
      showError(context, strings.PLEASE_CHECK_YOUR_NETWORK_CONNECTION);
    } catch (e) {
      print("ERROR: $e");
      stopEditSync();
      if (e?.message != null) {
        showError(context, e?.message);
      } else {
        showError(context, strings.SOMETHING_WENT_WRONG);
      }

      log(e.toString());
    }
  }

  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "Edit Order Screen");
    super.initState();
    _future = callEstimation();
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<OrderProvider>(context);

    return SafeArea(
        child: Stack(
      alignment: Alignment.center,
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: headerBar(title: strings.EDIT_ORDER, context: context),
          body: FutureBuilder(
              future: _future,
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Container(
                    height: double.infinity,
                    width: double.infinity,
                    padding: EdgeInsets.only(
                      top: ScreenUtil().setWidth(18),
                    ),
                    child: Column(
                      children: [
                        Visibility(
                            visible: (double.parse(provider
                                                .currentOrder.discount_amount ??
                                            '0')
                                        .abs() >
                                    0) ??
                                false,
                            child: Padding(
                              padding: EdgeInsets.only(
                                  bottom: ScreenUtil().setWidth(18)),
                              child: CouponAppliedBanner(),
                            )),
                        Flexible(
                          flex: 1,
                          child: ListView(
                            children: [
                              ListView.separated(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.symmetric(
                                    horizontal: ScreenUtil().setWidth(20)),
                                itemCount: provider.editItems.length,
                                itemBuilder: (_, index) {
                                  OD.Item product =
                                      provider.currentOrder.items[index];
                                  return Dismissible(
                                    key: ValueKey<int>(index),
                                    direction: DismissDirection.endToStart,
                                    confirmDismiss: (dismissDirection) async {
                                      var provider = Provider.of<OrderProvider>(
                                          context,
                                          listen: false);

                                      bool showMinAlert = (double.parse(provider
                                                      .currentOrder
                                                      .baseSubtotal) -
                                                  (double.parse(
                                                          product.basePrice) *
                                                      double.parse(product
                                                          .qtyOrdered))) <
                                              double.parse(provider
                                                      .editOrderMinSubTotal ??
                                                  '0')
                                          ? true
                                          : false;
                                      if (showMinAlert) {
                                        showError(
                                            context,
                                            strings.MINIMUM_SUBTOTAL_OF_AED +
                                                double.parse(provider
                                                        .editOrderMinSubTotal)
                                                    .twoDecimal() +
                                                strings.IS_REQUIRED_IN_ORDER);
                                        return Future.value(false);
                                      }
                                      Future<bool> futureBool =
                                          await showAlertDialog(product) ??
                                              Future.value(false);
                                      print("FUTURE BOOL: $futureBool");
                                      return futureBool;
                                    },
                                    background: Container(
                                      padding: EdgeInsets.only(right: 15),
                                      alignment: Alignment.centerRight,
                                      decoration: BoxDecoration(
                                          color: Colors.red.shade600,
                                          borderRadius:
                                              BorderRadius.circular(8.84)),
                                      child: Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                    ),
                                    onDismissed: (dismissDirection) {
                                      // removeItem(product);
                                    },
                                    child: EditProduct(
                                      product: product,
                                      startSync: startEditSync,
                                      stopSync: stopEditSync,
                                    ),
                                  );
                                },
                                separatorBuilder: (_, index) => SizedBox(
                                  height: 20,
                                ),
                              ),
                              SizedBox(
                                height: ScreenUtil().setWidth(25),
                              ),
                              Divider(),
                              SizedBox(
                                height: ScreenUtil().setWidth(25),
                              ),
                              TotalContainer(provider: provider),
                              Divider(),
                              Visibility(
                                visible: double.parse(provider?.currentOrder
                                                ?.shippingAmount ??
                                            '0')
                                        .abs() >
                                    0,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: ScreenUtil().setWidth(20)),
                                  child: Text(
                                    strings.SHIPPINGFEE_ADDED_ALERT_TEXT +
                                        "${(provider?.shippingChargeLimit ?? '0').split(".")[0]}" +
                                        strings.AED_LIMIT,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: provider.currentOrder.payment.method !=
                                    'cashondelivery',
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: ScreenUtil().setWidth(20),
                                      vertical: ScreenUtil().setHeight(20)),
                                  child: Text(
                                    strings.EDIT_ALERT_FOR_CASHONDELIVERY,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: ScreenUtil().setWidth(25),
                              ),
                            ],
                          ),
                        ),
                        BottomContainer(),
                      ],
                    ),
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Container(
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation<Color>(
                            values.NESTO_GREEN),
                        strokeWidth: ScreenUtil().setWidth(3),
                      ),
                    ),
                  );
                } else {
                  return Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: Center(
                      child: ConnectionLostWidget(),
                    ),
                  );
                }
              }),
        ),
        Visibility(
          visible: _editSyncLoader,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black12,
            child: Center(
              child: EditLoader(),
            ),
          ),
        )
      ],
    ));
  }
}

//styles

var edgeInsets = EdgeInsets.only(
  top: ScreenUtil().setWidth(20),
  right: ScreenUtil().setWidth(20),
  left: ScreenUtil().setWidth(20),
  bottom: ScreenUtil().setWidth(5),
);
