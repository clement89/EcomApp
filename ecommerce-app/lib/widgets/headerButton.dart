import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';

Widget headerButton({
  IconData icon,
  Color bgColor,
  Color borderColor,
  double iconSize,
  Color iconColor,
  Function onPress,
}) {
  return GestureDetector(
    onTap: onPress,
    child: Container(
      width: ScreenUtil().setWidth(44.19),
      height: ScreenUtil().setHeight(44.19),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      child: Icon(
        icon,
        size: iconSize,
        color: iconColor,
      ),
    ),
  );
}
