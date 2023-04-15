import 'package:Nesto/providers/auth_provider.dart';
import 'package:Nesto/providers/orders_provider.dart';
import 'package:Nesto/screens/delivery_rating.dart';
import 'package:Nesto/service_locator.dart';
import 'package:Nesto/services/navigation_service.dart';
import 'package:Nesto/utils/util.dart';
import 'package:Nesto/widgets/product_widget_spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:provider/provider.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/strings.dart' as strings;

void showPreviousOrderRating(orderId, salesIncrementalId) {
  final NavigationService _navigation = locator.get<NavigationService>();

  var authProvider = Provider.of<AuthProvider>(
      _navigation.navigatorKey.currentContext,
      listen: false);
  var ordersProvider = Provider.of<OrderProvider>(
      _navigation.navigatorKey.currentContext,
      listen: false);

  bool _continueButtonLoading = false;

  if (!isAuthTokenValid()) {
    return;
  }

  Future.delayed(Duration.zero, () {
    int rating = 0;
    return showModalBottomSheet(
        context: _navigation.navigatorKey.currentContext,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        )),
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Container(
                height: ScreenUtil().setWidth(420),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: ScreenUtil()
                            .setWidth(values.SPACING_MARGIN_STANDARD),
                      ),
                      Container(
                        width: ScreenUtil().setWidth(127),
                        height: ScreenUtil().setWidth(3),
                        color: Color(0xFFC4C4C4),
                      ),
                      SizedBox(
                        height: ScreenUtil().setWidth(36),
                      ),
                      Text(
                        '#' +
                            (salesIncrementalId == null
                                ? "--"
                                : salesIncrementalId),
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        strings.RATE_YOUR_PREVIOUS_DELIVERY,
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 24,
                            fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: ScreenUtil().setWidth(27),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          right: 30,
                          left: 30,
                        ),
                        child: Text(
                          strings.ORDER_RATING_TEXT,
                          style: TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                              fontWeight: FontWeight.normal,
                              letterSpacing: -0.08),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        height: ScreenUtil().setWidth(48),
                      ),
                      StarRating(
                        onChanged: (index) {
                          setState(() {
                            rating = index;
                          });
                        },
                        value: rating,
                        filledStar: Icons.star_rounded,
                        unfilledStar: Icons.star_border_rounded,
                      ),
                      SizedBox(
                        height: ScreenUtil().setWidth(48),
                      ),
                      Container(
                        width: ScreenUtil().setWidth(160),
                        height: ScreenUtil().setHeight(40),
                        child: TextButton(
                            onPressed: ()async{
                              if(authProvider.magentoUser == null){
                                setState(() {
                                  _continueButtonLoading = true;
                                });
                                await authProvider.fetchMagentoUser().then((value){
                                  setState(() {
                                    _continueButtonLoading = false;
                                  });
                                });
                                Navigator.of(_navigation.navigatorKey.currentContext).pop();
                                int customerId = authProvider.magentoUser.id;
                                ordersProvider.updateDeliveryRating(orderId, customerId, rating);
                              }else if(authProvider.magentoUser != null){
                                Navigator.of(_navigation.navigatorKey.currentContext).pop();
                                int customerId = authProvider.magentoUser.id;
                                ordersProvider.updateDeliveryRating(orderId, customerId, rating);
                              }
                            },
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                        (Set<MaterialState> states) {
                                  return Theme.of(context).primaryColor;
                                }),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                )),
                            child: Center(
                                child: _continueButtonLoading?ProductWidgetSpinner(Colors.white):Text(strings.CONTINUE,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        letterSpacing: 0.2)))),
                      )
                    ],
                  ),
                ));
          });
        });
  });
}
