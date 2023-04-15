import 'package:Nesto/extensions/number_extension.dart';
import 'package:Nesto/providers/orders_provider.dart';
import 'package:Nesto/screens/return_confirm_screen.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/utils/util.dart';
import 'package:Nesto/widgets/headers.dart';
import 'package:flutter/material.dart';
import 'package:Nesto/models/order_details.dart' as OD;
import 'package:flutter_screenutil/screenutil.dart';
import 'package:provider/provider.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/strings.dart' as strings;

class ReturnOrder extends StatefulWidget {
  static String routeName = "return_order_screen";
  const ReturnOrder({Key key}) : super(key: key);

  @override
  _ReturnOrderState createState() => _ReturnOrderState();
}

class _ReturnOrderState extends State<ReturnOrder> {
  List<ReturnProduct> _returnList;

  _toggleCheck(ReturnProduct selectedItem) {
    for (var item in _returnList) {
      if (selectedItem.product.sku == item.product.sku) {
        setState(() {
          item.isSelected = !item.isSelected;
        });
        break;
      }
    }
  }

  _unselectItems(expiredItemIds) {
    // print("================>");
    // print(expiredItemIds);
    // print(expiredItemIds[0].runtimeType);
    // print("<================");

    for (var item in _returnList) {
      if (expiredItemIds.contains(item.product.itemId)) {
        setState(() {
          item.isSelected = false;
        });
      }
    }
  }

