import 'dart:core';

import 'package:Nesto/extensions/number_extension.dart';
import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/screens/base_screen.dart';
import 'package:Nesto/screens/payment_failure_screen.dart';
import 'package:Nesto/screens/payment_gateway_webpage.dart';
import 'package:Nesto/screens/rate_experience.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:Nesto/strings.dart' as strings;
import '../values.dart' as values;

class PaymentSuccessfullScreen extends StatefulWidget {
  static String routeName = "/payment_successfull_screen";

  @override
  _PaymentSuccessfullScreenState createState() =>
      _PaymentSuccessfullScreenState();
}

class _PaymentSuccessfullScreenState extends State<PaymentSuccessfullScreen>
    with TickerProviderStateMixin {
  //AnimationController _controller;
  bool isLoading = true;
  String timeSlotForDelivery = "";
  double inaamPoints = 0;

  String getDateText(DateTime date) {
    return DateFormat("MMMM d").format(date);
  }

  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "Payment Success Page");
    super.initState();
    Provider.of<StoreProvider>(context, listen: false).resetCart(false);
    placeOrder();
  }

  Future placeOrder() async {
    var provider = Provider.of<StoreProvider>(context, listen: false);
    provider.orderError = false;
    provider.orderSuccess = false;
    setState(() {
      isLoading = true;
    });
    await provider.placeOrder(
        "ngeniusonline",
        provider.shippingAddress.latitude.toString(),
        provider.shippingAddress.longitude.toString(),
        provider.enableSubstitution,
        provider.deliveryNote);
    if (!provider.orderError) {
      setState(() {
        inaamPoints = getInaamPoints(provider.subTotal);
        timeSlotForDelivery = getDateText(provider.selectedDateForDelivery) +
            " " +
            provider.selectedFromTimeForDelivery +
            "-" +
            provider.selectedToTimeForDelivery;
        provider.resetCart(true);
        isLoading = false;
      });
      //firebase analytics logging.
      firebaseAnalytics.logPaymentSuccess();
    } else {
      if (provider.errorMessage.contains('Payment Error')) {
        Future.delayed(Duration.zero, () {
          Navigator.of(context)
              .pushReplacementNamed(PaymentFailureScreen.routeName);
        });
        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        showError(context, provider.errorMessage);
      }
      //firebase analytics logging.
      firebaseAnalytics.logPaymentFailure();
    }
  }

  Future<bool> _willPopCallback() async {
    if (!isLoading) {
      Provider.of<StoreProvider>(context, listen: false).resetCart(false);
      Provider.of<StoreProvider>(context, listen: false).shippingAddress = null;
      Navigator.of(context)
          .pushReplacementNamed(BaseScreen.routeName, arguments: {"index": 0});
    }
    return false; // return true if the route to be popped
  }

  @override
  Widget build(BuildContext context) {
    var storeProvider = Provider.of<StoreProvider>(context, listen: false);
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);
    return WillPopScope(
      onWillPop: _willPopCallback,
      child: SafeArea(
        child: Scaffold(
          body: Container(
            padding: EdgeInsets.fromLTRB(0.0, ScreenUtil().setHeight(33.15),
                0.0, ScreenUtil().setHeight(32.0)),
            height: double.infinity,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // titleText(),
                SizedBox(height: ScreenUtil().setHeight(28.85)),
                Container(
                  child: SizedBox(
                    height: ScreenUtil().setWidth(284),
                    width: ScreenUtil().setWidth(284),
                    child: storeProvider.orderError
                        ? Lottie.asset(
                            'assets/animations/order_cancelled.json',
                          )
                        : isLoading
                            ? Lottie.asset(
                                'assets/animations/fetching.json',
                              )
                            : Lottie.asset(
                                'assets/animations/order_payment_confirm.json',
                                repeat: false,
                              ),
                  ),
                ),
                Text(
                  storeProvider.orderError
                      ? strings.ORDER_FAILED
                      : isLoading
                          ? strings.ORDER_PROCESSING
                          : strings.ORDER_SUCCESFULLY_PLACED,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                ),
                Container(
                  margin: EdgeInsets.only(top: ScreenUtil().setHeight(26.0)),
                  padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(45.0)),
                  child: Text(
                    storeProvider.orderError
                        ? strings.SORRY_WE_COULD_NOT_COMPLETE_ORDER
                        : isLoading
                            ? strings.PLEASE_WAIT_WHILE_WE_PROCESS_THE_ORDER
                            : strings.ORDER_SUCCESSFUL_DESCRIPTION +
                                Provider.of<StoreProvider>(context,
                                        listen: false)
                                    .incrementId,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, fontSize: 17),
                  ),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(40.0),
                ),
                Visibility(
                    visible: !isLoading && !storeProvider.orderError,
                    child: Column(
                      children: [
                        ChipTile(
                          icon: Icons.verified,
                          subText: strings.WILL_BE_DELIVERED_ON,
                          mainText: timeSlotForDelivery,
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(12.0),
                        ),
                        ChipTile(
                          icon: Icons.verified,
                          subText: strings.INAAM_POINTS_EARNED,
                          mainText: inaamPoints.twoDecimal() + strings.POINTS,
                        ),
                      ],
                    )),
                Visibility(
                  visible: !isLoading,
                  child: Expanded(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          storeProvider.orderError && !storeProvider.flushCart
                              ? GreenButton(
                                  buttonTitle: strings.RETRY,
                                  onPress: () async {
                                    EasyLoading.show(
                                      //status: 'Processing...',
                                      maskType: EasyLoadingMaskType.black,
                                    );
                                    storeProvider.resetCart(false);
                                    await storeProvider.paymentGateway(
                                        storeProvider.enableSubstitution,
                                        storeProvider.deliveryNote);
                                    if (storeProvider.launchNGenius) {
                                      logNesto("LAUNCH NGENIUS");
                                      Future.delayed(Duration.zero, () {
                                        Navigator.of(context)
                                            .pushNamedAndRemoveUntil(
                                                PaymentGatewayWebpage.routeName,
                                                (Route<dynamic> route) =>
                                                    false);
                                      });
                                    } else if (storeProvider.orderError &&
                                        storeProvider.flushCart) {
                                      storeProvider.flushCart = false;
                                      storeProvider.orderError = false;
                                      showError(
                                          context, storeProvider.errorMessage);
                                      await storeProvider.resetCart(true);
                                      EasyLoading.dismiss();
                                      Navigator.of(context)
                                          .pushReplacementNamed(
                                              BaseScreen.routeName,
                                              arguments: {"index": 0});
                                    }
                                    EasyLoading.dismiss();
                                  },
                                )
                              : SizedBox(),
                          SizedBox(
                            height: ScreenUtil()
                                .setWidth(values.SPACING_MARGIN_STANDARD),
                          ),
                          GreenButton(
                            buttonTitle: strings.Shop_More,
                            onPress: () async {
                              if (storeProvider.orderError) {
                                {
                                  storeProvider.cancelOrder();
                                  storeProvider.resetCart(false);
                                  storeProvider.shippingAddress = null;
                                  //firebase analytics logging.
                                  firebaseAnalytics.logShopMore();
                                  Navigator.of(context).pushReplacementNamed(
                                      BaseScreen.routeName,
                                      arguments: {"index": 0});
                                }
                              } else {
                                Navigator.of(context)
                                    .pushNamed(RateExperience.routeName);
                              }
                            },
                          ),
                        ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Text titleText() {
    return Text(
      strings.PAYMENT_SUCCESSFUL.toUpperCase(),
      style: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
        color: Color(0XFF111A2C),
      ),
    );
  }
}
