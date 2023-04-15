import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:Nesto/strings.dart' as strings;

class NoAddressesWidget extends StatefulWidget {
  @override
  _NoAddressesWidgetState createState() => _NoAddressesWidgetState();
}

class _NoAddressesWidgetState extends State<NoAddressesWidget> {
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
              "assets/images/no_addresses.png",
              height: ScreenUtil().setWidth(121),
              width: ScreenUtil().setWidth(121),
            ),
            SizedBox(
              height: ScreenUtil().setWidth(30),
            ),
            Text(
              strings.NO_ADDRESS_FOUND,
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
              child: Center(
                child: Text(
                  strings.YOUR_ADDRESS_WILL,
                  style: TextStyle(
                      fontFamily: 'assets/fonts/sf_pro_display.ttf',
                      color: Colors.grey,
                      fontSize: 17,
                      fontWeight: FontWeight.w400),
                ),
              ),
            ),
            SizedBox(
              height: ScreenUtil().setWidth(3),
            ),
            Container(
              width: ScreenUtil().setWidth(150),
              child: Center(
                child: Text(
                  strings.APPEAR_HEAR,
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
