import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:Nesto/strings.dart' as strings;

class NoNotificationWidget extends StatefulWidget {
  @override
  _NoNotificationWidgetState createState() => _NoNotificationWidgetState();
}

class _NoNotificationWidgetState extends State<NoNotificationWidget> {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: ScreenUtil().setWidth(180),
            ),
            Image.asset(
              "assets/images/no_notifications.png",
              height: ScreenUtil().setWidth(121),
              width: ScreenUtil().setWidth(121),
            ),
            SizedBox(
              height: ScreenUtil().setWidth(30),
            ),
            Text(
              strings.NO_NOTIFICATION,
              style: TextStyle(
                  fontFamily: 'assets/fonts/sf_pro_display.ttf',
                  color: Color(0xFF000000),
                  fontSize: 28,
                  fontWeight: FontWeight.w700),
            ),
            SizedBox(
              height: ScreenUtil().setWidth(39),
            ),
            Container(
              width: ScreenUtil().setWidth(220),
              height: ScreenUtil().setHeight(25),
              child: Center(
                child: Text(
                  strings.YOUR_NEW_NOTIFICATION+" ",
                  style: TextStyle(
                      fontFamily: 'assets/fonts/sf_pro_display.ttf',
                      color: Colors.grey,
                      fontSize: 17,
                      fontWeight: FontWeight.w400),
                ),
              ),
            ),
            SizedBox(
              height: ScreenUtil().setWidth(1),
            ),
            Container(
              width: ScreenUtil().setWidth(150),
              child: Center(
                child: Text(
                  strings.WILL_APPEAR_HERE,
                  style: TextStyle(
                      fontFamily: 'assets/fonts/sf_pro_display.ttf',
                      color: Colors.grey,
                      fontSize: 17,
                      fontWeight: FontWeight.w400),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
