import 'dart:convert';

import 'package:Nesto/extensions/number_extension.dart';
import 'package:Nesto/models/order_details.dart';
import 'package:Nesto/providers/orders_provider.dart';
import 'package:Nesto/screens/replace_return_succes_screen.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/utils/util.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/widgets/dismiss_keyboard_widget.dart';
import 'package:Nesto/widgets/headers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:Nesto/strings.dart' as strings;

class ReturnConfirmScreen extends StatefulWidget {
  static String routeName = "return_confirm_screen";
  const ReturnConfirmScreen({Key key, this.returnItems}) : super(key: key);

  final List<Item> returnItems;

  @override
  _ReturnConfirmScreenState createState() => _ReturnConfirmScreenState();
}

class _ReturnConfirmScreenState extends State<ReturnConfirmScreen> {
  bool _loading = false;
  List<Item> _returnItems;
  OrderDetails _currentOrder;
  String _returnReason = "";

  showLoading() => setState(() => _loading = true);
  stopLoading() => setState(() => _loading = false);

  onChangeText(String value) {
    setState(() {
      _returnReason = value;
    });
  }

  _onConfirm() {
    if (_returnReason.trim().isEmpty) {
      showError(context, strings.PLEASE_MENTION_A_REASON_TO_RETURN);
      return;
    }

    _proceedWithReturn();
  }

