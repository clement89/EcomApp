import 'package:Nesto/values.dart' as values;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:Nesto/strings.dart' as strings;

class PaymentFailedWidget extends StatefulWidget {
  @override
  _PaymentFailedWidgetState createState() => _PaymentFailedWidgetState();
}

class _PaymentFailedWidgetState extends State<PaymentFailedWidget> {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              strings.PAYMENT_FAILED,
              style: TextStyle(
                  color: Color(0xFF111A2C),
                  fontSize: 21,
                  fontWeight: FontWeight.w700),
            ),
            SizedBox(
              height: ScreenUtil().setHeight(39),
            ),
            SizedBox(
              height: ScreenUtil().setWidth(283),
              width: ScreenUtil().setWidth(283),
              child: Lottie.asset('assets/animations/order_cancelled.json'),
            ),
            SizedBox(
              height: ScreenUtil().setWidth(39),
            ),
            Text(
              strings.ORDER_CANCELLED,
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 28,
                  fontWeight: FontWeight.w700),
            ),
            SizedBox(
              height: ScreenUtil().setWidth(values.SPACING_MARGIN_TEXT),
            ),
            Text(
              strings.SORRY_WE_COULDNT_PLACE_ORDER,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 17),
            ),
          ],
        ),
      ),
    );
  }
}
