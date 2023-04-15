import 'package:Nesto/values.dart' as values;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PaginationLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    //Screen Util Init
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);

    return Container(
      padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
      child: Transform.scale(
        scale: 0.5,
        child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(values.NESTO_GREEN)
        ),
      ),
    );
  }
}
