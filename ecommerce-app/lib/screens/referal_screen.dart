import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/widgets/headers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:share/share.dart';
import 'package:Nesto/strings.dart' as strings;

class ReferralScreen extends StatelessWidget {
  static String routeName = '/referral_screen';
  @override
  Widget build(BuildContext context) {
    firebaseAnalytics.screenView(screenName: "Referral Screen");
    return SafeArea(
      child: Scaffold(
          appBar: headerBar(title: strings.REFER, context: context),
          body: Container(
            height: double.infinity,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(children: [
                            Container(
                              margin: EdgeInsets.only(
                                  top: ScreenUtil().setHeight(10.0)),
                              // color: Colors.amber[100],
                              height: ScreenUtil().setHeight(150.0),
                              width: ScreenUtil().setWidth(150.0),
                              child: FittedBox(
                                fit: BoxFit.fitHeight,
                                child: Lottie.asset(
                                    'assets/animations/referal_gift.json'),
                              ),
                            ),
                            Text(
                              strings.REFER_TO_YOUR_FRIEND,
                              style: TextStyle(
                                  fontSize: 24.0,
                                  height: 1.19,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: ScreenUtil().setWidth(80),
                                  vertical: ScreenUtil().setHeight(17)),
                              child: Text(
                                strings.INVITE_YOUR_FRIENDS_AND_SHOP_TOGETHER,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.black),
                              ),
                            ),
                          ]),
                        ),
                        Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: ScreenUtil().setWidth(20),
                                vertical: ScreenUtil().setHeight(25)),
                            child: ClipboardWidget()),
                      ]),
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          left: ScreenUtil().setWidth(20),
                          right: ScreenUtil().setWidth(20),
                          bottom: ScreenUtil().setHeight(40),
                          top: ScreenUtil().setHeight(36)),
                      child: MaterialButton(
                        height: ScreenUtil().setHeight(62),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.84)),
                        color: values.NESTO_GREEN,
                        onPressed: () {
                          Share.share(strings.SHARE_LONG_TEXT);
                        },
                        child: Center(
                          child: Text(
                            strings.SHARE_YOUR_LINK,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 17.67,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),
    );
  }
}

class ClipboardWidget extends StatefulWidget {
  @override
  _ClipboardWidgetState createState() => _ClipboardWidgetState();
}

class _ClipboardWidgetState extends State<ClipboardWidget> {
  bool isPressed = false;
  bool isCopied = false;
  final snackBar = SnackBar(content: Text(strings.COPIED_TO_CLIPBOARD));

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: ScreenUtil().setWidth(values.SPACING_MARGIN_STANDARD),
        ),
        GestureDetector(
          onTap: () {
            Clipboard.setData(
                new ClipboardData(text: strings.SHARE_CLIPBOARD_TEXT));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            setState(() {
              isCopied = true;
            });
          },
          onTapDown: (TapDownDetails details) {
            setState(() {
              isPressed = true;
            });
          },
          onTapUp: (TapUpDetails details) {
            setState(() {
              isPressed = false;
            });
          },
          onTapCancel: () {
            setState(() {
              isPressed = false;
            });
          },
          child: Container(
            height: ScreenUtil().setWidth(60),
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(10)),
            decoration: BoxDecoration(
              color: isPressed ? Colors.grey[200] : Color(0xFFF5F5F8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    strings.GO_NESTO_SHOP,
                    style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                  isCopied
                      ? Icon(
                          Icons.done,
                          color: values.NESTO_GREEN,
                        )
                      : ImageIcon(
                          AssetImage(
                            "assets/icons/clipboard_icon.png",
                          ),
                          color: values.NESTO_GREEN,
                        )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
