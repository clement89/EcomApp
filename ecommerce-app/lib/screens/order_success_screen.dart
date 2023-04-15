import 'dart:core';

import 'package:Nesto/extensions/number_extension.dart';
import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/screens/base_screen.dart';
import 'package:Nesto/screens/rate_experience.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/strings.dart' as strings;
import 'package:Nesto/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class OrderSuccessfullScreen extends StatefulWidget {
  static String routeName = "/order_successfull_screen";

  @override
  _OrderSuccessfullScreenState createState() => _OrderSuccessfullScreenState();
}

class _OrderSuccessfullScreenState extends State<OrderSuccessfullScreen>
    with TickerProviderStateMixin {
  //AnimationController _controller;

  String timeSlotForDelivery = "";
  double inaamPoints = 0;

  String getDateText(DateTime date) {
    return DateFormat("MMMM d").format(date);
  }

  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "Order Success Screen");
    super.initState();
    Future.delayed(Duration.zero, () {
      var provider = Provider.of<StoreProvider>(context, listen: false);
      setState(() {
        inaamPoints = getInaamPoints(provider.subTotal);
        timeSlotForDelivery = getDateText(provider.selectedDateForDelivery) +
            " " +
            provider.selectedFromTimeForDelivery +
            "-" +
            provider.selectedToTimeForDelivery;
        provider.resetCart(true);
      });
    });
  }

  Future<bool> _willPopCallback() async {
    // Provider.of<StoreProvider>(context, listen: false).resetValues();
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
                // titleText(),
                SizedBox(height: ScreenUtil().setHeight(28.85)),
                Container(
                  child: SizedBox(
                    height: ScreenUtil().setWidth(284),
                    width: ScreenUtil().setWidth(284),
                    child: Lottie.asset(
                      'assets/animations/order_payment_confirm.json',
                      repeat: false,
                    ),
                  ),
                ),
                Text(
                  strings.ORDER_SUCCESFULLY_PLACED,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
                Container(
                  margin: EdgeInsets.only(top: ScreenUtil().setHeight(26.0)),
                  padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(45.0)),
                  child: Text(
                    strings.ORDER_SUCCESSFUL_DESCRIPTION +
                        Provider.of<StoreProvider>(context, listen: false)
                            .incrementId,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, fontSize: 17),
                  ),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(40.0),
                ),
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
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: GreenButton(
                      buttonTitle: strings.Shop_More,
                      onPress: () {
                        Navigator.of(context)
                            .pushNamed(RateExperience.routeName);
                      },
                    ),
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
