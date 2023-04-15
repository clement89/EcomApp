import 'package:Nesto/screens/splash_screen.dart';
import 'package:Nesto/values.dart' as values;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:Nesto/strings.dart' as strings;

class FailedToLoadWidget extends StatefulWidget {
  final String text;
  final Function toDo;

  const FailedToLoadWidget({Key key, @required this.text, this.toDo})
      : super(key: key);

  @override
  _FailedToLoadWidgetState createState() => _FailedToLoadWidgetState();
}

class _FailedToLoadWidgetState extends State<FailedToLoadWidget> {
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
              strings.WHOOPS,
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 28,
                  fontWeight: FontWeight.w700),
            ),
            SizedBox(
              height: ScreenUtil().setWidth(values.SPACING_MARGIN_TEXT),
            ),
            Text(
              widget.text,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 17),
            ),
            SizedBox(
              height: ScreenUtil().setWidth(30),
            ),
            GestureDetector(
              onTap:  widget.toDo,
              child: Container(
                width: ScreenUtil().setWidth(145),
                height: ScreenUtil().setWidth(46),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: values.NESTO_GREEN, width: 3)),
                child: Center(
                  child: Text(
                    strings.TRY_AGAIN,
                    style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 16),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