  _proceedWithReturn() async {
    var queryParams = await getQueryParams() ?? "";

    String _lambdaOrderUrl =
        FlavorConfig.instance.variables["LAMBDA_ORDER_URL"];
    String uri = _lambdaOrderUrl + '/return?' + queryParams;

    var headers = {
      "Content-Type": "application/json",
      "access-token": getLambdaToken()
    };

    var payload = {
      "sales_order_id": _currentOrder.entityId,
      "items": _returnItems.map((item) => item.toReturnJson()).toList(),
      "return_reason": _returnReason.trim(),
      "order_kind": "return",
      "cancellation_type": "partial"
    };

    print("==============>");
    print("PAYLOAD: $payload");
    print("<==============");

    try {
      showLoading();

      var response = await http.post(
        Uri.parse(uri),
        headers: headers,
        body: jsonEncode(payload),
      );

      var decodedResponse = jsonDecode(response.body);

      print("==============>");
      print("RESPONSE: $decodedResponse");
      print("<==============");

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return ReturnReplaceScreen(
                screencheck: 2,
              );
            },
          ),
        );
      } else {
        if (decodedResponse["item_expiry"] == true) {
          Navigator.of(context).pop(decodedResponse);
        } else
          throw Exception(decodedResponse["message"] ??
              strings.SOMETHING_WENT_WRONG_WITH_EXCLAMATION);
      }
    } catch (e) {
      stopLoading();
      print(e.toString());
      if (e is PlatformException) {
        showError(context, e.message);
      }
      showError(context, e.message);
    }
    stopLoading();
  }

  double get returnTotal {
    double total = 0;
    _returnItems.forEach((item) {
      total += double.parse(item?.rowTotalInclTax ?? "0");
    });
    return double.parse(total.toStringAsFixed(3));
  }

  get refundAmount {
    double _previousGrandTotal =
        double.parse(_currentOrder?.baseGrandTotal ?? "0");
    return _previousGrandTotal - returnTotal;
  }

  double get _total {
    double _previousGrandTotal =
        double.parse(_currentOrder?.baseGrandTotal ?? "0");
    return _previousGrandTotal - returnTotal;
  }

  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "Return Confirm Screen");
    super.initState();
    var provider = Provider.of<OrderProvider>(context, listen: false);

    _returnItems = widget?.returnItems ?? [];
    _currentOrder = provider.currentOrder;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.white,
      appBar: headerBar(title: strings.INITIATE_RETURN, context: context),
      body: DismissKeyboard(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              child: Column(
                children: [
                  Flexible(
                    flex: 1,
                    child: ListView(
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(23),
                        vertical: ScreenUtil().setWidth(23),
                      ),
                      children: [
                        ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (_, index) {
                            Item item = _returnItems[index];

                            return ReturnListItem(item: item);
                          },
                          separatorBuilder: (_, index) {
                            return SizedBox(
                              height: ScreenUtil().setWidth(20),
                            );
                          },
                          itemCount: _returnItems.length,
                        ),
                        Container(
                          height: ScreenUtil().setWidth(120),
                          margin: EdgeInsets.symmetric(
                              vertical: ScreenUtil().setWidth(25)),
                          decoration: borderDecoration,
                          child: TextField(
                            onChanged: onChangeText,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.done,
                            minLines: 1,
                            maxLines: 5,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(22),
                              hintText: strings.REASON_TO_RETURN,
                              hintStyle: TextStyle(
                                fontSize: 12.0,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: ScreenUtil().setWidth(25)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              strings.CONFIRM_RETURNS,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Divider(),
                            SizedBox(height: ScreenUtil().setWidth(25)),
                            Text(strings.ITEMS_WITH_BRACKET +
                                "${_returnItems.length}" +
                                ")"),
                            TotalRow(
                              leftText: strings.PREVIOUS_ORDER_TOTAL,
                              leftTextStyle: textStyle.copyWith(
                                  fontWeight: FontWeight.w700),
                              rightText: strings.AED +
                                  " " +
                                  double.parse(
                                          _currentOrder?.baseGrandTotal ?? "0")
                                      .twoDecimal(),
                            ),
                            Divider(),
                            SizedBox(
                              height: ScreenUtil().setWidth(30),
                            ),
                            TotalRow(
                              leftText: strings.ITEMS_RETURNED,
                              rightText: "-" +
                                  strings.AED +
                                  ' ' +
                                  returnTotal.twoDecimal(),
                            ),
                            Divider(),
                          ],
                        ),
                        SizedBox(
                          height: ScreenUtil().setWidth(25),
                        ),
                        Visibility(
                          visible: _currentOrder.paymentType !=
                              PaymentType.cash_on_delivery,
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: new TextSpan(
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                height: 1.38,
                              ),
                              children: <TextSpan>[
                                new TextSpan(
                                    text: strings.THE_BALANCE_AMOUNT_OF +
                                        returnTotal.twoDecimal() +
                                        ' ' +
                                        strings.AED +
                                        ' ' +
                                        strings
                                            .WILL_BE_REFUNDED_TO_YOU_VIA_PAYMENT_GATEWAY),
                                new TextSpan(
                                  text: strings.PLEASE_WAIT_BUSINESS_DAYS,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  BottomContainer(onConfirm: _onConfirm, total: _total),
                ],
              ),
            ),
            Visibility(
              visible: _loading,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black12,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        new AlwaysStoppedAnimation<Color>(values.NESTO_GREEN),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    ));
  }
}

class TotalRow extends StatelessWidget {
  TotalRow({
    Key key,
    this.leftText,
    this.rightText,
    this.rightTextStyle,
    this.leftTextStyle,
  }) : super(key: key);

  final String leftText;
  final String rightText;
  final TextStyle leftTextStyle;
  final TextStyle rightTextStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: ScreenUtil().setWidth(5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            leftText ?? "--",
            style: leftTextStyle ?? textStyle,
          ),
          Text(rightText,
              style: rightTextStyle ??
                  textStyle.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class ReturnListItem extends StatelessWidget {
  const ReturnListItem({
    Key key,
    @required this.item,
  }) : super(key: key);

  final Item item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: ScreenUtil().setWidth(90),
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(17)),
      decoration: BoxDecoration(
          color: Color(0XFFF5F5F8), borderRadius: BorderRadius.circular(8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: ScreenUtil().setWidth(40),
            width: ScreenUtil().setWidth(40),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(8.84)),
            child: Center(
                child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                double.parse(item.qtyOrdered).toInt().toString(),
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black),
              ),
            )),
          ),
          SizedBox(width: ScreenUtil().setWidth(15)),
          Flexible(
            flex: 1,
            child: SizedBox(
              width: double.infinity,
              child: Text(
                item.name ?? "--",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 15.47,
                    height: 1.19,
                    fontWeight: FontWeight.w300,
                    color: Color(0XFF111A2C)),
              ),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(15)),
          SizedBox(
            width: ScreenUtil().setWidth(70),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                strings.AED +
                    ' ' +
                    double.parse(item.rowTotalInclTax ?? "0.00").twoDecimal(),
                style: TextStyle(
                    color: Color(0XFF00983D),
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BottomContainer extends StatelessWidget {
  const BottomContainer(
      {Key key, @required this.onConfirm, @required this.total})
      : super(key: key);

  final Function onConfirm;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setWidth(150),
      width: double.infinity,
      decoration: bottomContainerDecoration,
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(18.0)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                strings.AED + ' ' + total.twoDecimal(),
                style: TextStyle(fontSize: 22.09, fontWeight: FontWeight.w800),
              )
            ],
          ),
          Container(
            height: ScreenUtil().setWidth(60),
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
            decoration:
                BoxDecoration(borderRadius: BorderRadius.circular(8.84)),
            child: ElevatedButton(
              style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.84),
                  )),
                  backgroundColor:
                      MaterialStateProperty.all(values.NESTO_GREEN),
                  enableFeedback: true),
              onPressed: onConfirm,
              child: Text(
                strings.CONFIRM_RETURN,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 17),
              ),
            ),
          )
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
var borderDecoration = BoxDecoration(
  border: Border.all(width: 1.4, color: Colors.grey[700]),
  borderRadius: BorderRadius.circular(8.95),
);
var textStyle = TextStyle(
  fontSize: 15.47,
  fontWeight: FontWeight.w400,
  height: 1.19,
);
