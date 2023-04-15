import 'dart:async';
import 'dart:io';

import 'package:Nesto/extensions/number_extension.dart';
import 'package:Nesto/providers/orders_provider.dart';
import 'package:Nesto/screens/edit_order_screen.dart';
import 'package:Nesto/screens/order_cancellation.dart';
import 'package:Nesto/screens/product_list_orders.dart';
import 'package:Nesto/screens/return_order_screen.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/services/notification_service.dart';
import 'package:Nesto/strings.dart' as strings;
import 'package:Nesto/strings.dart';
import 'package:Nesto/utils/util.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/widgets/connectivity_widget.dart';
import 'package:Nesto/widgets/delivery_progress_timeline.dart';
import 'package:Nesto/widgets/edge_cases/connection_lost.dart';
import 'package:Nesto/widgets/edge_cases/failed_to_load.dart';
import 'package:Nesto/widgets/order_invoice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderListingScreen extends StatefulWidget {
  static const routeName = "/order_listing_screen";
  final String orderid;

  const OrderListingScreen({Key key, this.orderid}) : super(key: key);

  @override
  _OrderListingScreenState createState() => _OrderListingScreenState();
}

//GlobalKey<ScaffoldState> _scaffoldKeyDetails = GlobalKey<ScaffoldState>();

class _OrderListingScreenState extends State<OrderListingScreen> {
  String orderstatus;
  Future fture;

  Widget checkStatusWidget() {
    if (orderstatus == 'out_for_delivery') {
      return ProductDetailsContainer(strings.ON_THE_WAY,
          'assets/svg/place_holder_2_arun.svg', Color(0xff9FB7E7));
    } else if (orderstatus == 'picking_initiated') {
      return ProductDetailsContainer(strings.ORDER_GETTING_PICKED,
          'assets/svg/place_holder_7_arun.svg', Color(0xffEBC871));
    } else if (orderstatus == 'payment_failed') {
      return ProductDetailsContainer(strings.PAYMENT_FAILED,
          'assets/svg/place_holder_3_arun.svg', Colors.red);
    } else if (orderstatus == 'cancelled' || orderstatus == 'canceled') {
      return ProductDetailsContainer(
          strings.CANCELLED, 'assets/svg/place_holder_3_arun.svg', Colors.red);
    } else if (orderstatus == 'holded') {
      return ProductDetailsContainer(strings.SUBSTITUTED,
          'assets/svg/place_holder_1_arun.svg', Color(0xff7F8FA4));
    } else if (orderstatus == 'delivered') {
      return ProductDetailsContainer(strings.ORDER_DELIVERED,
          'assets/svg/place_holder_4_arun.svg', Color(0xff75BB5E));
    } else if (orderstatus == 'packing_initiated' ||
        orderstatus == 'picking_completed') {
      return ProductDetailsContainer(strings.ORDER_IS_GETTING_PACKED,
          'assets/svg/place_holder_7_arun.svg', Color(0xffEBC871));
    } else if (orderstatus == 'ready_for_delivery' ||
        orderstatus == 'packing_completed') {
      return ProductDetailsContainer(strings.ORDER_PACKED,
          'assets/svg/place_holder_7_arun.svg', Color(0xffEBC871));
    } else if (orderstatus == 'pending') {
      return ProductDetailsContainer(strings.ORDER_IS_PENDING,
          'assets/svg/place_holder_7_arun.svg', Color(0xffEBC871));
    } else if (orderstatus == 'payment_review') {
      return ProductDetailsContainer(strings.PAYMENT_REVIEW,
          'assets/svg/place_holder_7_arun.svg', Color(0xffEBC871));
    } else if (orderstatus == 'processing') {
      return ProductDetailsContainer(strings.ORDER_IS_PROCESSING,
          'assets/svg/place_holder_7_arun.svg', Color(0xffEBC871));
    } else if (orderstatus == 'vehicle_breakdown') {
      return ProductDetailsContainer(strings.VEHICLE_BREAKDOWN,
          'assets/svg/place_holder_7_arun.svg', Color(0xffEBC871));
    } else if (orderstatus == 'return_initiated') {
      return ProductDetailsContainer(strings.RETURN_INITIATED,
          'assets/svg/place_holder_4_arun.svg', Color(0xff75BB5E));
    } else if (orderstatus == 'returned') {
      return ProductDetailsContainer(strings.ORDER_RETURNED,
          'assets/svg/place_holder_4_arun.svg', Color(0xff75BB5E));
    } else if (orderstatus == 'return_collected') {
      return ProductDetailsContainer(strings.RETURN_COLLECTED,
          'assets/svg/place_holder_4_arun.svg', Color(0xff75BB5E));
    } else if (orderstatus == 'closed') {
      return ProductDetailsContainer(strings.CLOSED,
          'assets/svg/place_holder_4_arun.svg', Color(0xff75BB5E));
    } else if (orderstatus == 'return_cancelled') {
      return ProductDetailsContainer(strings.RETURN_CANCELLED,
          'assets/svg/place_holder_3_arun.svg', Colors.red);
    }
  }

