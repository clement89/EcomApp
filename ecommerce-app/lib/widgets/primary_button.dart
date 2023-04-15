import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Nesto/values.dart' as values;

class PrimaryButton extends StatelessWidget {
  final String label;
  final Function onPressed;
  const PrimaryButton({
    Key key,
    @required this.label,
    @required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: ScreenUtil().setWidth(20),
          right: ScreenUtil().setWidth(20),
          bottom: ScreenUtil().setHeight(10),
          top: ScreenUtil().setHeight(10)),
      child: MaterialButton(
        height: ScreenUtil().setHeight(62),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.84)),
        color: values.NESTO_GREEN,
        onPressed: onPressed,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
                color: Colors.white,
                fontSize: 17.67,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
