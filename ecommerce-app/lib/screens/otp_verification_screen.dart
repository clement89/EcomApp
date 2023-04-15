import 'dart:async';

import 'package:Nesto/dio/models/otp_verification_request.dart';
import 'package:Nesto/providers/auth_provider.dart';
import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/screens/base_screen.dart';
import 'package:Nesto/screens/login_screen.dart';
import 'package:Nesto/screens/sign_up_screen.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/widgets/connectivity_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:Nesto/strings.dart' as strings;
import '../utils/util.dart';

class OtpVerificationScreen extends StatefulWidget {
  static String routeName = 'otp_verification_screen';

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String _otp;
  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "OTP Verification Screen");
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);

    var authProvider = Provider.of<AuthProvider>(context);
    var storeProvider = Provider.of<StoreProvider>(context, listen: false);

    //Move to dummy screen after auth is complete

    if (authProvider.isAuthError) {
      authProvider.isAuthError = false;
      Future.delayed(Duration.zero, () {
        WidgetsFlutterBinding.ensureInitialized();
        EasyLoading.dismiss();
        showError(context, authProvider.errorMessage);
      });
    }

    void submitHandler() async {
      if (authProvider.otpVerifiedStatus == true) {
        if (authProvider.shouldUserBeRegisteredDuringOTPVerification) {
          authProvider.shouldUserBeRegisteredDuringOTPVerification = false;
          Future.delayed(Duration.zero, () {
            WidgetsFlutterBinding.ensureInitialized();
            EasyLoading.dismiss();
            Navigator.of(context).pushNamed(SignUpScreen.routeName);
          });
        } else {
          await authProvider.saveTempAuthTokenAsAuthToken();
          if (authProvider.isRegistrationComplete) {
            authProvider.isRegistrationComplete = false;
            authProvider.clearMagentoUser();
            authProvider.fetchMagentoUser();
            storeProvider.createMagentoCart();
            Future.delayed(Duration.zero, () {
              WidgetsFlutterBinding.ensureInitialized();
              EasyLoading.dismiss();
              Navigator.of(context).pushNamedAndRemoveUntil(
                  BaseScreen.routeName, (route) => false,
                  arguments: {"index": 0});
            });
          }
        }
      } else {
        Future.delayed(Duration(seconds: 1, milliseconds: 420), () {
          EasyLoading.dismiss();
          showError(context, strings.PLEASE_ENTER_CORRECT_OTP);
        });
      }
    }

    void callVerifyOtpMagentoInAuthProvider() async {
      firebaseAnalytics.logInitiateOtpVerification();
      EasyLoading.show(
        maskType: EasyLoadingMaskType.black,
      );
      authProvider.otp = _otp;
      await authProvider
          .verifyOtpMagento(
              otpVerificationRequest: OtpVerificationRequest(
                  customer: CustomerDetails(
                      mobilenumber: authProvider.phoneNumber.toString(),
                      otp: _otp)))
          .then((value) {
        submitHandler();
      }).onError((error, stackTrace) {
        EasyLoading.dismiss();
        showError(context, strings.SOMETHING_WENT_WRONG);

        //analytics logging.
        firebaseAnalytics.logOtpFailure();
      });
    }

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: ConnectivityWidget(
          child: Container(
            height: double.infinity,
            width: double.infinity,
            padding: EdgeInsets.only(
              top: ScreenUtil().setHeight(62.0),
              left: ScreenUtil().setWidth(26.0),
              right: ScreenUtil().setWidth(26.0),
            ),
            child: Column(
              children: [
                nestoImageContainer(),
                verticalSpace(53.04),
                titleText(title: strings.OTP_AUTHENTICATION),
                verticalSpace(17.71),
                Text(
                  strings.AN_AUTHENTICATION_CODE_HAS_BEEN_SENT_TO,
                  style: kGreyTextStyle,
                ),
                Text(
                  authProvider.phoneNumber.replaceAllMapped(
                          RegExp(r".{4}"), (match) => "${match.group(0)} ") ??
                      '--',
                  style: kGreyTextStyle,
                ),
                verticalSpace(52.24),
                // buildTimer(),
                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  autoFocus: true,
                  animationType: AnimationType.scale,
                  pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(5.0),
                      fieldHeight: 50,
                      fieldWidth: 40,
                      activeColor: Color(0XFFF5F5F8),
                      inactiveColor: Color(0XFFF5F5F8),
                      activeFillColor: Color(0XFFF5F5F8),
                      inactiveFillColor: Color(0XFFF5F5F8),
                      selectedFillColor: Color(0XFFF5F5F8),
                      selectedColor: Color(0XFFCFD0D7)),
                  enableActiveFill: true,
                  cursorColor: Colors.black,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _otp = value;
                    });
                  },
                  onSubmitted: (value) => callVerifyOtpMagentoInAuthProvider(),
                ),
                verticalSpace(26.56),
                !authProvider.resendOTPTimer
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            strings.DIDINT_RECIEVE_THE_CODE,
                            style: kGreyTextStyle.copyWith(fontSize: 17.71),
                          ),
                          GestureDetector(
                            onTap: () => authProvider.resendOTP(),
                            child: Text(
                              strings.RESEND,
                              style: kGreyTextStyle.copyWith(
                                  fontSize: 17.71,
                                  color: kGreenColor,
                                  fontWeight: FontWeight.w700),
                            ),
                          )
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            strings.RESEND_A_NEW_OTP_IN,
                            style: kGreyTextStyle.copyWith(fontSize: 17.71),
                          ),
                          Countdown(
                            seconds: 30,
                            build: (BuildContext context, double time) => Text(
                              "00:" + time.toInt().toString(),
                              style: kGreyTextStyle.copyWith(
                                  fontSize: 17.71,
                                  color: kGreenColor,
                                  fontWeight: FontWeight.w700),
                            ),
                            interval: Duration(seconds: 1),
                            onFinished: () {
                              authProvider.hideResendOTPTimer();
                            },
                          ),
                        ],
                      ),
                verticalSpace(38),
                GreenButton(
                    onPress: callVerifyOtpMagentoInAuthProvider,
                    buttonText: strings.CONTINUE),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//styles
const greyColor = Color(0xFFB2B2B2);
Color kGreyColor = Color(0XFF525C67);
Color kGreenColor = Color(0XFF00983D);

TextStyle kGreyTextStyle = TextStyle(
  color: kGreyColor.withOpacity(0.6),
  fontSize: 15.49,
  height: 1.7,
);
