import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:Nesto/strings.dart' as strings;

class NoCompletedOrdersWidget extends StatefulWidget {
  @override
  NoCompletedOrdersWidgetState createState() => NoCompletedOrdersWidgetState();
}

class NoCompletedOrdersWidgetState extends State<NoCompletedOrdersWidget> {
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
            SvgPicture.asset(
              "assets/svg/no_orders.svg",
              height: ScreenUtil().setWidth(121),
              width: ScreenUtil().setWidth(121),
            ),
            SizedBox(
              height: ScreenUtil().setWidth(39),
            ),
            Text(
              strings.NO_COMPLETED_ORDERS_YET,
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 21,
                  fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