  showEditProceedAlert() {
    notificationServices.showCustomDialog(
      title: "Edit Order?",
      description:
          "On editing, the prices of items will be updated. Do you want to continue?",
      negativeText: strings.NO,
      positiveText: strings.YES,
      action: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return EditOrder();
          },
        ),
      ),
    );
  }

  void _reportMissing() async {
    String sourceInfo = await getQueryParams(forMail: true);
    String incrementId = Provider.of<OrderProvider>(context, listen: false)
        .detailstest
        .increment_id;

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: CONTACT_US_EMAIL,
      query: encodeQueryParameters(<String, String>{
        'subject': 'Missing items #$incrementId',
        'body':
            "Do not delete the following information. ${Platform.isAndroid ? "\n\n$sourceInfo\n" : "$sourceInfo "}"
      }),
    );
    if (await canLaunch(emailLaunchUri.toString())) {
      launch(emailLaunchUri.toString());
    } else {
      throw 'Could not launch ${emailLaunchUri.toString()}';
    }
  }

  reload() {
    setState(() {
      fture = Provider.of<OrderProvider>(context, listen: false)
          .myorderdetails(widget.orderid);
    });
  }

  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "Order Listing Screen");
    // Provider.of<StoreProvider>(context, listen: false).modifyLaunchNGenius(false);
    fetchAuthToken();
    fture = Provider.of<OrderProvider>(context, listen: false)
        .myorderdetails(widget.orderid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () {
          EasyLoading.dismiss();
          Navigator.pop(context, true);
          return;
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          //key: _scaffoldKeyDetails,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            centerTitle: true,
            leading: Container(
              padding: EdgeInsets.all(10),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context, true);
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
              strings.ORDER_DETAILS,
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 1),
            ),
            elevation: 0,
          ),
          body: ConnectivityWidget(
            child: FutureBuilder(
              future: fture,
              builder: (context, snapshot) {
                logNesto(
                    "CONNECTION STATE:" + snapshot.connectionState.toString());
                var provider = Provider.of<OrderProvider>(context).detailstest;
                if (snapshot.connectionState == ConnectionState.done) {
                  if (provider == null)
                    orderstatus = 'pending';
                  else
                    orderstatus = provider.status;
                  return provider == null
                      ? FailedToLoadWidget(
                          text: strings.FAILED_TO_LOAD_ORDER_DETAILS,
                          toDo: reload,
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    DeliveryProgressTimeline(
                                      status: orderstatus,
                                    ),
                                    SizedBox(
                                      height: ScreenUtil().setHeight(20),
                                    ),
                                    checkStatusWidget(),
                                    SizedBox(
                                      height: ScreenUtil().setHeight(30),
                                    ),
                                    Visibility(
                                      visible:
                                          !(orderstatus == 'payment_failed' ||
                                              orderstatus == 'processing' ||
                                              orderstatus == 'payment_review' ||
                                              orderstatus == 'cancelled' ||
                                              orderstatus == 'canceled'),
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: ScreenUtil().setHeight(10),
                                          ),
                                          Container(
                                            height: ScreenUtil().setHeight(80),
                                            width: ScreenUtil().setWidth(290),
                                            decoration: BoxDecoration(
                                                color: Color(0xffF5F5F8),
                                                border: Border.all(
                                                  color: Color(0xffF5F5F8),
                                                ),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20))),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Container(
                                                    padding: EdgeInsets.all(2),
                                                    child: Lottie.asset(
                                                        'assets/animations/payment_confirm.json',
                                                        animate: true,
                                                        repeat: false,
                                                        height: 260,
                                                        width: 60)),
                                                SizedBox(
                                                  width: 25,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          strings.DELIVERY_ON,
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: Color(
                                                                0xff757D85),
                                                          ),
                                                        ),
                                                        Container(
                                                          width: ScreenUtil()
                                                              .setWidth(180),
                                                          child: Text(
                                                            Provider.of<OrderProvider>(
                                                                    context)
                                                                .detailstest
                                                                .date,
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          width: ScreenUtil()
                                                              .setWidth(180),
                                                          child: Text(
                                                            Provider.of<OrderProvider>(
                                                                    context)
                                                                .detailstest
                                                                .time,
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Visibility(
                                      visible:
                                          !(orderstatus == 'payment_failed' ||
                                              orderstatus == 'processing' ||
                                              orderstatus == 'payment_review' ||
                                              orderstatus == 'cancelled' ||
                                              orderstatus == 'canceled'),
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: ScreenUtil().setHeight(20),
                                          ),
                                          Container(
                                            height: ScreenUtil().setHeight(80),
                                            width: ScreenUtil().setWidth(290),
                                            decoration: BoxDecoration(
                                                color: Color(0xffF5F5F8),
                                                border: Border.all(
                                                  color: Color(0xffF5F5F8),
                                                ),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20))),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(2),
                                                  child: Lottie.asset(
                                                      'assets/animations/payment_confirm.json',
                                                      animate: true,
                                                      repeat: false,
                                                      height: 260,
                                                      width: 60),
                                                ),
                                                SizedBox(
                                                  width: 25,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          strings
                                                              .INAAM_POINTS_EARNED,
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: Color(
                                                                0xff757D85),
                                                          ),
                                                        ),
                                                        Text(
                                                          Provider.of<OrderProvider>(
                                                                  context)
                                                              .detailstest
                                                              .inaam,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Visibility(
                                      visible: (orderstatus ==
                                                  'picking_initiated' ||
                                              orderstatus == 'pending' ||
                                              orderstatus == 'delivered') &&
                                          (!Provider.of<OrderProvider>(context)
                                              .isreturnenabled),
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: ScreenUtil().setHeight(20),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              if (orderstatus ==
                                                      'picking_initiated' ||
                                                  orderstatus == 'pending') {
                                                showEditProceedAlert();
                                              } else if (orderstatus ==
                                                  'delivered') {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) {
                                                      return ReturnOrder();
                                                    },
                                                  ),
                                                );
                                              }
                                            },
                                            child: EditReturnCard(
                                              status: orderstatus,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: ScreenUtil().setHeight(20),
                                    ),
                                    orderstatus == 'pending' ||
                                            orderstatus ==
                                                'picking_initiated' ||
                                            orderstatus ==
                                                'picking_completed' ||
                                            orderstatus == 'packing_initiated'
                                        ? CancelButton()
                                        : SizedBox(),
                                    /*orderstatus == 'picking_initiated'
                                        ? CancelButton()
                                        : SizedBox(),*/
                                    //: SizedBox(),
                                    SizedBox(
                                      height: ScreenUtil().setHeight(20),
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.only(left: 20, bottom: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                            strings.DELIVERY_ADDRESS,
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10.0,
                                          ),
                                          Divider(),
                                          IconText(
                                            ic: Icons.streetview,
                                            text: provider.building,
                                          ),
                                          SizedBox(
                                            height: 10.0,
                                          ),
                                          IconText(
                                            ic: Icons.person,
                                            text: provider.name,
                                          ),
                                          SizedBox(
                                            height: 10.0,
                                          ),
                                          IconText(
                                            ic: Icons.phone,
                                            text: provider.phone,
                                          ),
                                          // SizedBox(
                                          //   height: 5.0,
                                          // ),
                                          // IconText(
                                          //   ic: Icons.email_outlined,
                                          //   text: provider.email,
                                          // ),
                                        ],
                                      ),
                                    ),
                                    Visibility(
                                      visible: !(orderstatus == 'cancelled' ||
                                          orderstatus == 'canceled'),
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            left: 20, bottom: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              height: 5.0,
                                            ),
                                            Text(
                                              strings.DELIVERY_TIME,
                                              style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10.0,
                                            ),
                                            Divider(),
                                            IconText(
                                              ic: Icons.calendar_today_outlined,
                                              text: provider.date ?? '--',
                                            ),
                                            SizedBox(
                                              height: 10.0,
                                            ),
                                            IconText(
                                              ic: Icons.timer,
                                              text: provider.time ?? '--',
                                            ),
                                            SizedBox(
                                              height: 10.0,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(20.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            strings.ORDER_INFORMATION,
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10.0,
                                          ),
                                          Divider(),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                strings.PRODUCTS,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Color(0xff666666),
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                              Row(
                                                children: [
                                                  provider.noitem == '1'
                                                      ? Text(
                                                          provider.noitem +
                                                              strings.ITEM +
                                                              ' ',
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              color: Color(
                                                                  0xff000000),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        )
                                                      : Text(
                                                          provider.noitem +
                                                              strings.ITEMS +
                                                              ' ',
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              color: Color(
                                                                  0xff000000),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      //firebase analytics logging.
                                                      firebaseAnalytics.viewItems(
                                                          orderID:
                                                              provider?.orderid,
                                                          incrementalID: provider
                                                              ?.increment_id);
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) {
                                                            return ProductListDisplay();
                                                          },
                                                        ),
                                                      );
                                                    },
                                                    child: SvgPicture.asset(
                                                        'assets/svg/place_holder_6_arun.svg'),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10.0,
                                          ),
                                          /*Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Price',
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Color(0xff666666),
                                                fontWeight: FontWeight.w400),
                                          ),
                                          Text(
                                            'AED ' +
                                                Provider.of<OrderProvider>(context)
                                                    .detailstest
                                                    .price
                                                    .substring(
                                                        0,
                                                        Provider.of<OrderProvider>(
                                                                    context)
                                                                .detailstest
                                                                .price
                                                                .length -
                                                            2),
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Color(0xff000000),
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),*/
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                strings.SHIPPING_EXCL_VAT,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Color(0xff666666),
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                              Text(
                                                strings.AED +
                                                    ' ' +
                                                    double.parse(provider
                                                            .shippingfee)
                                                        .twoDecimal(),
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Color(0xff000000),
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10.0,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                strings.COUPON_DISCOUNT,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Color(0xff666666),
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                              Text(
                                                strings.AED +
                                                    ' ' +
                                                    double.parse(provider
                                                            .discountDisplay)
                                                        .twoDecimal(),
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Color(0xff000000),
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10.0,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(strings.TOTAL_PRICE,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 17)),
                                              Text(
                                                strings.AED +
                                                    ' ' +
                                                    double.parse(provider.total)
                                                        .twoDecimal(),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 17),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: ScreenUtil().setHeight(20),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(
                                          left: 20.0, right: 20.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            strings.PAYMENT_METHOD,
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(
                                            height: ScreenUtil().setHeight(10),
                                          ),
                                          Divider(),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(provider?.card),
                                              Spacer(),
                                              Icon(Icons.check_box_outlined),
                                            ],
                                          ),
                                          SizedBox(
                                            height: ScreenUtil().setHeight(20),
                                          ),
                                          Visibility(
                                            visible: provider?.note != null &&
                                                provider.note.isNotEmpty,
                                            child: Text(
                                              strings.DELIVERY_NOTES,
                                              style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: ScreenUtil().setHeight(10),
                                          ),
                                          Visibility(
                                              visible: provider?.note != null &&
                                                  provider.note.isNotEmpty,
                                              child: Divider()),
                                          Visibility(
                                            visible: provider?.note != null &&
                                                provider.note.isNotEmpty,
                                            child: SizedBox(
                                              height:
                                                  ScreenUtil().setHeight(10),
                                            ),
                                          ),
                                          Visibility(
                                            visible: provider?.note != null &&
                                                provider.note.isNotEmpty,
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Container(
                                                child: Text(
                                                  provider?.note ?? '--',
                                                ),
                                              ),
                                            ),
                                          ),
                                          Invoice(
                                            url: provider?.invoiceUrl,
                                            status: provider?.status,
                                          ),
                                          SizedBox(
                                              height:
                                                  ScreenUtil().setWidth(30)),
                                          //#REPORT MISSING
                                          SizedBox(
                                            height: ScreenUtil().setWidth(50),
                                            child: Center(
                                              child: TextButton(
                                                style: ButtonStyle(
                                                  foregroundColor:
                                                      MaterialStateProperty.all<
                                                          Color>(Colors.grey),
                                                  overlayColor:
                                                      MaterialStateProperty.all<
                                                              Color>(
                                                          Colors.grey[100]),
                                                ),
                                                onPressed: _reportMissing,
                                                child: Text(
                                                  "Report missing items",
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      decoration: TextDecoration
                                                          .underline),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                              height:
                                                  ScreenUtil().setWidth(30)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(
                          valueColor: new AlwaysStoppedAnimation<Color>(
                              values.NESTO_GREEN)));
                } else
                  return Container(
                      color: Colors.white, child: ConnectionLostWidget());
              },
            ),
          ),
        ),
      ),
    );
  }
}

