import 'dart:async';

import 'package:Nesto/extensions/number_extension.dart';
import 'package:Nesto/models/order_details.dart';
import 'package:Nesto/providers/orders_provider.dart';
import 'package:Nesto/screens/replace_return_succes_screen.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/strings.dart' as strings;
import 'package:Nesto/widgets/connectivity_widget.dart';
import 'package:Nesto/widgets/dismiss_keyboard_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class OrderCancellation extends StatefulWidget {
  static final routeName = "/order_cancellation";

  @override
  _OrderCancellationState createState() => _OrderCancellationState();
}

//GlobalKey<ScaffoldState> _scaffoldKeyCancel = GlobalKey<ScaffoldState>();

class _OrderCancellationState extends State<OrderCancellation> {
  TextEditingController cancelreason = new TextEditingController();
  bool isDisableOnBack = false;
  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "Order Cancellation Screen");
    isDisableOnBack = false;
    var provider = Provider.of<OrderProvider>(context, listen: false);
    provider.modifysuccesscreenvalues();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (Provider.of<OrderProvider>(context, listen: false).successcancel) {
      Future.delayed(Duration.zero, () {
        EasyLoading.dismiss();

        Provider.of<OrderProvider>(context, listen: false)
            .modifysuccesscreenvalues();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return ReturnReplaceScreen(
                screencheck: 4,
              );
            },
          ),
        );
      });
    }
    if (Provider.of<OrderProvider>(context).errorcancel) {
      //SHOW ALERT DIALOG
      EasyLoading.dismiss();
      isDisableOnBack = false;

      // showInfo(
      //     context,
      //     Provider.of<OrderProvider>(context, listen: false)
      //         .errorcancelmessage);
      Future.delayed(Duration.zero, () async {
        Provider.of<OrderProvider>(context, listen: false)
            .modifysuccesscreenvalues();
      });
    }
    return WillPopScope(
      onWillPop: () {
        //var provider = Provider.of<OrderProvider>(context, listen: false);
        if (!isDisableOnBack) {
          EasyLoading.dismiss();
          Provider.of<OrderProvider>(context, listen: false)
              .modifysuccesscreenvalues();
          Navigator.of(context).pop();
        }

        return;
      },
      child: DismissKeyboard(
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            centerTitle: true,
            leading: Container(
              padding: EdgeInsets.all(10),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                    height: ScreenUtil().setHeight(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        width: 1,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.black,
                            size: 15,
                          ),
                        ),
                      ],
                    )),
              ),
            ),
            title: Text(
              strings.CANCEL_ORDER,
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 1),
            ),
            elevation: 0,
          ),
          body: ConnectivityWidget(
            child: SingleChildScrollView(
              child: GestureDetector(
                onTap: () {
                  WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ProductCancelledContainer(),
                    SizedBox(
                      height: ScreenUtil().setHeight(30),
                    ),
                    Container(
                      height: ScreenUtil().setHeight(80),
                      width: ScreenUtil().setWidth(360),
                      decoration: BoxDecoration(
                          color: Color(0xffFFDED1),
                          border: Border.all(
                            color: Color(0xffF5F5F8),
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            strings
                                .CANCEL_THIS_ORDER_MAY_CAUSE_YOU_TO_LOSE_PROMOTIONAL,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color(0xff111A2C)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(30),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            strings.REASON_FOR_CANCELLATION,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                                fontSize: 17),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                          )
                          // Divider(),
                        ],
                      ),
                    ),
                    Container(
                      height: 150,
                      margin: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 20.0),
                      decoration: borderDecoration,
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        minLines: 1, //Normal textInputField will be displayed
                        maxLines:
                            5, // when user presses enter it will adapt to it
                        controller: cancelreason,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(22),
                          hintText: strings.REASON_FOR_CANCELLATION,
                          hintStyle: TextStyle(
                            fontSize: 12.0,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Visibility(
                            maintainSize: true,
                            maintainAnimation: true,
                            maintainState: true,
                            visible: Provider.of<OrderProvider>(context,
                                        listen: false)
                                    .detailstest
                                    .card ==
                                'Card Payment',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  strings.CONFIRM_CANCELLATION,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 17),
                                ),
                                Divider(),
                                RichText(
                                  text: TextSpan(
                                    text: strings.THE_BALANCE_AMOUNT_OF +
                                        Provider.of<OrderProvider>(context)
                                            .detailstest
                                            .total
                                            .substring(
                                                0,
                                                Provider.of<OrderProvider>(
                                                            context)
                                                        .detailstest
                                                        .total
                                                        .length -
                                                    2) +
                                        strings
                                            .WILL_BE_REFUNDED_TO_YOU_VIA_ORIGINAL_PAYMENT_METHOD,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: strings
                                            .PLEASE_WAIT_3_4_BUSINESS_DAYS_TO_RECIEVE_THE_REFUND,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: ScreenUtil().setHeight(40),
                                ),
                              ],
                            ),
                          ),
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                isDisableOnBack = true;
                                EasyLoading.show(
                                  //status: 'Processing...',
                                  maskType: EasyLoadingMaskType.black,
                                );

                                var provider = Provider.of<OrderProvider>(
                                        context,
                                        listen: false)
                                    .detailstest;

                                var cancelreasontext = cancelreason.text.trim();
                                Provider.of<OrderProvider>(context,
                                        listen: false)
                                    .CancelOrder(
                                        provider.orderid,
                                        cancelreasontext,
                                        provider.customer_id,
                                        provider.increment_id);
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.70,
                                height: ScreenUtil().setHeight(60),
                                decoration: BoxDecoration(
                                  color: Color(0XFF00983D),
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(10),
                                      topLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                      bottomLeft: Radius.circular(10)),
                                ),
                                child: Center(
                                  child: Text(
                                    strings.CANCEL_THIS_ORDER,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17.67,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProductCancelledContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<OrderProvider>(context).detailstest;
    String title;
    if (provider.status == 'picking_initiated')
      title = strings.ORDER_GETTING_PICKED;
    else
      title = strings.ORDER_IS_PENDING;
    return Container(
      padding: EdgeInsets.all(10),
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      height: ScreenUtil().setHeight(140),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.all(5),
            width: MediaQuery.of(context).size.width * 0.20,
            height: ScreenUtil().setHeight(150),
            decoration: BoxDecoration(
              color: Color(0xffF6F7FA),
              border: Border.all(
                width: 2,
                color: Color(0xffEBC871),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
                padding: EdgeInsets.all(10),
                child: SvgPicture.asset(
                  'assets/svg/place_holder_7_arun.svg',
                )),
          ),
          SizedBox(
            width: ScreenUtil().setWidth(5),
          ),
          SizedBox(width: ScreenUtil().setWidth(5)),
          Expanded(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 14),
                  ),
                  Text(
                    provider.datetime,
                    style: TextStyle(
                        color: Color(0xff7E7F80),
                        fontWeight: FontWeight.w500,
                        fontSize: 14),
                  ),
                  Text('#' + provider.increment_id,
                      style: TextStyle(
                          color: Color(0xff7E7F80),
                          fontWeight: FontWeight.w400,
                          fontSize: 14)),
                  provider.noitem == '1'
                      ? Text(
                          provider.noitem +
                              strings.ITEM +
                              ' | ' +
                              double.parse(provider.total).twoDecimal(),
                          style: TextStyle(
                              color: Color(0xff7E7F80),
                              fontWeight: FontWeight.w400,
                              fontSize: 14),
                        )
                      : Text(
                          provider.noitem +
                              strings.ITEMS +
                              ' | ' +
                              double.parse(provider.total).twoDecimal(),
                          style: TextStyle(
                              color: Color(0xff7E7F80),
                              fontWeight: FontWeight.w400,
                              fontSize: 14),
                        )
                ],
              ),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(10)),
        ],
      ),
    );
  }
}

var borderDecoration = BoxDecoration(
  border: Border.all(width: 1.4, color: Colors.grey[700]),
  borderRadius: BorderRadius.circular(8.95),
);
