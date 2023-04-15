import 'dart:async';

import 'package:Nesto/utils/util.dart';
import 'package:Nesto/values.dart' as values;
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Nesto/strings.dart' as strings;

class ConnectionLostWidget extends StatefulWidget {
  @override
  _ConnectionLostWidgetState createState() => _ConnectionLostWidgetState();
}

class _ConnectionLostWidgetState extends State<ConnectionLostWidget> {
  bool showSpinner;

  @override
  void initState() {
    setState(() {
      showSpinner = false;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);

    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/no_internet.png",
                  height: ScreenUtil().setWidth(126),
                  width: ScreenUtil().setWidth(126),
                ),
                SizedBox(
                  height: ScreenUtil().setWidth(39),
                ),
                Text(
                  strings.CONNECTION_LOST,
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 28,
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: ScreenUtil().setWidth(values.SPACING_MARGIN_TEXT),
                ),
                Text(
                  strings.CHECK_YOUR_INTERNET_CONNECTION,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 17),
                ),
                SizedBox(
                  height: ScreenUtil().setWidth(30),
                ),
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      showSpinner = true;
                    });
                    Timer(Duration(seconds: 2), () async {
                      ConnectivityResult result;
                      final Connectivity _connectivity = Connectivity();
                      try {
                        result = await _connectivity.checkConnectivity();
                      } on PlatformException catch (e) {
                        setState(() {
                          showSpinner = false;
                        });
                        logNesto(e.toString());
                      }
                      if (result == ConnectivityResult.none) {
                        setState(() {
                          showSpinner = false;
                        });
                        showError(context, strings.NO_INTERNET_CONNECTION);
                      } else {
                        setState(() {
                          showSpinner = false;
                        });
                      }
                    });
                  },
                  child: Container(
                    width: ScreenUtil().setWidth(145),
                    height: ScreenUtil().setWidth(46),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: values.NESTO_GREEN, width: 3)),
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
        ),
        Visibility(
          visible: showSpinner,
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: CircularProgressIndicator(
                valueColor:
                    new AlwaysStoppedAnimation<Color>(values.NESTO_GREEN),
              ),
            ),
          ),
        )
      ],
    );
  }
}
