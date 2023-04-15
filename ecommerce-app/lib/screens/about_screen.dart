import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/widgets/headers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:Nesto/strings.dart' as strings;

import '../values.dart' as values;

class AboutScreen extends StatefulWidget {
  static String routeName = '/about';
  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "About Screen");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: headerBar(title: strings.ABOUT_NESTO, context: context),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
                left: ScreenUtil().setWidth(39.0),
                right: ScreenUtil().setWidth(39.0),
                bottom: ScreenUtil().setHeight(70.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //nesto logo
                Center(
                  child: Container(
                    margin: EdgeInsets.only(top: ScreenUtil().setHeight(72.0)),
                    // color: Colors.amber[100],
                    height: ScreenUtil().setWidth(150.0),
                    width: ScreenUtil().setWidth(150.0),
                    child: FittedBox(
                      fit: BoxFit.fill,
                      child:
                          SvgPicture.asset("assets/svg/nesto_logo_square.svg"),
                    ),
                  ),
                ),
                SizedBox(height: ScreenUtil().setHeight(83.0)),
                titleColumn(title: strings.WHO_WE_ARE),
                SizedBox(height: ScreenUtil().setHeight(15.0)),
                subText(strings.about_nesto_main_text),
                SizedBox(height: ScreenUtil().setHeight(34.0)),
                subText(strings.about_nesto_second_text),
                SizedBox(height: ScreenUtil().setHeight(45.0)),
                titleColumn(title: strings.OUR_MISSION),
                SizedBox(height: ScreenUtil().setHeight(34.0)),
                subText(strings.OUR_MISSION_TEXT),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container subText(String text) {
    return Container(
      child: Text(
        text,
        style: TextStyle(
            fontSize: 16,
            height: 1.19,
            fontWeight: FontWeight.w300,
            color: Color(0XFF000000)),
      ),
    );
  }

  Widget titleColumn({String title}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: 24.0,
              height: 1.19,
              fontWeight: FontWeight.w700,
              color: Colors.black),
        ),
        SizedBox(
          height: ScreenUtil().setHeight(7.0),
        ),
        Container(
          height: ScreenUtil().setHeight(5.0),
          width: ScreenUtil().setWidth(77.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.84),
              color: values.NESTO_GREEN),
        )
      ],
    );
  }
}
