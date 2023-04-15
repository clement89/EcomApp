import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/strings.dart' as strings;

class ApiFailedWidget extends StatelessWidget {
  const ApiFailedWidget({
    Key key,
    @required this.onPressRetry,
    this.mainText,
    this.subText,
  }) : super(key: key);

  final Function onPressRetry;
  final String mainText;
  final String subText;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          "assets/svg/something_went_wrong.svg",
          height: ScreenUtil().setWidth(126),
          width: ScreenUtil().setWidth(126),
        ),
        SizedBox(
          height: ScreenUtil().setWidth(39),
        ),
        Text(
          mainText ?? "Something went wrong",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.black87, fontSize: 28, fontWeight: FontWeight.w700),
        ),
        SizedBox(
          height: ScreenUtil().setWidth(values.SPACING_MARGIN_TEXT),
        ),
        Text(
          subText ?? "Please try again",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54, fontSize: 17),
        ),
        SizedBox(
          height: ScreenUtil().setWidth(30),
        ),
        GestureDetector(
          onTap: onPressRetry,
          child: Container(
            width: ScreenUtil().setWidth(145),
            height: ScreenUtil().setWidth(46),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: values.NESTO_GREEN, width: 3)),
            child: Center(
              child: Text(
                "TAP TO RETRY",
                style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 16),
              ),
            ),
          ),
        )
      ],
    );
  }
}
