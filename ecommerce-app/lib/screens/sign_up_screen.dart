import 'dart:async';

import 'package:Nesto/models/user.dart';
import 'package:Nesto/providers/auth_provider.dart';
import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/screens/base_screen.dart';
import 'package:Nesto/screens/login_screen.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/strings.dart' as strings;
import 'package:Nesto/utils/constants.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/utils/util.dart';
import 'package:Nesto/widgets/connectivity_widget.dart';
import 'package:Nesto/widgets/dismiss_keyboard_widget.dart';
import 'package:Nesto/widgets/gender_radio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = "/sign_up_screen";
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

//GlobalKey _signUpFormKey;

class _SignUpScreenState extends State<SignUpScreen> {
  String _email, _phone, _name;
  String _countryCode = '+971';
  DateTime selectedDate = DateTime.now();
  String dob = '';
  String _currentSelectedCountry;

  String phoneErr, emailErr, nameErr;
  bool showPhoneErr = false;
  bool showEmailErr = false;
  bool showNameErr = false;
  bool _genderErr = false;
  bool _dobErr = false;
  bool visible = false;
  bool _nationalityErr = false;

  Gender selectedGender = Gender.none;

  bool isEmailFocused = false;

  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();

  FocusNode nameFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();

  void setEmail(value) => _email = value;
  void setPhone(value) => _phone = value;
  void setName(value) => _name = value;
  void setCountryCode(value) => _countryCode = value.toString();

  void loadProgress() {
    if (visible == true) {
      setState(() {
        visible = false;
      });
    } else {
      setState(() {
        visible = true;
      });
    }
  }

  changeGender(Gender gender) {
    //log('$gender', name: 'profile_screen');
    logNestoCustom(message: '$gender', logType: LogType.debug);

    setState(() => selectedGender = gender);
  }

  void _validate() {
    bool isEmailValid = _emailController.text.isValidEmail();
    bool isNameEmpty = _nameController.text.isEmpty;
    if (isNameEmpty) {
      showNameErr = true;
      nameErr = strings.NAME_CANNOT_BE_EMPTY;
    } else {
      showNameErr = false;
    }
    if (!isEmailValid) {
      showEmailErr = true;
      emailErr = strings.PLEASE_ENTER_VALID_EMAIL;
    } else {
      showEmailErr = false;
    }
    if (dob == null || dob == '') {
      _dobErr = true;
    } else {
      _dobErr = false;
    }
    if (_currentSelectedCountry == null) {
      _nationalityErr = true;
    } else {
      _nationalityErr = false;
    }
    if (selectedGender == Gender.none) {
      _genderErr = true;
    } else {
      _genderErr = false;
    }
    setState(() {});
    if (showEmailErr ||
        showNameErr ||
        _genderErr ||
        _dobErr ||
        _nationalityErr) {
      return;
    }
    _signUp();
  }

