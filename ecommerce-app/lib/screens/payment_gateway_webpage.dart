import 'dart:async';
import 'dart:io';

import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/screens/checkout_screen.dart';
import 'package:Nesto/screens/payment_success_page.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/services/notification_service.dart';
import 'package:Nesto/utils/util.dart';
import 'package:Nesto/widgets/connectivity_widget.dart';
import 'package:Nesto/widgets/headerButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:Nesto/strings.dart' as strings;
import 'package:webview_flutter/webview_flutter.dart';

class PaymentGatewayWebpage extends StatefulWidget {
  static String routeName = "/payment_gateway_webpage";

  @override
  _PaymentGatewayWebpageState createState() => _PaymentGatewayWebpageState();
}

class _PaymentGatewayWebpageState extends State<PaymentGatewayWebpage> {
  bool isLoading = true;
  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "Payment Gateway Screen");
    super.initState();
    Future.delayed(Duration.zero, () {
      EasyLoading.dismiss();
    });
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    var storeProvider = Provider.of<StoreProvider>(context);

    void backHandler() async {
      firebaseAnalytics.logBackPressPaymentScreen();
      notificationServices.showCustomDialog(
          title: strings.DO_YOU_WANT_TOLEAVE_THIS_PAGE,
          description: strings.YOUR_TRANSACTION_WILL_GET_CANCELLED,
          negativeText: strings.NO,
          positiveText: strings.YES,
          action: () {
            storeProvider.cancelOrder();
            storeProvider.resetCart(false);
            Navigator.of(context)
                .pushReplacementNamed(CheckoutScreen.routeName);
            firebaseAnalytics.logCancelAlert();
          });
    }

    Future<bool> _willPopCallback() async {
      backHandler();
      return false; // return true if the route to be popped
    }

    return ConnectivityWidget(
      child: WillPopScope(
        onWillPop: _willPopCallback,
        child: SafeArea(
          child: Stack(
            children: [
              WebView(
                onPageStarted: (url) {
                  logNesto("PAYMENT GATEWAY URL:" + url);
                  if (url.contains("go.nesto.shop")) {
                    Future.delayed(Duration.zero, () {
                      Navigator.of(context).pushReplacementNamed(
                          PaymentSuccessfullScreen.routeName);
                    });
                  }
                },
                onPageFinished: (url) {
                  setState(() {
                    isLoading = false;
                  });
                },
                javascriptMode: JavascriptMode.unrestricted,
                initialUrl: storeProvider.paymentGatewayUrl,
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: ScreenUtil().setWidth(20.0),
                  top: ScreenUtil().setHeight(32.0),
                ),
                child: headerButton(
                    icon: Icons.chevron_left,
                    iconSize: 27.0,
                    bgColor: Colors.white,
                    borderColor: Color(0XFFBBBDC1),
                    onPress: backHandler),
              ),
              isLoading
                  ? Center(
                      child: Padding(
                      padding: EdgeInsets.only(
                        bottom: ScreenUtil().setHeight(70.0),
                      ),
                      child: Text(strings.PLEASE_WAIT,
                          style: TextStyle(
                              color: Colors.black45,
                              fontSize: 17,
                              fontWeight: FontWeight.bold)),
                    ))
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
