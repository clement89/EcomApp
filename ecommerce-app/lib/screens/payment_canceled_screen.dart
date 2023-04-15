import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/screens/base_screen.dart';
import 'package:Nesto/screens/rate_experience.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:Nesto/strings.dart' as strings;
import '../values.dart' as values;

class PaymentCancelScreen extends StatefulWidget {
  static String routeName = "/payment_cancel_screen";

  @override
  _PaymentCancelScreenState createState() => _PaymentCancelScreenState();
}

class _PaymentCancelScreenState extends State<PaymentCancelScreen>
    with TickerProviderStateMixin {
  //AnimationController _controller;
  //

  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "Payment Cancellation Screen");
    super.initState();
    Future.delayed(Duration.zero, () async {
      var provider = Provider.of<StoreProvider>(context, listen: false);
      provider.cancelOrder();
      // try {
      //   await provider.addAllProductsToMagentoCart();
      // } catch (e) {
      //   provider.resetCart(true);
      // }
      provider.resetCart(false);
      provider.shippingAddress = null;
    });
    //firebase analytics logging.
    firebaseAnalytics.logPaymentCancel();
  }

  Future<bool> _willPopCallback() async {
    Navigator.of(context)
        .pushReplacementNamed(BaseScreen.routeName, arguments: {"index": 0});
    return false; // return true if the route to be popped
  }

  @override
  Widget build(BuildContext context) {
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
                titleText(),
                SizedBox(height: ScreenUtil().setHeight(28.85)),
                Container(
                  child: SizedBox(
                    height: ScreenUtil().setWidth(283),
                    width: ScreenUtil().setWidth(283),
                    child: Lottie.asset(
                      'assets/animations/order_cancelled.json',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Text(
                    strings.ORDER_PROCESSIG_CANCELLED,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: ScreenUtil().setHeight(26.0)),
                  padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(45.0)),
                  child: Text(
                    strings.ORDER_PROCESSING_CANCELLED_DESCRIPTION,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, fontSize: 17),
                  ),
                ),
                Expanded(child: SizedBox()),
                GreenButton(
                    buttonTitle: strings.Shop_More,
                    onPress: () {
                      //firebase analytics logging.
                      firebaseAnalytics.logShopMore();
                      Navigator.of(context).pushReplacementNamed(
                          BaseScreen.routeName,
                          arguments: {"index": 0});
                    }),
                SizedBox(
                  height: ScreenUtil().setWidth(values.SPACING_MARGIN_STANDARD),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Text titleText() {
    return Text(
      strings.ORDER_CANCELLED.toUpperCase(),
      style: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
        color: Color(0XFF111A2C),
      ),
    );
  }
}
