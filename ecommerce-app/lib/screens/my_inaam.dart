import 'package:Nesto/providers/auth_provider.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/widgets/connectivity_widget.dart';
import 'package:Nesto/widgets/headers.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:provider/provider.dart';
import 'package:Nesto/strings.dart' as strings;
import 'package:Nesto/extensions/number_extension.dart';

class MyInaam extends StatefulWidget {
  static String routeName = "/my_inaam_page";
  @override
  _MyInaamState createState() => _MyInaamState();
}

class _MyInaamState extends State<MyInaam> {
  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "My Inaam Screen");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);
    var authProvider = Provider.of<AuthProvider>(context);
    return SafeArea(
      child: Scaffold(
        appBar: headerBar(title: strings.MY_INAAM, context: context),
        backgroundColor: Colors.white,
        body: ConnectivityWidget(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                  left: ScreenUtil().setWidth(20.0),
                  right: ScreenUtil().setWidth(20.0),
                  bottom: ScreenUtil().setHeight(30.0)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: ScreenUtil().setHeight(38),
                  ),
                  Container(
                    width: ScreenUtil().screenWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          strings.INAAM_ID,
                          style: TextStyle(
                            color: Color(0xFF000000),
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(15),
                  ),
                  BarcodeWidget(
                    barcode: Barcode.code39(),
                    // Barcode type and settings
                    data: authProvider.inaamCode,
                    // Content
                    width: ScreenUtil().setWidth(325.0),
                    height: ScreenUtil().setHeight(120.0),
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(50),
                  ),
                  Container(
                    width: ScreenUtil().screenWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          strings.CURRENT_POINTS,
                          style: TextStyle(
                            color: Color(0xFF000000),
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(25),
                  ),
                  Container(
                    width: ScreenUtil().screenWidth,
                    height: ScreenUtil().setHeight(60),
                    decoration: BoxDecoration(
                        color: Color(0xFFFBFBFB),
                        border:
                            Border.all(color: Color(0xFFF5F5F8), width: 1.0),
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: ScreenUtil().setWidth(20.0)),
                          child: Text(
                            authProvider.inaamPoints.twoDecimal() +
                                strings.INAAM_POINTS,
                            style: TextStyle(
                              color: Color(0xFF000000),
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(50),
                  ),
                  Container(
                    width: ScreenUtil().screenWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          strings.TOTAL_POINTS_EARNED,
                          style: TextStyle(
                            color: Color(0xFF000000),
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(25),
                  ),
                  Container(
                    width: ScreenUtil().screenWidth,
                    height: ScreenUtil().setHeight(60),
                    decoration: BoxDecoration(
                        color: Color(0xFFFBFBFB),
                        border:
                            Border.all(color: Color(0xFFF5F5F8), width: 1.0),
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: ScreenUtil().setWidth(20.0)),
                          child: Text(
                            authProvider.inaamPointsLifeTime.twoDecimal() +
                                strings.INAAM_POINTS,
                            style: TextStyle(
                              color: Color(0xFF000000),
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
