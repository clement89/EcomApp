import 'dart:async';
import 'package:Nesto/strings.dart' as strings;
import 'package:Nesto/providers/auth_provider.dart';
import 'package:Nesto/screens/otp_verification_screen.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/utils/formatters/card_formatter.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/widgets/connectivity_widget.dart';
import 'package:Nesto/widgets/dismiss_keyboard_widget.dart';
import 'package:Nesto/widgets/headers.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:easy_rich_text/easy_rich_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:provider/provider.dart';

import '../utils/util.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = "/login_screen";

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool showPassword = true;
  bool isTextFieldShown = true;
  String phoneNum;
  void setNumber(number) => phoneNum = number;

  void toggle() {
    setState(() {
      showPassword = !showPassword;
    });
  }

  void getOtp() {
    setState(() {
      isTextFieldShown = false;
    });
  }
  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "Login Screen");
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);

    var authProvider = Provider.of<AuthProvider>(context);

    // if (authProvider.doesUserNeedsToBeRegistered) {
    //   Future.delayed(Duration.zero, () {
    //     WidgetsFlutterBinding.ensureInitialized();
    //     EasyLoading.dismiss();
    //     authProvider.doesUserNeedsToBeRegistered = false;
    //     Navigator.of(context).pushNamed(SignUpScreen.routeName);
    //   });
    // }

    if (authProvider.canUserProceedToOTPScreen) {
      Future.delayed(Duration.zero, () {
        WidgetsFlutterBinding.ensureInitialized();
        EasyLoading.dismiss();
        authProvider.canUserProceedToOTPScreen = false;
        //Maybe confusing but need seperate variable to know if we should procced with

        Navigator.of(context).pushNamed(OtpVerificationScreen.routeName);
      });
    }

    if (authProvider.isAuthError) {
      authProvider.isAuthError = false;
      Future.delayed(Duration.zero, () {
        WidgetsFlutterBinding.ensureInitialized();
        EasyLoading.dismiss();
        showError(context, authProvider.errorMessage);
      });
    }

    return SafeArea(
      child: Scaffold(
        appBar: headerBar(title: '', context: context),
        backgroundColor: Colors.white,
        key: _scaffoldKey,
        body: ConnectivityWidget(
          child: DismissKeyboard(
            child: Container(
              height: double.infinity,
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 26.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //nestoImage
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 60.31, 0.0, 69.0),
                      child: nestoImageContainer(),
                    ),
                    titleText(
                      title: strings.LETS_SIGN_YOU_IN,
                    ),
                    verticalSpace(8.85),
                    subTitleText(''),
                    verticalSpace(51.11),
                    //enter email
                    LoginForm(
                      setNumber: setNumber,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget titleText({String title}) {
  return Text(
    title,
    style: TextStyle(fontSize: 26.56, fontWeight: FontWeight.w700),
  );
}

Widget subTitleText(String text) {
  return Text(
    text,
    style: TextStyle(
        color: kGreyColor.withOpacity(0.6),
        fontSize: 15.49,
        fontWeight: FontWeight.w400),
  );
}

class LoginForm extends StatefulWidget {
  LoginForm({
    this.setNumber,
  });

  final Function setNumber;

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool showErrorText = false;
  final _phoneController = TextEditingController();

  String _countryCode = '+971';

  void _login() async {
    if (_phoneController.text.isEmpty ||
        _phoneController.text.length <= 6 ||
        _phoneController.text.length >= 13) {
      setState(() {
        showErrorText = true;
      });
      return;
    }
    setState(() {
      showErrorText = false;
    });

    String _phoneNumber = _countryCode + _phoneController.text;

    EasyLoading.show(
      //status: 'Processing...',
      maskType: EasyLoadingMaskType.black,
    );

    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.phoneNumber = _phoneNumber;
    try {
      await authProvider.sendMobileNumberToMagento();
      firebaseAnalytics.logSignIn(logInMethod: "mobile");
    } catch (e) {
      EasyLoading.dismiss();
      logNesto("LOGIN ERROR:" + e.toString());
      showError(context, strings.COULD_NOT_COMPLETE_THE_REQUEST_TRY_AGAIN);

      //analytics logging.
      firebaseAnalytics.logSignInFailure(logInMethod: "mobile");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              strings.Phone_number,
              style: TextStyle(color: Color(0xFF898B9A), fontSize: 15.49),
            ),
            Text(
              showErrorText ? strings.PLEASE_ENTER_A_VALID_PHONE_NUMBER : '',
              style: TextStyle(color: Colors.red, fontSize: 12.0),
            ),
          ],
        ),
        verticalSpace(8.56),
        Container(
          height: ScreenUtil().setHeight(61.97),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 10.0),
          decoration: BoxDecoration(
            color: Color(0XFFBBBDC1).withOpacity(0.18),
            borderRadius: BorderRadius.all(Radius.circular(8.85)),
            border: showErrorText ? Border.all(color: Colors.red) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 13,
                child: CountryCodePicker(
                  onChanged: (value) {
                    setState(() {
                      _countryCode = value.toString();
                    });
                  },
                  padding: EdgeInsets.all(0.0),
                  initialSelection: '+971',
                  showDropDownButton: true,
                  alignLeft: true,
                  flagWidth: 16,
                  showCountryOnly: false,
                  showOnlyCountryWhenClosed: false,
                  enabled: true,
                  countryFilter: ["AE", "IN"],
                  showFlag: true,
                  showFlagMain: true,
                ),
              ),
              Expanded(
                flex: 15,
                child: TextFormField(
                  textAlignVertical: TextAlignVertical.center,
                  controller: _phoneController,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.number,
                  minLines: 1,
                  autofocus: true,
                  onChanged: widget.setNumber,
                  onFieldSubmitted: (value) {
                    _login();
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(15),
                    PhoneInputFormatter(),
                  ],
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    hintText: strings.ENTER_YOUR_PHONE_NUMBER,
                    contentPadding: EdgeInsets.all(0.0),
                    suffixIcon: Icon(
                      !showErrorText
                          ? Icons.check_circle_outline_outlined
                          : Icons.cancel_outlined,
                      color: !showErrorText
                          ? kGreyColor.withOpacity(0.6)
                          : Colors.red,
                      size: 15.49,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        verticalSpace(34.75),
        GreenButton(
          onPress: _login,
          buttonText: strings.SIGN_IN,
        ),
        verticalSpace(64),
        Center(
          child: EasyRichText(
            strings.BY_ENTERING_YOUR_PHONE_NUMBER_YOU_AGRRE_TO_T_AND_C,
            textAlign: TextAlign.center,
            defaultStyle: TextStyle(
                fontWeight: FontWeight.w400,
                color: Colors.black87,
                fontSize: 14),
            patternList: [
              EasyRichTextPattern(
                targetString: strings.TERMS_AND_CONDITIONS,
                recognizer: TapGestureRecognizer()
                  ..onTap = () => launchTermsAndConditions(),
                style: TextStyle(
                  color: values.NESTO_GREEN,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
              ),
              EasyRichTextPattern(
                targetString: strings.PRIVACY_POLICY,
                recognizer: TapGestureRecognizer()
                  ..onTap = () => launchPrivacyPolicy(),
                style: TextStyle(
                  color: values.NESTO_GREEN,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ],
    ));
  }
}

Widget verticalSpace(double height) {
  return SizedBox(
    height: ScreenUtil().setHeight(height),
  );
}

Widget nestoImageContainer() {
  return SizedBox(
    height: ScreenUtil().setHeight(90.0),
    width: ScreenUtil().setWidth(174.0),
    child: Image(
      fit: BoxFit.cover,
      image: AssetImage('assets/images/nestoLogin.webp'),
    ),
  );
}

class GreenButton extends StatelessWidget {
  GreenButton({@required this.onPress, @required this.buttonText});

  final Function onPress;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: ScreenUtil().setHeight(61.97),
      child: MaterialButton(
          onPressed: onPress,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          color: kGreenColor,
          child: Center(
            child: Text(
              buttonText,
              style: TextStyle(
                  fontSize: 17.71,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
          )),
    );
  }
}

//styles
const kInputTextDecoration = InputDecoration(
    border: UnderlineInputBorder(
      borderSide: BorderSide(
          // 1px solid #B2B2B2
          color: Color(0xFFB2B2B2),
          width: 1.0),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(
          // 1px solid #B2B2B2
          color: Color(0xFFB2B2B2),
          width: 1.0),
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(
          // 1px solid #B2B2B2
          color: Color(0xFFB2B2B2),
          width: 1.0),
    ),
    labelStyle: TextStyle(color: Color(0XFFB2B2B2)));

const loginButtonColor = Color(0XFF249140);
const kInputTextStyle = TextStyle(
  color: Color(0xFFB2B2B2),
);
const kLoginBtnTextStyle = TextStyle(fontSize: 15, color: Color(0xFFFFFFFF));

const greyColor = Color(0xFFB2B2B2);
Color kGreyColor = Color(0XFF525C67);
Color kGreenColor = Color(0XFF00983D);

TextStyle kGreyTextStyle = TextStyle(
  color: kGreyColor.withOpacity(0.6),
  fontSize: 15.49,
  height: 1.7,
);
