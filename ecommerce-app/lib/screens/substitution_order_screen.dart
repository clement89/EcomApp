import 'dart:developer';

import 'package:Nesto/extensions/number_extension.dart';
import 'package:Nesto/providers/substitution_provider.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/strings.dart' as strings;
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/widgets/edge_cases/connection_lost.dart';
import 'package:Nesto/widgets/headers.dart';
import 'package:Nesto/widgets/out_of_stock_item.dart';
import 'package:Nesto/widgets/product_list_container_orders.dart';
import 'package:Nesto/widgets/substitute_product.dart';
import 'package:Nesto/widgets/total_container_substitution.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:Nesto/widgets/dynamic_homepage_widgets/edit_loader_widget.dart';

class SubstitutionOrderScreen extends StatefulWidget {
  static String routeName = "substitution_order_screen";

  const SubstitutionOrderScreen({Key key}) : super(key: key);

  @override
  _SubstitutionOrderScreenState createState() =>
      _SubstitutionOrderScreenState();
}

class _SubstitutionOrderScreenState extends State<SubstitutionOrderScreen> {
  Future _suggestionsFuture;
  bool _editSyncLoader = false;

  startEditSync() => setState(() => _editSyncLoader = true);

  stopEditSync() => setState(() => _editSyncLoader = false);

  String formatTime(double time) {
    Duration duration = Duration(seconds: time.toInt());
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "Substitution Order Screen");
    super.initState();
    var provider = Provider.of<SubstitutionProvider>(context, listen: false);
    _suggestionsFuture = provider.getSubstituteSuggestions();
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<SubstitutionProvider>(context);

