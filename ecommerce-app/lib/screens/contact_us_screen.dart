
import 'package:Nesto/screens/rate_experience.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/widgets/connectivity_widget.dart';
import 'package:Nesto/widgets/headers.dart';
import 'package:easy_rich_text/easy_rich_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Nesto/strings.dart' as strings;
import '../values.dart' as values;

class ContactUsScreen extends StatefulWidget {
  static const routeName = '/contact_us';
  @override
  _ContactUsScreenState createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  String _phoneNumber = "+97148129700";

  void _callSupport() async {
    var uri = 'tel:$_phoneNumber';
    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }

  _launchWhatsapp() async {
    await FlutterOpenWhatsapp.sendSingleMessage(_phoneNumber, "");
  }

  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "Contact Us Screen");
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    //Screen Util
    ScreenUtil.init(context,
        designSize: Size(414, 926), allowFontScaling: true);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: headerBar(title: strings.CONTACT_US, context: context),
        body:  ConnectivityWidget(
          child: Container(
            padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(80.0)),
            height: double.infinity,
            width: double.infinity,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(
                      top: ScreenUtil().setHeight(101.0),
                      bottom: ScreenUtil().setHeight(39.0)),
                  height: ScreenUtil().setHeight(202),
                  width: ScreenUtil().setWidth(202),
                  child: Center(
                    child: SizedBox(
                      height: ScreenUtil().setWidth(202),
                      width: ScreenUtil().setWidth(202),
                      child: Lottie.asset('assets/animations/contact_us.json'),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(40.0)),
                  child: Text(
                    strings.CONTACT_US_DESCRIPTION,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GreenButton(
                          onPress: _callSupport,
                          buttonTitle: strings.CALL_US,
                          buttonHeight: 56.0,
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(20.0),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 26.0),
                          child: SizedBox(
                            height: ScreenUtil().setHeight(56.0),
                            child: Material(
                              color: Color(0XFF00983D),
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.84)),
                              child: MaterialButton(
                                onPressed: _launchWhatsapp,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/whatsapp_sabarish.svg',
                                      height: ScreenUtil().setWidth(24.0),
                                      width: ScreenUtil().setWidth(24.0),
                                    ),
                                    SizedBox(
                                      width: ScreenUtil().setWidth(15.0),
                                    ),
                                    Text(
                                      strings.WHATSAPP_US,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 17.67,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(20.0),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil().setWidth(26.0)),
                          height: ScreenUtil().setHeight(56.0),
                          child: Material(
                            color: Colors.transparent,
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                                side: BorderSide(color: values.NESTO_GREEN),
                                borderRadius: BorderRadius.circular(8.84)),
                            child: Center(
                              child: EasyRichText(
                                strings.CONTACT_US_EMAIL,
                                patternList: [
                                  EasyRichTextPattern(
                                    targetString: 'support@nesto.shop',
                                    urlType: 'email',
                                    style: TextStyle(
                                        color: values.NESTO_GREEN,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
