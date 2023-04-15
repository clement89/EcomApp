import 'dart:async';

import 'package:Nesto/models/user.dart';
import 'package:Nesto/providers/auth_provider.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/utils/constants.dart';
import 'package:Nesto/utils/util.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/widgets/connectivity_widget.dart';
import 'package:Nesto/widgets/gender_radio.dart';
import 'package:Nesto/widgets/headers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:Nesto/strings.dart' as strings;

class ProfileScreen extends StatefulWidget {
  static String routeName = "/profile_screen";

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name;
  bool _nameErr = false;
  bool _dobErr = false;
  bool _genderErr = false;
  User magentoUser;
  Gender selectedGender = Gender.none;
  DateTime selectedDate = DateTime.now();
  String dob = '';
  String _currentSelectedCountry;
  bool _nationalityErr = false;

  void _save() async {
    EasyLoading.show();
    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    var payLoad = {
      "customer": {
        "firstname": _name,
        "lastname": ".",
        "email": authProvider.magentoUser.emailAddress,
        "website_id": 1,
        "dob": dob,
        "gender": selectedGender == Gender.male ? 1 : 0,
        "custom_attributes": [
          {
            "attribute_code": "mobile_number",
            "value": authProvider.magentoUser.phoneNumber
          },
          {
            "attribute_code": "nationality",
            "value": _currentSelectedCountry
          }
        ]
      }
    };

    bool success = await authProvider.editUserProfile(payLoad);
    if (success) {
      Navigator.of(context).pop();
    }
  }

  void _validate() {
    if (_name == null ||
        _name == '' ||
        dob == null ||
        dob == '' ||
        _currentSelectedCountry == null ||
        selectedGender == Gender.none) {
      if (_name == null || _name == '') {
        setState(() => _nameErr = true);
      } else {
        setState(() => _nameErr = false);
      }
      if (dob == null || dob == '') {
        setState(() => _dobErr = true);
      } else {
        setState(() => _dobErr = false);
      }
      if (_currentSelectedCountry == null) {
        setState(() => _nationalityErr = true);
      } else {
        setState(() => _nationalityErr = false);
      }
      if (selectedGender == Gender.none) {
        setState(() => _genderErr = true);
      } else {
        setState(() => _genderErr = false);
      }
      return;
    }
    setState(() => _nameErr = _genderErr = _dobErr = _nationalityErr = false);
    //log('continue with save', name: 'profile_screen');
    logNestoCustom(message: 'continue with save', logType: LogType.debug);

    _save();
  }

  void setName(String value) => _name = value;

  changeGender(Gender gender) {
    //log('$gender', name: 'profile_screen');
    logNestoCustom(message: '$gender', logType: LogType.debug);

    setState(() => selectedGender = gender);
  }