  void _signUp() async {
    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    var storeProvider = Provider.of<StoreProvider>(context, listen: false);
    authProvider.email = _email;
    logNesto("EMAIL FROM INPUT FIELD:" + _email);
    authProvider.userFullName = _name;
    EasyLoading.show(
      maskType: EasyLoadingMaskType.black,
    );
    try {
      await authProvider.registerNewUserInMagento();
      if (authProvider.isRegistrationComplete) {
        Future.delayed(Duration(seconds: 1, milliseconds: 700), () {
          WidgetsFlutterBinding.ensureInitialized();
          EasyLoading.dismiss();
          authProvider.isRegistrationComplete = false;
          authProvider.clearMagentoUser();
          var payLoad = {
            "customer": {
              "firstname": _name,
              "lastname": ".",
              "email": _email,
              "website_id": 1,
              "dob": dob,
              "gender": selectedGender == Gender.male ? 1 : 0,
              "custom_attributes": [
                {
                  "attribute_code": "mobile_number",
                  "value": authProvider.phoneNumber
                },
                {
                  "attribute_code": "nationality",
                  "value": _currentSelectedCountry
                }
              ]
            }
          };
          authProvider.editUserProfile(payLoad, signup: true);
          storeProvider.createMagentoCart();

          Navigator.of(context).pushNamedAndRemoveUntil(
              BaseScreen.routeName, (route) => false,
              arguments: {"index": 0});
        });
      } else {
        EasyLoading.dismiss();
        logNesto('This is not executed');
        showError(context, authProvider.errorMessage);
      }
    } catch (e) {
      EasyLoading.dismiss();
      print(e.message);
      showError(
          context, strings.COULD_NOT_COMPLETE_REGISTRATION_PLEASE_TRY_AGAIN);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus.unfocus();
    }
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        fieldHintText: 'mm/dd/yy',
        firstDate: DateTime(1947),
        lastDate: DateTime.now());
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        DateFormat dateFormat = DateFormat("MMM dd,yyyy");
        dob = dateFormat.format(selectedDate);
      });
  }

  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "Sign Up Screen");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);

    @override
    void dispose() {
      super.dispose();
      // Clean up the focus node and controllers when disposed.
      nameFocusNode.dispose();
      emailFocusNode.dispose();
      _emailController.clear();
      _nameController.clear();
      _emailController.dispose();
      _nameController.dispose();
    }

    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.white,
      body: ConnectivityWidget(
        child: DismissKeyboard(
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Visibility(
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  visible: visible,
                  child: CircularProgressIndicator()),
              Container(
                width: double.infinity,
                height: double.infinity,
                padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(26.0)),
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(top: ScreenUtil().setHeight(60)),
                  child: Column(
                    children: [
                      nestoImageContainer(),
                      SizedBox(
                        height: ScreenUtil().setHeight(38.0),
                      ),
                      titleText(title: strings.GETTING_STARTED),
                      SizedBox(
                        height: ScreenUtil().setHeight(8.85),
                      ),
                      subTitleText(strings.CREATE_AN_ACCOUNT_TO_CONTINUE),
                      SizedBox(
                        height: ScreenUtil().setHeight(23.65),
                      ),
                      customRow(
                          title: strings.NAME,
                          showErr: showNameErr,
                          errText: nameErr),
                      SizedBox(
                        height: ScreenUtil().setHeight(8.56),
                      ),
                      CustomTextField(
                          showErrorText: showNameErr,
                          controller: _nameController,
                          onChangeText: setName,
                          hintText: strings.ENTER_YOUR_NAME,
                          autoFoucus: true,
                          keyboardType: TextInputType.name,
                          focusNode: nameFocusNode,
                          onSubmit: () {
                            // FocusScope.of(context).nextFocus();
                            setState(() {
                              isEmailFocused = true;
                            });
                          }),
                      customRow(
                          title: strings.EMAIL,
                          showErr: showEmailErr,
                          errText: emailErr),
                      SizedBox(
                        height: ScreenUtil().setHeight(8.56),
                      ),
                      CustomTextField(
                          showErrorText: showEmailErr,
                          controller: _emailController,
                          onChangeText: setEmail,
                          hintText: strings.ENTER_YOUR_EMAIL,
                          autoFoucus: isEmailFocused,
                          focusNode: emailFocusNode,
                          keyboardType: TextInputType.emailAddress,
                          onSubmit: () {
                            isEmailFocused = false;
                          }),
                      customRow(
                        title: strings.NATIONALITY,
                        showErr: _nationalityErr,
                        errText: strings.NATIONALITY_ERR,
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(8.56),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            bottom: ScreenUtil().setHeight(18.81)),

                        padding: EdgeInsets.only(
                          left: ScreenUtil().setWidth(17),
                          right: ScreenUtil().setWidth(10),
                          top: ScreenUtil().setHeight(14.0),
                          bottom: ScreenUtil().setHeight(14.0),
                        ),
                        // height: ScreenUtil().setHeight(68),
                        width: double.infinity,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: _nationalityErr
                                    ? Colors.red
                                    : Colors.transparent),
                            color: Color(0XFFBBBDC1).withOpacity(0.18),
                            borderRadius: BorderRadius.circular(8.0)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            iconSize: 30,
                            iconDisabledColor: values.NESTO_GREEN,
                            iconEnabledColor: _nationalityErr
                                ? Colors.red
                                : values.NESTO_GREEN,
                            value: _currentSelectedCountry,
                            isDense: true,
                            onChanged: (String newValue) {
                              setState(
                                  () => _currentSelectedCountry = newValue);
                            },
                            hint: Text(
                              strings.SELECT_NATIONALITY,
                            ),
                            items: COUNTRY_LIST.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: SizedBox(
                                    width: ScreenUtil().setWidth(260.0),
                                    child: Text(
                                      value,
                                      maxLines: 1,
                                    )),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      customRow(
                        title: strings.DATE_OF_BIRTH,
                        showErr: _dobErr,
                        errText: strings.PLEASE_SELECT_DOB,
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(8.56),
                      ),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Container(
                          height: ScreenUtil().setHeight(61.97),
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(
                              left: ScreenUtil().setWidth(18.0)),
                          margin: EdgeInsets.only(
                              bottom: ScreenUtil().setHeight(18.81)),
                          decoration: BoxDecoration(
                            color: Color(0XFFBBBDC1).withOpacity(0.18),
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.85)),
                            border:
                                _dobErr ? Border.all(color: Colors.red) : null,
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                      dob == null || dob == ''
                                          ? strings.SELECT_DOB
                                          : dob,
                                      style: dob == null || dob == ''
                                          ? placeholderTextStyle
                                          : TextStyle(
                                              color: Colors.black,
                                              fontSize: 16)),
                                ),
                                Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            ScreenUtil().setWidth(15.0)),
                                    child: Icon(
                                      Icons.calendar_today_rounded,
                                      color: !_dobErr
                                          ? kGreyColor.withOpacity(0.6)
                                          : Colors.red,
                                      size: 22,
                                    ))
                              ],
                            ),
                          ),
                        ),
                      ),
                      customRow(
                        title: strings.GENDER,
                        showErr: _genderErr,
                        errText: strings.PLEASE_SELECT_GENDER,
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(8.56),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GenderRadio(
                            // value: Gender.male,
                            isSelected: selectedGender == Gender.male,
                            label: strings.MALE,
                            selectedGender: selectedGender,
                            onPress: () => changeGender(Gender.male),
                          ),
                          SizedBox(width: ScreenUtil().setWidth(5)),
                          GenderRadio(
                            // value: Gender.female,
                            isSelected: selectedGender == Gender.female,
                            label: strings.FEMALE,
                            selectedGender: selectedGender,
                            onPress: () => changeGender(Gender.female),
                          )
                        ],
                      ),
                      SizedBox(height: ScreenUtil().setWidth(84)),
                      GreenButton(
                        //TODO: SIGN UP HERE
                        buttonText: strings.SIGN_UP,
                        onPress: _validate,
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(16.6),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Widget customRow({String title, String errText, bool showErr}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(color: Color(0xFF898B9A), fontSize: 15.49),
        ),
        Text(
          showErr ? errText : '',
          style: TextStyle(color: Colors.red, fontSize: 12.0),
        ),
      ],
    );
  }
}