class IconText extends StatelessWidget {
  final IconData ic;
  final String text;

  const IconText({Key key, this.ic, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 3.0),
      child: Row(
        children: [
          Icon(
            ic,
            size: 15,
          ),
          SizedBox(
            width: 5.0,
          ),
          Flexible(
            child: Container(
              child: Text(
                text,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// class TimeOver extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: ScreenUtil().setHeight(80),
//       width: ScreenUtil().setWidth(290),
//       decoration: BoxDecoration(
//           color: Color(0xffF2F2F2),
//           border: Border.all(
//             color: Color(0xffF5F5F8),
//           ),
//           borderRadius: BorderRadius.all(Radius.circular(20))),
//       child: Padding(
//         padding: const EdgeInsets.only(left: 15.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Retry payment window closed',
//               style: TextStyle(
//                 fontSize: 10,
//                 fontWeight: FontWeight.w400,
//                 color: Color(0xff757D85),
//               ),
//             ),
//             Text(
//               'Please create a new order',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class ProductDetailsContainer extends StatelessWidget {
  final String title;
  final String asetimage;
  final Color clr;

  ProductDetailsContainer(this.title, this.asetimage, this.clr);

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<OrderProvider>(context).detailstest;

    return GestureDetector(
      onTap: () {
        //firebase analytics logging.
        firebaseAnalytics.viewItems(
            orderID: provider?.orderid, incrementalID: provider?.increment_id);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return ProductListDisplay();
            },
          ),
        );
      },
      child: Container(
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
                  color: clr,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                  padding: EdgeInsets.all(10),
                  child: SvgPicture.asset(asetimage)),
            ),
            SizedBox(
              width: ScreenUtil().setWidth(5),
            ),
            SizedBox(width: ScreenUtil().setWidth(5)),
            Expanded(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 14),
                    ),
                    Text(
                      provider.createdTime,
                      style: TextStyle(
                          color: Color(0xff7E7F80),
                          fontWeight: FontWeight.w500,
                          fontSize: 14),
                    ),
                    Text("#" + provider.increment_id,
                        style: TextStyle(
                            color: Color(0xff7E7F80),
                            fontWeight: FontWeight.w400,
                            fontSize: 14)),
                    provider.noitem == '1'
                        ? Text(
                            provider.noitem +
                                strings.ITEM +
                                ' | ' +
                                strings.AED +
                                " " +
                                double.parse(Provider.of<OrderProvider>(context)
                                        .detailstest
                                        .total)
                                    .twoDecimal(),
                            style: TextStyle(
                                color: Color(0xff7E7F80),
                                fontWeight: FontWeight.w400,
                                fontSize: 14),
                          )
                        : Text(
                            provider.noitem +
                                strings.ITEMS +
                                ' | ' +
                                strings.AED +
                                " " +
                                double.parse(provider.total).twoDecimal(),
                            style: TextStyle(
                                color: Color(0xff7E7F80),
                                fontWeight: FontWeight.w400,
                                fontSize: 14),
                          ),
                  ],
                ),
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(10)),
            Container(
              padding: EdgeInsets.all(20),
              child: SvgPicture.asset('assets/svg/place_holder_6_arun.svg'),
            ),
          ],
        ),
      ),
    );
  }
}

