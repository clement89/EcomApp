import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Nesto/values.dart' as values;

class CustomDialogWidget extends StatelessWidget {
  const CustomDialogWidget(
      {Key key,
      this.context,
      this.title,
      this.description,
      this.positiveText,
      this.negativeText,
      this.positiveTextColor,
      this.onPressed,
      this.onNoPressed})
      : super(key: key);
  final BuildContext context;
  final String title;
  final String description;
  final String positiveText;
  final String negativeText;
  final Color positiveTextColor;
  final Function onPressed;
  final Function onNoPressed;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      contentPadding: EdgeInsets.only(
          top: ScreenUtil().setWidth(8),
          left: ScreenUtil().setWidth(24),
          right: ScreenUtil().setWidth(24),
          bottom: ScreenUtil().setWidth(12)),
      titlePadding: EdgeInsets.only(
        top: ScreenUtil().setWidth(24),
        left: ScreenUtil().setWidth(24),
        right: ScreenUtil().setWidth(24),
      ),
      title: Text(title,
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800)),
      content: Text(
        description,
        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w400),
      ),
      actions: <Widget>[
        Align(
          alignment: Alignment.bottomLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Visibility(
                visible: negativeText != null && negativeText != '',
                child: TextButton(
                    child: Text(
                      negativeText,
                      style: TextStyle(
                          color: values.NESTO_GREEN,
                          fontWeight: FontWeight.w600),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                      if (onNoPressed != null) {
                        onNoPressed();
                      }
                    }),
              ),
              TextButton(
                  child: Text(
                    positiveText,
                    style: TextStyle(
                        color: positiveTextColor, fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                    onPressed();
                  }),
            ],
          ),
        ),
      ],
    );
  }
}