    return SafeArea(
        child: Stack(
      alignment: Alignment.center,
      children: [
        Scaffold(
          appBar: headerBar(title: strings.SUBSTITUTE_ORDER, context: context),
          body: Container(
            height: double.infinity,
            width: double.infinity,
            child: Column(
              children: [
                Flexible(
                  flex: 1,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: ScreenUtil().setWidth(32),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil().setWidth(16)),
                          child: Stack(
                            children: [
                              ProductListContainer(
                                  strings.ORDER_ON_HOLD,
                                  provider?.substituteOrder?.orderCreatedAt ??
                                      '--',
                                  provider?.substituteOrder?.salesIncrementalId,
                                  provider?.substituteOrder?.itemCount
                                      .toString(),
                                  provider?.substituteOrder?.paymentAmount
                                      ?.twoDecimal(),
                                  'assets/svg/place_holder_7_arun.svg',
                                  Colors.transparent),
                              Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      top: ScreenUtil().setWidth(
                                          values.SPACING_MARGIN_TEXT)),
                                  child: Container(
                                    width: ScreenUtil().setWidth(86),
                                    height: ScreenUtil().setWidth(30),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.black87),
                                    ),
                                    child: Center(
                                      child: Countdown(
                                        seconds: provider.cuttOff,
                                        build: (BuildContext context,
                                                double time) =>
                                            Text(
                                          formatTime(time),
                                          style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        interval: Duration(seconds: 1),
                                        onFinished: () {
                                          log("Timer done");
                                          Navigator.of(context).maybePop();
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: ScreenUtil().setWidth(40),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil().setWidth(16)),
                          child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                strings.ITEMS_OUT_OF_STOCK,
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Colors.black87),
                              )),
                        ),
                        SizedBox(
                          height: ScreenUtil()
                              .setWidth(values.SPACING_MARGIN_STANDARD),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil().setWidth(8)),
                          child: SizedBox(
                            height: ScreenUtil().setWidth(90),
                            child:
                                OutOfStockItemWidget(provider?.outOfStockItem),
                          ),
                        ),
                        SizedBox(
                          height: ScreenUtil().setWidth(42),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil().setWidth(16)),
                          //child: Text(strings.SUBSTITUTION_PROCESS_DESC,style: TextStyle(color: Colors.black87,fontSize: 16),),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: new TextSpan(
                              style: TextStyle(
                                  color: Colors.black87, fontSize: 13),
                              children: <TextSpan>[
                                new TextSpan(
                                    text: strings
                                        .SINCE_THE_ABOUVE_ITEM_IS_OUT_OF_STOCK),
                                new TextSpan(
                                    text: strings
                                        .PLEASE_CHOOSE_A_RELATED_ITEM_FROM_THE_LIST_BELOW,
                                    style: new TextStyle(
                                        fontWeight: FontWeight.w700)),
                                new TextSpan(
                                    text: strings
                                        .AND_MAKE_SUBSTITUTION_FOR_THIS_ORDER),
                                new TextSpan(
                                    text: strings
                                        .UPDATED_AMOUNT_WILL_BE_CALCULATED_BASED_ON_SUBSTITUTION,
                                    style: new TextStyle(
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: ScreenUtil().setWidth(42),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil().setWidth(16)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                strings.AVAILABLE_SUBSTITUTES,
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: ScreenUtil()
                              .setWidth(values.SPACING_MARGIN_LARGE),
                        ),
                        SizedBox(
                          height: ScreenUtil().setWidth(305),
                          width: double.infinity,
                          child: FutureBuilder(
                            future: _suggestionsFuture,
                            builder: (_, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                return ListView.builder(
                                    padding: EdgeInsets.only(
                                        left: ScreenUtil().setWidth(10)),
                                    scrollDirection: Axis.horizontal,
                                    itemCount:
                                        provider?.itemSuggestions?.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: EdgeInsets.only(
                                            right: ScreenUtil().setWidth(10)),
                                        child: SubstituteProduct(
                                          item: provider.itemSuggestions[index],
                                          startSync: startEditSync,
                                          stopSync: stopEditSync,
                                        ),
                                      );
                                    });
                              } else if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(
                                    valueColor:
                                        new AlwaysStoppedAnimation<Color>(
                                            values.NESTO_GREEN),
                                    strokeWidth: ScreenUtil().setWidth(3),
                                  ),
                                );
                              } else {
                                return Center(
                                  child: ConnectionLostWidget(),
                                );
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          height: ScreenUtil()
                              .setWidth(values.SPACING_MARGIN_X_LARGE),
                        ),
                        TotalContainer(),
                        SizedBox(
                          height: ScreenUtil()
                              .setWidth(values.SPACING_MARGIN_STANDARD),
                        ),
                      ],
                    ),
                  ),
                ),
                //bottom container
                BottomContainer(provider: provider),
              ],
            ),
          ),
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

class BottomContainer extends StatelessWidget {
  const BottomContainer({
    Key key,
    @required this.provider,
  }) : super(key: key);

  final SubstitutionProvider provider;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setWidth(120.0),
      width: double.infinity,
      decoration: bottomContainerDecoration,
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(18.0)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.GRAND_TOTAL,
                    style: TextStyle(
                      fontSize: 17.67,
                      height: 1.19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    strings.VAT_INCLUSIVE,
                    style: TextStyle(
                        fontSize: 12,
                        height: 1.19,
                        color: Color(0XFF898B9A),
                        fontWeight: FontWeight.w500),
                  )
                ],
              ),
              Text(
                strings.AED + ' ' + provider.total.twoDecimal(),
                style: TextStyle(fontSize: 22.09, fontWeight: FontWeight.w800),
              )
            ],
          ),
        ],
      ),
    );
  }
}

//styles
BoxDecoration bottomContainerDecoration = BoxDecoration(
    color: Colors.white,
    boxShadow: [
      BoxShadow(
          color: Color(0XFF000000).withOpacity(0.05),
          blurRadius: 10.0,
          offset: Offset(0.0, 0.75))
    ],
    borderRadius: BorderRadius.only(
        topLeft: Radius.circular(18.0), topRight: Radius.circular(18.0)));