  Future<void> _selectDate(BuildContext context) async {
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
    firebaseAnalytics.screenView(screenName: "Profile Screen");
    super.initState();
    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    magentoUser = authProvider.magentoUser;
    _name = magentoUser?.firstName;
    selectedGender = magentoUser?.gender;
    _currentSelectedCountry = COUNTRY_LIST.contains(magentoUser?.nationality)
        ? magentoUser?.nationality
        : null;
    if (magentoUser?.dob == null || magentoUser?.dob == '') {
      dob = '';
    } else {
      var date = DateTime.parse(magentoUser?.dob);
      DateFormat formatter = DateFormat('MMM dd,yyyy');
      var formattedDate = formatter.format(date);
      dob = formattedDate.toString();
      //log(selectedGender.toString(), name: 'editProfileCtx');
      logNestoCustom(
          message: selectedGender.toString(), logType: LogType.debug);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: headerBar(title: strings.MY_PROFILE, context: context),
        body: ConnectivityWidget(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(34.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: ScreenUtil().setHeight(20.0),
                ),
                TitleText(
                  title: strings.FULL_NAME,
                ),
                Container(
                  alignment: Alignment.center,
                  height: ScreenUtil().setHeight(68),
                  decoration: boxDecoration.copyWith(
                      border: Border.all(
                          color: _nameErr ? Colors.red : Colors.transparent)),
                  child: TextFormField(
                    textAlign: TextAlign.left,
                    style: textFieldStyle,
                    initialValue: magentoUser?.firstName ?? '--',
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        suffixIcon: Icon(
                          !_nameErr
                              ? Icons.check_circle_outline_outlined
                              : Icons.cancel_outlined,
                          color: !_nameErr
                              ? kGreyColor.withOpacity(0.6)
                              : Colors.red,
                          size: 20,
                        ),
                        contentPadding: EdgeInsets.only(
                            left: 15, bottom: 15, top: 14, right: 15)),
                    keyboardType: TextInputType.name,
                    onChanged: setName,
                    textInputAction: TextInputAction.done,
                  ),
                ),
                TitleText(title: strings.EMAIL),
                Container(
                  alignment: Alignment.centerLeft,
                  width: double.infinity,
                  height: ScreenUtil().setHeight(68),
                  padding: EdgeInsets.only(left: ScreenUtil().setWidth(17)),
                  decoration: boxDecoration.copyWith(
                    color: Colors.white,
                    border: Border.all(color: Color(0XFFF5F5F8)),
                  ),
                  child: Text(
                    magentoUser?.emailAddress ?? '--',
                    style: textFieldStyle,
                  ),
                ),
                TitleText(title: strings.PHONE),
                Container(
                  alignment: Alignment.centerLeft,
                  height: ScreenUtil().setHeight(68),
                  width: double.infinity,
                  padding: EdgeInsets.only(left: ScreenUtil().setWidth(17)),
                  decoration: boxDecoration.copyWith(
                      color: Colors.white,
                      border: Border.all(color: Color(0XFFF5F5F8))),
                  child: Text(
                    magentoUser?.phoneNumber ?? '--',
                    style: textFieldStyle,
                  ),
                ),
                TitleText(
                  title: strings.NATIONALITY,
                  err: _nationalityErr,
                  errText: strings.NATIONALITY_ERR,
                ),
                Container(
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
                      iconEnabledColor:
                          _nationalityErr ? Colors.red : values.NESTO_GREEN,
                      value: _currentSelectedCountry,
                      isDense: true,
                      onChanged: (String newValue) {
                        setState(() => _currentSelectedCountry = newValue);
                      },
                      hint: Text(
                        strings.SELECT_NATIONALITY,
                      ),
                      items: COUNTRY_LIST.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: SizedBox(
                              width: ScreenUtil().setWidth(260.0),
                              child: Text(value, maxLines: 1)),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                TitleText(
                  title: strings.DATE_OF_BIRTH,
                  err: _dobErr,
                  errText: strings.PLEASE_SELECT_DOB,
                ),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    height: ScreenUtil().setHeight(68),
                    padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(17)),
                    decoration: boxDecoration.copyWith(
                        border: Border.all(
                            color: _dobErr ? Colors.red : Colors.transparent)),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              dob == null || dob == ''
                                  ? strings.SELECT_DOB
                                  : dob,
                              style: dob == null || dob == ''
                                  ? placeholderTextStyle
                                  : TextStyle(
                                      color: Colors.black, fontSize: 16)),
                          SizedBox(
                            height: ScreenUtil().setHeight(20.0),
                          ),
                          Icon(
                            Icons.calendar_today_rounded,
                            color: !_dobErr
                                ? kGreyColor.withOpacity(0.6)
                                : Colors.red,
                            size: 22,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                TitleText(
                  title: strings.GENDER,
                  err: _genderErr,
                  errText: strings.PLEASE_SELECT_GENDER,
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
                SaveButton(onSave: _validate),
                SizedBox(height: ScreenUtil().setWidth(35)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SaveButton extends StatelessWidget {
  const SaveButton({
    Key key,
    @required this.onSave,
  }) : super(key: key);

  final Function onSave;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ScreenUtil().setWidth(61.86),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              primary: values.NESTO_GREEN,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.84))),
          onPressed: onSave,
          child: Center(
            child: Text(
              strings.SAVE,
              style: saveBtnStyle,
            ),
          )),
    );
  }
}

class TitleText extends StatelessWidget {
  const TitleText({
    Key key,
    @required this.title,
    this.errText,
    this.err,
  }) : super(key: key);

  final String title;
  final String errText;
  final bool err;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: ScreenUtil().setWidth(28),
        bottom: ScreenUtil().setWidth(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: titleTxt),
          Visibility(
              visible: err ?? false,
              child: Text(
                errText ?? '',
                style: errTextStyle,
              ))
        ],
      ),
    );
  }
}

//styles
var saveBtnStyle = TextStyle(
    fontSize: 17.67, fontWeight: FontWeight.w700, color: Colors.white);
var titleTxt =
    TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: Colors.grey);
var placeholderTextStyle = TextStyle(color: Colors.grey[700], fontSize: 16);
var greyColor = Color(0XFFBBBDC1).withOpacity(0.18);
var boxDecoration =
    BoxDecoration(color: greyColor, borderRadius: BorderRadius.circular(10));
var textFieldStyle = TextStyle(color: Colors.black, fontSize: 16);
var genderTextStyle = TextStyle(
    color: values.NESTO_GREEN, fontSize: 15, fontWeight: FontWeight.w600);
var errTextStyle = TextStyle(color: Colors.red, fontSize: 11);
Color kGreyColor = Color(0XFF525C67);
