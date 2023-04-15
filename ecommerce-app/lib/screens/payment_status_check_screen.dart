import 'dart:async';

import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/screens/payment_failure_screen.dart';
import 'package:Nesto/screens/payment_success_page.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/widgets/connectivity_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PaymentStatusCheckScreen extends StatefulWidget {
  static const routeName = "/payment_status_screen";

  @override
  _PaymentStatusCheckScreenState createState() =>
      _PaymentStatusCheckScreenState();
}

class _PaymentStatusCheckScreenState extends State<PaymentStatusCheckScreen> {
  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "Payment Status Check Screen");
    Future.delayed(Duration.zero, () async {
      var storeProvider = Provider.of<StoreProvider>(context, listen: false);
      await storeProvider.checkPaymentStatus();
      if (storeProvider.paymentStatus == PAYMENT_STATUS.AUTHORIZED ||
          storeProvider.paymentStatus == PAYMENT_STATUS.CAPTURED) {
        Future.delayed(Duration.zero, () {
          Navigator.of(context).pushNamedAndRemoveUntil(
              PaymentSuccessfullScreen.routeName,
              (Route<dynamic> route) => false);
        });
      } else if (storeProvider.paymentStatus != PAYMENT_STATUS.NONE) {
        storeProvider.modifyLaunchNGenius(false);
        Future.delayed(Duration.zero, () {
          Navigator.of(context).pushNamedAndRemoveUntil(
              PaymentFailureScreen.routeName, (Route<dynamic> route) => false);
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // var storeProvider = Provider.of<StoreProvider>(context);
    return Scaffold(
      body: ConnectivityWidget(
        child: Center(
          child: Center(
            child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(values.NESTO_GREEN),
            ),
          ),
        ),
      ),
    );
  }
}