class EditReturnCard extends StatelessWidget {
  final String status;

  const EditReturnCard({Key key, this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (status == 'picking_initiated' || status == 'pending') {
      return Container(
        height: ScreenUtil().setHeight(80),
        width: ScreenUtil().setWidth(290),
        decoration: BoxDecoration(
            color: Color(0xffFFEAB6),
            border: Border.all(
              color: Color(0xffF5F5F8),
            ),
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: ScreenUtil().setWidth(2),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  strings.MADE_A_MISTAKE,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff757D85),
                  ),
                ),
                Text(
                  strings.EDIT_THIS_ORDER,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.all(20),
              child: SvgPicture.asset('assets/svg/place_holder_6_arun.svg'),
            ),
          ],
        ),
      );
    } else if (status == 'delivered') {
      return Container(
        height: ScreenUtil().setHeight(80),
        width: ScreenUtil().setWidth(290),
        decoration: BoxDecoration(
            color: Color(0xffFFDED1),
            border: Border.all(
              color: Color(0xffF5F5F8),
            ),
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  strings.HAVING_PROBLEMS,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff757D85),
                  ),
                ),
                Text(
                  strings.RETURN_ITEMS,
                  //or Replace
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.all(20),
              child: SvgPicture.asset('assets/svg/place_holder_6_arun.svg'),
            ),
          ],
        ),
      );
    } else {
      return SizedBox(
        height: 0,
      );
    }
  }
}

class CancelButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return OrderCancellation();
            },
          ),
        );
      },
      child: Container(
        height: ScreenUtil().setHeight(80),
        width: ScreenUtil().setWidth(290),
        decoration: BoxDecoration(
            color: Color(0xffFFDED1),
            border: Border.all(
              color: Color(0xffF5F5F8),
            ),
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: ScreenUtil().setWidth(2),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  strings.HAVING_PROBLEMS,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff757D85),
                  ),
                ),
                Text(
                  strings.CANCEL_THIS_ORDER,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.all(20),
              child: SvgPicture.asset('assets/svg/place_holder_6_arun.svg'),
            ),
          ],
        ),
      ),
    );
  }
}
