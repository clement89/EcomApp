import 'package:Nesto/strings.dart';
import 'package:Nesto/utils/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RateMyAppBottomSheetWidget extends StatefulWidget {
  @override
  _RateMyAppBottomSheetWidgetState createState() =>
      _RateMyAppBottomSheetWidgetState();
}

class _RateMyAppBottomSheetWidgetState
    extends State<RateMyAppBottomSheetWidget> {
  @override
  Widget build(BuildContext context) {
    return new Container(
        height: ScreenUtil().setHeight(430.0),
        width: ScreenUtil().screenWidth,
        decoration: new BoxDecoration(
            color: Colors.white,
            borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(20.0),
                topRight: const Radius.circular(20.0))),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: ScreenUtil().setHeight(15.0)),
              Container(
                width: ScreenUtil().setWidth(150.0),
                height: 2,
                decoration: BoxDecoration(
                    color: Color(0xFFC4C4C4),
                    borderRadius: BorderRadius.circular(1.5)),
              ),
              SizedBox(height: ScreenUtil().setHeight(20.0)),
              Container(
                width: ScreenUtil().setWidth(140.0),
                height: ScreenUtil().setWidth(140.0),
                child: Lottie.asset('assets/animations/rate_us.json',
                    repeat: false),
              ),
              SizedBox(height: ScreenUtil().setHeight(25.0)),
              Container(
                width: ScreenUtil().setWidth(330.0),
                height: ScreenUtil().setHeight(35.0),
                child: Center(
                    child: Text(
                  RATE_APP_TITLE,
                  style: TextStyle(
                      fontFamily: 'SFProDisplay',
                      color: Color(0xFF252529),
                      fontSize: 24.0,
                      fontWeight: FontWeight.w600),
                )),
              ),
              SizedBox(height: ScreenUtil().setHeight(15.0)),
              Container(
                width: ScreenUtil().setWidth(200.0),
                height: ScreenUtil().setHeight(25.0),
                child: Center(
                    child: Text(
                  RATE_APP_SUB_TITLE,
                  style: TextStyle(
                      fontFamily: 'SFProDisplay',
                      color: Color(0xFF252529),
                      fontSize: 13.0,
                      fontWeight: FontWeight.w400),
                )),
              ),
              SizedBox(height: ScreenUtil().setHeight(45.0)),
              Container(
                width: ScreenUtil().setWidth(350.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      child: Container(
                        width: ScreenUtil().setWidth(150.0),
                        height: ScreenUtil().setHeight(40.0),
                        color: Colors.transparent,
                        child: Center(
                            child: Text(
                          RATE_APP_LATER_BUTTON,
                          style: TextStyle(
                              fontFamily: 'SFProDisplay',
                              color: Color(0xFF00983D),
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400),
                        )),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    Container(
                      width: ScreenUtil().setWidth(150.0),
                      height: ScreenUtil().setHeight(40.0),
                      child: RaisedButton(
                          color: Color(0xFF00883D),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7.0)),
                          child: Center(
                              child: Text(
                            RATE_APP_SURE,
                            style: TextStyle(
                                fontFamily: 'SFProDisplay',
                                color: Colors.white,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400),
                          )),
                          onPressed: () async {
                            openAppStoreOrPlaystore();
                            SharedPreferences sharedPreferences =
                                await SharedPreferences.getInstance();
                            await sharedPreferences.setBool(
                                "alreadyRated", true);
                            Navigator.pop(context);
                          }),
                    ),
                  ],
                ),
              ),
              SizedBox(height: ScreenUtil().setHeight(35.0)),
            ]));
  }
}
