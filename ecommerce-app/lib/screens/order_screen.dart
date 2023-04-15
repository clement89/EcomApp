import 'dart:async';

import 'package:Nesto/models/orderlistmodel.dart';
import 'package:Nesto/providers/orders_provider.dart';
import 'package:Nesto/providers/substitution_provider.dart';
import 'package:Nesto/screens/base_screen.dart';
import 'package:Nesto/screens/order_listing_screen.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/widgets/connectivity_widget.dart';
import 'package:Nesto/widgets/edge_cases/connection_lost.dart';
import 'package:Nesto/widgets/edge_cases/no_orders_yet.dart';
import 'package:Nesto/widgets/order_list_widget.dart';
import 'package:Nesto/widgets/product_list_container_orders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';
import 'package:Nesto/strings.dart' as strings;
class OrderScreen extends StatefulWidget {
  static const routeName = "/order_screen";

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  bool isActive = false;
  String text;
  Future orderfuture;

  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "Order Screen");
    orderfuture = Provider.of<OrderProvider>(context, listen: false).myorders();
    super.initState();
  }

  Future navigatePage(String orderid) async {
    final reload = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return OrderListingScreen(
            orderid: orderid,
          );
        },
      ),
    );
    print("reload orders: $reload");
    //reload future when poped from order_details.
    if (reload) {
      setState(() {
        orderfuture =
            Provider.of<OrderProvider>(context, listen: false).myorders();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //ScreenUtil.init(context);
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pushReplacementNamed(BaseScreen.routeName,
            arguments: {"index": 4});
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            centerTitle: true,
            leading: GestureDetector(
              onTap: () {
                Navigator.of(context).pushReplacementNamed(BaseScreen.routeName,
                    arguments: {"index": 4});
                //Navigator.of(context).pop();
              },
              child: Container(
                padding: EdgeInsets.all(10),
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
              strings.MY_ORDERS.toUpperCase(),
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 1),
            ),
            elevation: 0,
            bottom: TabBar(
              indicatorColor: Colors.green,
              labelColor: Colors.green,
              unselectedLabelColor: Colors.black,
              tabs: [
                Tab(text: strings.ONGOING),
                Tab(text: strings.COMPLETED),
              ],
            ),
          ),
          body: ConnectivityWidget(
            child: TabBarView(
              children: [
                FutureBuilder(
                  future: orderfuture,
                  builder: (context, snapshot) {
                    /*logNesto('AUTH TOKEN' +
                        Provider.of<OrderProvider>(context, listen: false)
                            .authToken);*/
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Provider.of<OrderProvider>(context)
                                  .orderlisttest
                                  .length ==
                              0
                          ? Container(
                              color: Colors.white,
                              child: NoOrdersYetWidget(),
                            )
                          : Container(
                              child: GroupedListView<OrderListModel, String>(
                                elements: Provider.of<OrderProvider>(context)
                                    .orderlisttest,
                                //order: GroupedListOrder.ASC,
                                itemComparator: (item1, item2) =>
                                    item2.createdAt.compareTo(item1.createdAt),
                                groupBy: (OrderListModel element) {
                                  return element.status;
                                },
                                floatingHeader: true,
                                groupHeaderBuilder: (OrderListModel element) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        left: ScreenUtil().setWidth(25.0)),
                                    child: SizedBox(
                                      height: ScreenUtil().setHeight(74.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            element.status,
                                            style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w700),
                                          ),
                                          Divider(),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                itemBuilder: (_, OrderListModel element) {
                                  if (element.title ==
                                      'Order Waiting for Substitutes') {
                                    return GestureDetector(
                                      onTap: () {
                                        EasyLoading.show(
                                          //status: 'Processing...',
                                          maskType: EasyLoadingMaskType.black,
                                        );
                                        Provider.of<SubstitutionProvider>(
                                                context,
                                                listen: false)
                                            .getOrderSubstitute(element.orderid)
                                            .then(
                                          (value) {
                                            EasyLoading.dismiss();
                                            return Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) {
                                                  // return SubstitutionScreen();
                                                },
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: ProductListContainer(
                                          strings.ORDER_WAITING_FOR_SUBSTITUTES,
                                          element.datetime,
                                          element.increment_id,
                                          element.noitem,
                                          element.price,
                                          'assets/svg/place_holder_1_arun.svg',
                                          Color(0xff7F8FA4)),
                                    );
                                  } else if (element.title == 'On The Way') {
                                    return GestureDetector(
                                      onTap: () {
                                        navigatePage(element.orderid);
                                      },
                                      child: ProductListContainer(
                                          strings.ON_THE_WAY,
                                          element.datetime,
                                          element.increment_id,
                                          element.noitem,
                                          element.price,
                                          'assets/svg/place_holder_2_arun.svg',
                                          Color(0xff9FB7E7)),
                                    );
                                  } else if (element.title ==
                                      'Order is Pending') {
                                    return GestureDetector(
                                      onTap: () {
                                        navigatePage(element.orderid);
                                      },
                                      child: ProductListContainer(
                                          element.title,
                                          element.datetime,
                                          element.increment_id,
                                          element.noitem,
                                          element.price,
                                          'assets/svg/place_holder_7_arun.svg',
                                          Color(0xffEBC871)),
                                    );
                                  } else if (element.title ==
                                      'Payment Review') {
                                    return GestureDetector(
                                      onTap: () {
                                        navigatePage(element.orderid);
                                      },
                                      child: ProductListContainer(
                                          element.title,
                                          element.datetime,
                                          element.increment_id,
                                          element.noitem,
                                          element.price,
                                          'assets/svg/place_holder_7_arun.svg',
                                          Color(0xffEBC871)),
                                    );
                                  } else if (element.title ==
                                      'Order is Getting Packed') {
                                    return GestureDetector(
                                      onTap: () {
                                        navigatePage(element.orderid);
                                      },
                                      child: ProductListContainer(
                                          element.title,
                                          element.datetime,
                                          element.increment_id,
                                          element.noitem,
                                          element.price,
                                          'assets/svg/place_holder_7_arun.svg',
                                          Color(0xffEBC871)),
                                    );
                                  }else if (element.title ==
                                      'Order Packed') {
                                    return GestureDetector(
                                      onTap: () {
                                        navigatePage(element.orderid);
                                      },
                                      child: ProductListContainer(
                                          element.title,
                                          element.datetime,
                                          element.increment_id,
                                          element.noitem,
                                          element.price,
                                          'assets/svg/place_holder_7_arun.svg',
                                          Color(0xffEBC871)),
                                    );
                                  } else if (element.title ==
                                      'Payment Failed') {
                                    return GestureDetector(
                                      onTap: () {
                                        navigatePage(element.orderid);
                                      },
                                      child: ProductListContainer(
                                          element.title,
                                          element.datetime,
                                          element.increment_id,
                                          element.noitem,
                                          element.price,
                                          'assets/svg/place_holder_3_arun.svg',
                                          Colors.red),
                                    );
                                  } else if (element.title ==
                                      'Order is Getting Picked') {
                                    return GestureDetector(
                                      onTap: () {
                                        navigatePage(element.orderid);
                                      },
                                      child: ProductListContainer(
                                          element.title,
                                          element.datetime,
                                          element.increment_id,
                                          element.noitem,
                                          element.price,
                                          'assets/svg/place_holder_7_arun.svg',
                                          Color(0xffEBC871)),
                                    );
                                  } else {
                                    return GestureDetector(
                                      onTap: () {
                                        navigatePage(element.orderid);
                                      },
                                      child: ProductListContainer(
                                          element.title,
                                          element.datetime,
                                          element.increment_id,
                                          element.noitem,
                                          element.price,
                                          'assets/svg/place_holder_7_arun.svg',
                                          Color(0xffEBC871)),
                                    );
                                  }
                                },
                              ),
                            );
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(
                          child: CircularProgressIndicator(
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                  values.NESTO_GREEN)));
                    } else
                      return Container(
                        color: Colors.white,
                        child: ConnectionLostWidget(),
                      );
                  },
                ),
                FutureBuilder(
                  future: orderfuture,
                  builder: (context, snapshot) {
                    /*logNesto('AUTH TOKEN' +
                        Provider.of<OrderProvider>(context, listen: false)
                            .authToken);*/
                    if (snapshot.connectionState == ConnectionState.done) {
                      return ProductList();
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(
                          child: CircularProgressIndicator(
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                  values.NESTO_GREEN)));
                    } else
                      return Container(
                        color: Colors.white,
                        child: ConnectionLostWidget(),
                      );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
