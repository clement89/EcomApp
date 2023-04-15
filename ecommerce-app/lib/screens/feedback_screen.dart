import 'dart:io';

import 'package:Nesto/providers/auth_provider.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/utils/util.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/widgets/headers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:Nesto/strings.dart' as strings;
import 'package:url_launcher/url_launcher.dart';

class FeedbackScreen extends StatelessWidget {
  static String routeName = '/feedback_screen';

  @override
  Widget build(BuildContext context) {
    void _sendFeedback(String feedbackType) async {
      String userId = "";
      var authProvider = Provider.of<AuthProvider>(context, listen: false);
      String sourceInfo = await getQueryParams(forMail: true);
      if (isAuthTokenValid()) {
        if (authProvider.magentoUser == null) {
          await authProvider.fetchMagentoUser();
          userId = authProvider?.magentoUser?.id?.toString();
        } else {
          userId = authProvider?.magentoUser?.id?.toString();
        }
      }

      final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: strings.CONTACT_US_EMAIL,
        query: encodeQueryParameters(<String, String>{
          'subject': '$feedbackType${userId == "" ? "" : " - [ $userId ]"}',
          'body':
              "Do not delete the following information. ${Platform.isAndroid ? "\n\n$sourceInfo\nFeedback :-  " : "$sourceInfo"}"
        }),
      );
      if (await canLaunch(emailLaunchUri.toString())) {
        launch(emailLaunchUri.toString());
      } else {
        throw 'Could not launch ${emailLaunchUri.toString()}';
      }
    }

    firebaseAnalytics.screenView(screenName: "Referral Screen");
    return SafeArea(
      child: Scaffold(
          appBar: headerBar(title: strings.FEEDBACK_HEADER, context: context),
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
                                  bottom: ScreenUtil().setHeight(20.0),
                                  top: ScreenUtil().setHeight(10.0)),
                              // color: Colors.amber[100],
                              height: ScreenUtil().setHeight(150.0),
                              width: ScreenUtil().setWidth(150.0),
                              child: FittedBox(
                                fit: BoxFit.fitHeight,
                                child: Lottie.asset(
                                    'assets/animations/rate_us.json'),
                              ),
                            ),
                            Text(
                              strings.FEEDBACK_TITLE,
                              style: TextStyle(
                                  fontSize: 24.0,
                                  height: 1.19,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: ScreenUtil().setWidth(40),
                                  vertical: ScreenUtil().setHeight(17)),
                              child: Text(
                                strings.FEEDBACK_SUBTITLE,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.black),
                              ),
                            ),
                          ]),
                        ),
                      ]),
                ),
                Column(
                  children: [
                    Greenbutton(
                      label: strings.APP_FEEDBACK,
                      feedbackType: "App experience",
                      onPressed: _sendFeedback,
                    ),
                    Greenbutton(
                      label: strings.TECHNICAL_FEEDBACK,
                      feedbackType: "Technical",
                      onPressed: _sendFeedback,
                    ),
                    Greenbutton(
                      label: strings.OPERATIONAL_FEEDBACK,
                      feedbackType: "Operational",
                      onPressed: _sendFeedback,
                    ),
                  ],
                ),
              ],
            ),
          )),
    );
  }
}

class Greenbutton extends StatelessWidget {
  final String label;
  final String feedbackType;
  final Function onPressed;
  const Greenbutton({
    Key key,
    @required this.label,
    @required this.feedbackType,
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
        onPressed: () {
          onPressed(feedbackType);
        },
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
