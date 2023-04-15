import 'package:Nesto/screens/filter_scren.dart';
import 'package:Nesto/values.dart' as values;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Nesto/strings.dart' as strings;


Widget fab({@required BuildContext context}) {
  return GestureDetector(
    onTap: () {
      Navigator.pushNamed(context, FilterScreen.routeName);
    },
    child: Container(
      decoration: BoxDecoration(
          color: values.NESTO_GREEN, borderRadius: BorderRadius.circular(30.0)),
      height: ScreenUtil().setHeight(47.0),
      width: ScreenUtil().setWidth(135.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            strings.FILTER,
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
          ),
          SizedBox(
            width: ScreenUtil().setWidth(3.0),
          ),
          Icon(
            Icons.filter_list,
            color: Colors.white,
          )
        ],
      ),
    ),
  );
}
