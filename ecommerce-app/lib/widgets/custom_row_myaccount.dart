import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Function onPress;
  final Widget svgIcon;

  const CustomRow({Key key, this.text, this.icon, this.onPress, this.svgIcon})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: ScreenUtil().setHeight(23.0),
        ),
        color: Colors.transparent,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            svgIcon ??
                Icon(
                  icon,
                  color: Colors.green,
                  size: 18,
                ),
            SizedBox(
              width: ScreenUtil().setWidth(15),
            ),
            Text(
              text,
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(child: SizedBox()),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.black26,
              size: 15,
            ),
          ],
        ),
      ),
    );
  }
}