class CustomTextField extends StatelessWidget {
  CustomTextField({
    @required this.showErrorText,
    @required this.controller,
    @required this.onChangeText,
    @required this.keyboardType,
    @required this.onSubmit,
    this.autoFoucus,
    this.hintText,
    this.focusNode,
  });

  final bool showErrorText;
  final TextEditingController controller;
  final ValueChanged onChangeText;
  final String hintText;
  final TextInputType keyboardType;
  final Function onSubmit;
  final bool autoFoucus;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(61.97),
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: ScreenUtil().setWidth(18.0)),
      margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(18.81)),
      decoration: BoxDecoration(
        color: Color(0XFFBBBDC1).withOpacity(0.18),
        borderRadius: BorderRadius.all(Radius.circular(8.85)),
        border: showErrorText ? Border.all(color: Colors.red) : null,
      ),
      child: TextFormField(
        controller: controller,
        textInputAction: TextInputAction.done,
        keyboardType: keyboardType,
        autofocus: autoFoucus,
        focusNode: focusNode,
        textAlignVertical: TextAlignVertical.center,
        minLines: 1,
        onChanged: onChangeText,
        onFieldSubmitted: (value) {
          onSubmit();
        },
        cursorColor: Colors.black,
        decoration: InputDecoration(
          hintText: hintText ?? '',
          contentPadding: EdgeInsets.all(0.0),
          suffixIcon: Icon(
            !showErrorText
                ? Icons.check_circle_outline_outlined
                : Icons.cancel_outlined,
            color: !showErrorText ? kGreyColor.withOpacity(0.6) : Colors.red,
            size: 20,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

Color kGreenColor = Color(0XFF00983D);

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(this);
  }
}

extension NameValidator on String {
  bool isValidName() {
    return RegExp(r"^[a-zA-Z]+(([',. -][a-zA-Z ])?[a-zA-Z]*)*$").hasMatch(this);
  }
}

extension PhoneValidator on String {
  bool isValidPhone() {
    return RegExp(r'(^(?:[+0]9)?[0-9]{10,16}$)').hasMatch(this);
  }
}

extension PasswordValidator on String {
  bool isValidPassword(String pass) {
    return RegExp(
            r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
        .hasMatch(pass);
  }
}

Color kGreyColor = Color(0XFF525C67);

var boxDecoration =
    BoxDecoration(color: greyColor, borderRadius: BorderRadius.circular(10));
var textFieldStyle = TextStyle(color: Colors.black, fontSize: 16);
var placeholderTextStyle = TextStyle(color: Colors.grey[700], fontSize: 16);
