import 'package:Nesto/values.dart' as values;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:Nesto/strings.dart' as strings;

class NoProductsFoundWidget extends StatefulWidget {
  @override
  _NoProductsFoundWidgetState createState() => _NoProductsFoundWidgetState();
}

class _NoProductsFoundWidgetState extends State<NoProductsFoundWidget> {
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
              "assets/svg/something_went_wrong.svg",
              height: ScreenUtil().setWidth(121),
              width: ScreenUtil().setWidth(121),
            ),
            SizedBox(
              height: ScreenUtil().setWidth(39),
            ),
            Text(
              strings.SORRY,
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 28,
                  fontWeight: FontWeight.w700),
            ),
            SizedBox(
              height: ScreenUtil().setWidth(values.SPACING_MARGIN_TEXT),
            ),
            Text(
              strings.NO_PRODUCT_FOUND,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 17),
            ),
          ],
        ),
      ),
    );
  }
}
