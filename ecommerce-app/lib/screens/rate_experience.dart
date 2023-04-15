import 'dart:async';
import 'dart:convert';

import 'package:Nesto/providers/auth_provider.dart';
import 'package:Nesto/screens/base_screen.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/utils/util.dart';
import 'package:Nesto/widgets/connectivity_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Nesto/strings.dart' as strings;
import '../values.dart' as values;

class RateExperience extends StatefulWidget {
  static String routeName = "/rate_experience_screen";

  RateExperience({Key key}) : super(key: key);

  @override
  _RateExperienceState createState() => _RateExperienceState();
}

class _RateExperienceState extends State<RateExperience> {
  int rating = 0;

  Future sendRating() async {
    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    var customerId = authProvider?.magentoUser?.id;
    String _lamdaBaseURL = FlavorConfig.instance.variables["LAMBDA_BASE_URL"];
    var queryParams = await getQueryParams() ?? "";
    var url = _lamdaBaseURL + '/experience-rating' + queryParams;
    var payload = {"customer_id": customerId, "experience_rating": rating};
    var encodedJson = jsonEncode(payload);
    var header = {
      "content-type": "application/json",
      "access-token": getLambdaToken() ?? "",
    };
    try {
      //log('HEADER: $header', name: 'rate_exprience');
      //log('URL: $url', name: 'rate_exprience');
      //log('PAYLOAD: $payload', name: 'rate_exprience');
      logNestoCustom(message: 'HEADER: $header', logType: LogType.debug);
      logNestoCustom(message: 'URL: $url', logType: LogType.debug);
      logNestoCustom(message: 'PAYLOAD: $payload', logType: LogType.debug);

      var response =
          await http.post(Uri.parse(url), body: encodedJson, headers: header);
      if (response?.statusCode == 200) {
        //log('RESPONSE: ${response.body}', name: 'rate_experience');
        logNestoCustom(
            message: 'RESPONSE: ${response.body}', logType: LogType.debug);

        //firebase analytics logging.
        firebaseAnalytics.rateOrder(
          rating: rating.toString() ?? 'none',
        );
      } else {
        throw ('${response.body}');
      }
    } catch (e) {
      //log('ERR: $e', name: 'rate_experience');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }
  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "Rate Experience Screen");
    super.initState();
  }
  Widget build(BuildContext context) {
    //Screen Util Init
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);

    return SafeArea(
        child: Scaffold(
      body: ConnectivityWidget(
        child: Container(
          padding: EdgeInsets.only(
              top: ScreenUtil().setHeight(213.0),
              bottom: ScreenUtil().setHeight(32.0)),
          height: double.infinity,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                strings.HOW_DID_WE_DO,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: ScreenUtil().setHeight(26.0)),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(57.0)),
                child: Text(
                  strings.PLEASE_RATE_YOUR_DELIVERY_EXPERIANCE,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      color: Color(0XFF7E7F80)),
                ),
              ),
              SizedBox(height: ScreenUtil().setHeight(90.0)),
              StarRating(
                onChanged: (index) {
                  setState(() {
                    rating = index;
                  });
                },
                value: rating,
                filledStar: Icons.star_rounded,
                unfilledStar: Icons.star_border_rounded,
              ),
              SizedBox(height: ScreenUtil().setHeight(134.0)),
              // ChipTile(
              //   icon: Icons.verified,
              //   subText: 'Savings made in this order',
              //   mainText: 'AED 30 in Savings',
              // ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: GreenButton(
                    buttonTitle: strings.CONTINUE,
                    onPress: () async {
                      sendRating();
                      SharedPreferences sp =
                          await SharedPreferences.getInstance();
                      bool firstOrderPlaced =
                          sp.getBool('firstOrderPlaced') ?? false;
                      if (!firstOrderPlaced) {
                        await sp.setBool('firstOrderPlaced', true);
                      }
                      Navigator.of(context).pushReplacementNamed(
                          BaseScreen.routeName,
                          arguments: {
                            "firstOrderPlaced": !firstOrderPlaced,
                            'index': 0
                          });
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    ));
  }
}

class GreenButton extends StatelessWidget {
  const GreenButton(
      {Key key,
      @required this.buttonTitle,
      @required this.onPress,
      this.buttonHeight})
      : super(key: key);

  final String buttonTitle;
  final Function onPress;
  final double buttonHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 26.0),
      height: ScreenUtil().setHeight(buttonHeight ?? 61.86),
      child: Material(
        color: Color(0XFF00983D),
        clipBehavior: Clip.antiAlias,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.84)),
        child: MaterialButton(
          onPressed: onPress,
          child: Center(
            child: Text(
              buttonTitle,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17.67,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

class ChipTile extends StatelessWidget {
  ChipTile({this.icon, this.subText, this.mainText});

  final IconData icon;
  final String subText;
  final String mainText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 36.0),
      height: ScreenUtil().setHeight(64),
      width: ScreenUtil().setWidth(312),
      decoration: BoxDecoration(
          color: Color(0XFFF5F5F8), borderRadius: BorderRadius.circular(8.0)),
      child: Row(
        children: [
          //gif
          Icon(
            icon,
            size: 32,
            color: values.NESTO_GREEN,
          ),
          SizedBox(
            width: ScreenUtil().setWidth(37.0),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subText,
                style: TextStyle(
                    fontSize: 10,
                    height: 1.2,
                    fontWeight: FontWeight.w400,
                    color: Color(0XFF757D85)),
              ),
              Text(
                mainText,
                style: TextStyle(
                    color: Color(0XFF111A2C),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.2),
              )
            ],
          )
        ],
      ),
    );
  }
}

class StarRating extends StatelessWidget {
  final void Function(int index) onChanged;
  final int value;
  final IconData filledStar;
  final IconData unfilledStar;

  const StarRating({
    Key key,
    this.onChanged,
    this.value = 0,
    this.filledStar,
    this.unfilledStar,
  })  : assert(value != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = Color(0XFFFFA133);
    final size = 28.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return IconButton(
          onPressed: onChanged != null
              ? () {
                  onChanged(value == index + 1 ? index : index + 1);
                }
              : null,
          color: index < value ? color : null,
          iconSize: size,
          icon: Icon(
            index < value //
                ? filledStar ?? Icons.star
                : unfilledStar ?? Icons.star_border,
          ),
          padding: EdgeInsets.zero,
          tooltip: '${index + 1} of 5',
        );
      }),
    );
  }
}