  _initiateReturn() async {
    if (returnItems.length < 1) {
      showError(context, strings.PLEASE_SELECT_ATLEAST_ONE_ITEM);
      return;
    }

    final errResponse = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return ReturnConfirmScreen(returnItems: returnItems);
        },
      ),
    );

    print("==============>");
    print("RESPONSE: $errResponse");
    print("<==============");

    if ((errResponse["item_expiry"] ?? false) == true) {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              height: ScreenUtil().setWidth(350),
              color: Color(0xFF737373),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(15),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.84),
                    topRight: Radius.circular(8.84),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        margin: EdgeInsets.only(
                            top: ScreenUtil().setHeight(18.0),
                            bottom: ScreenUtil().setHeight(24.0)),
                        height: ScreenUtil().setHeight(4),
                        width: ScreenUtil().setWidth(127),
                        decoration: BoxDecoration(
                          color: Color(0XFFC4C4C4),
                          borderRadius: BorderRadius.circular(8.84),
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        strings.RETURN_HAS_EXPIRED_FOR_SOME_SELECTED_ITEMS,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.black87,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    SizedBox(
                      height: ScreenUtil().setWidth(18),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          errResponse["message"] ?? "--",
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red[400],
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: ScreenUtil().setWidth(60),
                      padding:
                          EdgeInsets.only(bottom: ScreenUtil().setWidth(5)),
                      color: Colors.transparent,
                      child: Center(
                        child: Container(
                          height: ScreenUtil().setWidth(50),
                          width: ScreenUtil().setWidth(160),
                          margin: EdgeInsets.symmetric(
                              horizontal: ScreenUtil().setWidth(23)),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.84)),
                          child: ElevatedButton(
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.84),
                                )),
                                backgroundColor: MaterialStateProperty.all(
                                    values.NESTO_GREEN),
                                enableFeedback: true),
                            onPressed: () {
                              Navigator.pop(context);
                              _unselectItems(errResponse["expired_item_ids"]);
                            },
                            child: Text(
                              strings.GO_BACK,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          });
    }
  }

  List<OD.Item> get returnItems {
    var selectedItems = _returnList.where((item) => item.isSelected).toList();
    var itemsToBeReturned = selectedItems.map((item) => item.product).toList();
    return itemsToBeReturned;
  }

  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "Return Order Screen");
    super.initState();
    var provider = Provider.of<OrderProvider>(context, listen: false);
    _returnList = provider.currentOrder.items
        .map((item) => ReturnProduct(product: item, isSelected: false))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: headerBar(title: strings.SELECT_ITEMS, context: context),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(18)),
          // color: Colors.green[100],
          child: Column(
            children: [
              Flexible(
                flex: 3,
                child: Container(
                  // color: Colors.orange,
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(
                      vertical: ScreenUtil().setWidth(23),
                    ),
                    itemBuilder: (_, index) {
                      ReturnProduct product = _returnList[index];
                      return ReturnItem(
                        product: product,
                        toggleCheck: _toggleCheck,
                      );
                    },
                    separatorBuilder: (_, index) => SizedBox(
                      height: 20,
                    ),
                    itemCount: _returnList.length,
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: Container(
                  width: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.WHAT_DO_YOU_WANT_TO_DO,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: ScreenUtil().setWidth(8)),
                      Divider(height: 0),
                      Flexible(
                        flex: 1,
                        child: Center(
                          child: InitiateReturn(
                              returnItems: returnItems,
                              onPressed: _initiateReturn),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InitiateReturn extends StatelessWidget {
  const InitiateReturn({
    Key key,
    @required this.returnItems,
    @required this.onPressed,
  }) : super(key: key);

  final List<OD.Item> returnItems;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: ScreenUtil().setWidth(75),
        width: ScreenUtil().setWidth(312),
        padding: EdgeInsets.symmetric(
            vertical: ScreenUtil().setWidth(15),
            horizontal: ScreenUtil().setWidth(18)),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.84),
            color: Color(0XFFFFDED1)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.I_WANT_TO,
                  style: TextStyle(
                    color: Color(0XFF757D85),
                    fontSize: 11,
                  ),
                ),
                Text(
                  strings.RETURN +
                      returnItems.length.toString() +
                      " ${returnItems.length > 1 ? strings.ITEMS : strings.ITEM}",
                  style: TextStyle(
                    color: Color(0XFF111A2C),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class ReturnItem extends StatelessWidget {
  const ReturnItem({
    Key key,
    @required this.product,
    @required this.toggleCheck,
  }) : super(key: key);

  final ReturnProduct product;
  final Function toggleCheck;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => toggleCheck(product),
      child: Container(
        height: ScreenUtil().setWidth(90),
        width: double.infinity,
        // color: Colors.blue,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomCheckBox(
              isSelected: product.isSelected,
              // toggleCheck: () => toggleCheck(product),
            ),
            SizedBox(width: ScreenUtil().setWidth(25)),
            Flexible(
              flex: 1,
              child: Container(
                height: double.infinity,
                width: double.infinity,
                padding:
                    EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(17)),
                decoration: BoxDecoration(
                    color: Color(0XFFF5F5F8),
                    borderRadius: BorderRadius.circular(8)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: ScreenUtil().setWidth(40),
                      width: ScreenUtil().setWidth(40),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.84)),
                      child: Center(
                          child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          double.parse(product.product.qtyOrdered)
                              .toInt()
                              .toString(),
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
                          product.product.name ?? "--",
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
                              double.parse(product?.product?.rowTotalInclTax ??
                                      "0.00")
                                  .twoDecimal(),
                          style: TextStyle(
                              color: Color(0XFF00983D),
                              fontSize: 15.5,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CustomCheckBox extends StatelessWidget {
  CustomCheckBox({
    @required this.isSelected,
    // @required this.toggleCheck,
  });

  final bool isSelected;
  // final Function toggleCheck;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      curve: Curves.easeInOutCirc,
      height: ScreenUtil().setWidth(25),
      width: ScreenUtil().setWidth(25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: isSelected ? values.NESTO_GREEN : Colors.transparent,
        border: isSelected ? null : Border.all(color: Colors.grey, width: 1.5),
      ),
      child: isSelected
          ? Icon(
              Icons.check,
              size: 18,
              color: Colors.white,
            )
          : null,
    );
  }
}

class ReturnProduct {
  ReturnProduct({this.product, this.isSelected});
  OD.Item product;
  bool isSelected = false;
}
