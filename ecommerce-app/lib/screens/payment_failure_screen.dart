import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/screens/base_screen.dart';
import 'package:Nesto/screens/payment_gateway_webpage.dart';
import 'package:Nesto/screens/rate_experience.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:Nesto/strings.dart' as strings;
import '../values.dart' as values;

class PaymentFailureScreen extends StatefulWidget {
  static String routeName = "/payment_failure_screen";

  @override
  _PaymentFailureScreenState createState() => _PaymentFailureScreenState();
}

class _PaymentFailureScreenState extends State<PaymentFailureScreen>
    with TickerProviderStateMixin {
  //AnimationController _controller;

  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "Payment Failure Screen");
    super.initState();
    Future.delayed(Duration.zero, () {
      var provider = Provider.of<StoreProvider>(context, listen: false);
      provider.resetCart(false);
      // provider.addAllProductsToMagentoCart();
    });
  }

  Future<bool> _willPopCallback() async {
    EasyLoading.dismiss();
    Provider.of<StoreProvider>(context, listen: false).resetCart(false);
    Provider.of<StoreProvider>(context, listen: false).shippingAddress = null;
    // Provider.of<StoreProvider>(context, listen: false).resetValues();
    // Provider.of<StoreProvider>(context, listen: false)
    //     .modifyLaunchNGenius(false);
    Navigator.of(context)
        .pushReplacementNamed(BaseScreen.routeName, arguments: {"index": 0});
    return false; // return true if the route to be popped
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<StoreProvider>(context, listen: false);

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
                Text(
                  strings.ORDER_IS_UNSUCCESFULL,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                ),
                Container(
                  margin: EdgeInsets.only(top: ScreenUtil().setHeight(26.0)),
                  padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(57.0)),
                  child: Text(
                    strings.SORRY_YOUR_ORDER_HAS_BEEN_FAILED,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, fontSize: 17),
                  ),
                ),
                Expanded(child: SizedBox()),
                GreenButton(
                    buttonTitle: strings.RETRY_PAYMENT,
                    onPress: () async {
                      //firebase analytics logging.
                      firebaseAnalytics.logPaymentRetry();
                      EasyLoading.show(
                        //status: 'Processing...',
                        maskType: EasyLoadingMaskType.black,
                      );
                      await provider.paymentGateway(
                          provider.enableSubstitution, provider.deliveryNote);
                      if (provider.launchNGenius) {
                        logNesto("LAUNCH NGENIUS");
                        Future.delayed(Duration.zero, () {
                          Navigator.of(context).pushReplacementNamed(
                              PaymentGatewayWebpage.routeName);
                        });
                      }
                      EasyLoading.dismiss();
                    }),
                SizedBox(
                  height: ScreenUtil().setWidth(values.SPACING_MARGIN_STANDARD),
                ),
                GreenButton(
                    buttonTitle: strings.Shop_More,
                    onPress: () {
                      provider.resetCart(false);
                      provider.shippingAddress = null;
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
      strings.PAYMENT_FAILED.toUpperCase(),
      style: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
        color: Color(0XFF111A2C),
      ),
    );
  }
}
