import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductWidgetSpinner extends StatelessWidget {
  final Color color;

  ProductWidgetSpinner(this.color);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);

    return SizedBox(
        height: ScreenUtil().setWidth(17),
        width: ScreenUtil().setWidth(17),
        child: CircularProgressIndicator(
          strokeWidth: ScreenUtil().setWidth(3),
          valueColor: new AlwaysStoppedAnimation<Color>(color),
        ));
  }
}
