
import 'package:Nesto/strings.dart' as strings;
import 'package:Nesto/values.dart' as values;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class WeAreNotHereYetWidget extends StatefulWidget {
  @override
  _WeAreNotHereYetWidgetState createState() => _WeAreNotHereYetWidgetState();
}

class _WeAreNotHereYetWidgetState extends State<WeAreNotHereYetWidget> {
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
            SizedBox(
              height: ScreenUtil().setWidth(299),
              width: ScreenUtil().setWidth(299),
              child: Lottie.asset('assets/animations/not_servicable.json'),
            ),
            Text(
              strings.SERVICE_AREA_MESSAGE,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(0xFF494B4B),
                  fontWeight: FontWeight.w600,
                  fontSize: 20),
            ),
            SizedBox(
              height: ScreenUtil().setWidth(values.SPACING_MARGIN_TEXT),
            ),
            Text(
              strings.COMING_TO_YOUR_LOCATION_SOON,
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF494B4B), fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
