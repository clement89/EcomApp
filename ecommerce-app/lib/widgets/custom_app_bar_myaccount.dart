import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Nesto/strings.dart' as strings;
class CustomAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: ScreenUtil().setHeight(35),
          width: ScreenUtil().setWidth(35),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black26,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 15,
            ),
          ),
        ),
        Expanded(child: SizedBox()),
        Text(
          strings.MY_ACCOUNT,
          style: TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(child: SizedBox()),
        Container(
          height: ScreenUtil().setHeight(35),
          width: ScreenUtil().setWidth(35),
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Icon(
              Icons.search,
              color: Colors.black,
              size: 20,
            ),
          ),
        )
      ],
    );
  }
}
