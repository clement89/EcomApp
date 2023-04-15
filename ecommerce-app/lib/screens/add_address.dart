import 'dart:async';
import 'dart:convert';

import 'package:Nesto/models/address.dart';
import 'package:Nesto/providers/auth_provider.dart';
import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/screens/location_screen.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/utils/formatters/address_field_formatter.dart';
import 'package:Nesto/utils/util.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/widgets/connectivity_widget.dart';
import 'package:Nesto/widgets/headers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:Nesto/strings.dart' as strings;
import '../widgets/edge_cases/connection_lost.dart';

class AddAddress extends StatefulWidget {
  static String routeName = '/add_address';

  @override
  _AddAddressState createState() => _AddAddressState();
}

class _AddAddressState extends State<AddAddress> {
  bool showSpinner;

  //key
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  var _countries = ['UAE'];
  var _emirates = [
    'Abu Dhabi',
    'Dubai',
    'Sharjah',
    'Umm al-Qaiwain',
    'Fujairah',
    'Ajman',
    "Ra's al-Khaimah"
  ];
  String _emirate = storeCode == 'en_ajh'
      ? 'Ajman'
      : storeCode == "en_abu"
          ? 'Sharjah'
          : 'Dubai';

  String _name,
      _phoneNumber,
      _email,
      _selectedLocation,
      _appartment,
      _buildingName,
      _buildingBlock,
      _streetName;
  bool nameErr = false;
  bool phoneErr = false;
  bool emailErr = false;
  bool countryErr = false;
  bool emirateErr = false;
  bool locationErr = false;
  bool appartmentErr = false;
  bool buildingNameErr = false;
  bool buildingBlockErr = false;
  bool streetNameErr = false;

  bool zipErr = false;
  String _currentSelectedCountry = 'UAE';
  double latitude, longitude;

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  TextEditingController appartmentController = TextEditingController();
  TextEditingController buildingNameController = TextEditingController();
  TextEditingController buildingBlockController = TextEditingController();
  TextEditingController streetNameController = TextEditingController();

  // List<TextEditingController> controllers = [
  //   phoneController,
  //   nameController,
  //   addressController,
  //   zipcodeController,
  //   emailController,
  //   emiratesController
  // ];

  void setName(text) => _name = text;

  void setPhone(text) => _phoneNumber = text;

  void setEmirates(text) => _emirates = text;

  void setEmail(text) => _email = text;

  void setAppartment(text) => _appartment = text;
  void setBuildingName(text) => _buildingName = text;
  void setBuildingBlock(text) => _buildingBlock = text;
  void setStreetName(text) => _streetName = text;

  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "Add Address Screen");
    setState(() {
      showSpinner = false;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Screen Util Init
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);

    //Auth provider
    var authProvider = Provider.of<AuthProvider>(context);
    var storeProvider = Provider.of<StoreProvider>(context);

    Future _saveAddress() async {
      logNesto("ADDRESS ADDED");
      logNesto("$_appartment\n$_buildingName\n$_buildingBlock\n$_streetName");
      var address = Address(
          name: _name,
          telephone: _phoneNumber,
          region: _currentSelectedCountry,
          city: _emirate,
          street:
              "${_appartment?.trim()}\n${_buildingName.trim()}\n${_buildingBlock.trim()}\n${_streetName.trim()}",
          email: _email,
          latitude: latitude,
          longitude: longitude,
          location: _selectedLocation);
      await authProvider.addNewAddressToMagento(address, context).then((value) {
        setState(() {
          showSpinner = false;
        });
      });
    }

    void _validate() async {
      if (showSpinner == false) {
        var isNameEmpty = nameController.text.isEmpty;
        var isPhoneValid = phoneController.text.isValidPhone();
        var isEmailValid = emailController.text.isValidEmail();
        var isAppartmentEmpty = appartmentController.text.isEmpty;
        var isBuildingNameEmpty = buildingNameController.text.isEmpty;
        var isBuildingBlockEmpty = buildingBlockController.text.isEmpty;
        var isStreetNameEmpty = streetNameController.text.isEmpty;
        var isLocationEmpty = _selectedLocation?.isEmpty ?? true;
        if (isNameEmpty ||
            !isEmailValid ||
            isAppartmentEmpty ||
            isBuildingNameEmpty ||
            isBuildingBlockEmpty ||
            isStreetNameEmpty ||
            !isPhoneValid ||
            isLocationEmpty) {
          if (!isPhoneValid) {
            setState(() {
              phoneErr = true;
            });
          } else {
            setState(() {
              phoneErr = false;
            });
          }
          setState(() {
            nameErr = isNameEmpty;
          });
          if (!isEmailValid) {
            setState(() {
              emailErr = true;
            });
          } else {
            setState(() {
              emailErr = false;
            });
          }
          if (isAppartmentEmpty) {
            setState(() {
              appartmentErr = true;
            });
          } else {
            setState(() {
              appartmentErr = false;
            });
          }
          if (isBuildingNameEmpty) {
            setState(() {
              buildingNameErr = true;
            });
          } else {
            setState(() {
              buildingNameErr = false;
            });
          }
          if (isBuildingBlockEmpty) {
            setState(() {
              buildingBlockErr = true;
            });
          } else {
            setState(() {
              buildingBlockErr = false;
            });
          }
          if (isStreetNameEmpty) {
            setState(() {
              streetNameErr = true;
            });
          } else {
            setState(() {
              streetNameErr = false;
            });
          }

          setState(() {
            locationErr = isLocationEmpty;
          });

          showError(
              context, strings.PLEASE_VALIDATE_THE_DETAILS_YOU_HAVE_ENETERED);
          return;
        }
        setState(() {
          nameErr = phoneErr = emailErr = zipErr = appartmentErr =
              buildingNameErr =
                  buildingBlockErr = streetNameErr = locationErr = false;
          showSpinner = true;
        });
        await _saveAddress();
      }
    }

    void handleLocationClick() => Navigator.pushNamed(
          context,
          LocationScreen.routeName,
          arguments: AddAddress.routeName,
        ).then((value) {
          var decoded = jsonDecode(value);
          setState(() {
            _selectedLocation = decoded['value'];
          });
          this.latitude = decoded['lat'];
          this.longitude = decoded['lng'];
        });
    Future<bool> _willPopCallback() async {
      Navigator.pop(context, true);
    }

    return SafeArea(
      child: WillPopScope(
        onWillPop: _willPopCallback,
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          appBar: headerBar(
              title: strings.ADD_ADDRESS,
              context: context,
              onBackPress: () {
                Navigator.pop(context, true);
              }),
          body: ConnectivityWidget(
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
                  child: Container(
                    height: double.infinity,
                    width: double.infinity,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(34.0)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          titleText(
                              title: strings.NAME,
                              isError: nameErr,
                              errText: strings.NAME_CANNOT_BE_EMPTY),
                          CustomTextField(
                            onChange: setName,
                            keyboardType: TextInputType.name,
                            controller: nameController,
                            error: nameErr,
                          ),
                          titleText(
                              title: strings.PHONE_NUMBER,
                              isError: phoneErr,
                              errText: strings.PLEASE_ENTER_VALID_PHONE),
                          CustomTextField(
                            onChange: setPhone,
                            keyboardType: TextInputType.phone,
                            controller: phoneController,
                            error: phoneErr,
                          ),
                          titleText(
                              title: strings.EMAIL,
                              isError: emailErr,
                              errText: strings.PLEASE_ENTER_VALID_EMAIL),
                          CustomTextField(
                            onChange: setEmail,
                            keyboardType: TextInputType.emailAddress,
                            controller: emailController,
                            error: emailErr,
                          ),
                          titleText(title: strings.COUNTRY),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil().setWidth(17.0),
                              vertical: ScreenUtil().setHeight(14.0),
                            ),
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Color(0XFFBBBDC1).withOpacity(0.18),
                                borderRadius: BorderRadius.circular(8.0)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                iconSize: 30,
                                iconDisabledColor: values.NESTO_GREEN,
                                iconEnabledColor: values.NESTO_GREEN,
                                value: _currentSelectedCountry,
                                isDense: true,
                                onChanged: (String newValue) {
                                  setState(() {
                                    _currentSelectedCountry = newValue;
                                  });
                                },
                                items: _countries.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          titleText(title: strings.EMIRITES),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil().setWidth(17.0),
                              vertical: ScreenUtil().setHeight(14.0),
                            ),
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Color(0XFFBBBDC1).withOpacity(0.18),
                                borderRadius: BorderRadius.circular(8.0)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                iconSize: 30,
                                iconDisabledColor: values.NESTO_GREEN,
                                iconEnabledColor: values.NESTO_GREEN,
                                value: _emirate,
                                isDense: true,
                                onChanged: (String newValue) {
                                  setState(() {
                                    _emirate = newValue;
                                  });
                                },
                                items: _emirates.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          titleText(
                              title: strings.LOCATION,
                              isError: locationErr,
                              errText: strings.LOCATION_FIELD_CANNOT_BE_EMPTY),
                          GestureDetector(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: ScreenUtil().setWidth(17.0),
                                vertical: ScreenUtil().setHeight(14.0),
                              ),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                    color: Color(0XFFF5F5F8), width: 1),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _selectedLocation ??
                                          strings.SELECT_LOCATION,
                                      style: TextStyle(
                                          color: Color(_selectedLocation == null
                                              ? 0XFFB2B2B2
                                              : 0XFF000000)),
                                    ),
                                  ),
                                  Icon(
                                    Icons.gps_fixed,
                                    color: Color(0XFF00983D),
                                    size: 24,
                                  ),
                                ],
                              ),
                            ),
                            onTap: handleLocationClick,
                          ),
                          titleText(
                              title: strings.APPARTMENT,
                              isError: appartmentErr,
                              errText: strings.APPARTMENT_ERROR),
                          CustomTextField(
                            onChange: setAppartment,
                            controller: appartmentController,
                            error: appartmentErr,
                          ),
                          titleText(
                              title: strings.BUILDING_NAME,
                              isError: buildingNameErr,
                              errText: strings.BUILDING_NAME_ERROR),
                          CustomTextField(
                            onChange: setBuildingName,
                            controller: buildingNameController,
                            error: buildingNameErr,
                          ),
                          titleText(
                              title: strings.BUILDING_BLOCK,
                              isError: buildingBlockErr,
                              errText: strings.BUILDING_BLOCK_ERROR),
                          CustomTextField(
                            onChange: setBuildingBlock,
                            controller: buildingBlockController,
                            error: buildingBlockErr,
                          ),
                          titleText(
                              title: strings.STREET_NAME,
                              isError: streetNameErr,
                              errText: strings.STREET_NAME_ERROR),
                          CustomTextField(
                            onChange: setStreetName,
                            controller: streetNameController,
                            error: streetNameErr,
                          ),
                          SizedBox(
                            height: ScreenUtil().setHeight(45.0),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Material(
                              color: values.NESTO_GREEN,
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.84)),
                              child: MaterialButton(
                                height: ScreenUtil().setHeight(61.86),
                                onPressed: _validate,
                                child: Center(
                                  child: Text(
                                    strings.SAVE_ADDRESS,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17.67,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: ScreenUtil().setHeight(34.14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                showSpinner
                    ? Center(
                        child: CircularProgressIndicator(
                            valueColor: new AlwaysStoppedAnimation<Color>(
                                values.NESTO_GREEN)))
                    : Container()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding titleText({String title, bool isError, String errText}) {
    return Padding(
      padding: EdgeInsets.only(
          top: ScreenUtil().setHeight(24.0),
          bottom: ScreenUtil().setHeight(8.0)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0XFF666666)),
          ),
          Visibility(
            visible: isError ?? false,
            child: Text(
              errText ?? '',
              style: TextStyle(color: Colors.red, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    Key key,
    this.height,
    this.maxLine,
    this.hintText,
    this.onChange,
    this.keyboardType,
    this.controller,
    this.error,
  }) : super(key: key);

  final double height;
  final String hintText;
  final int maxLine;
  final ValueChanged onChange;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final bool error;

  @override
  Widget build(BuildContext context) {
    //Screen Util Init
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);
    return Container(
      height: ScreenUtil().setWidth(height ?? 48),
      decoration: BoxDecoration(
          color: Color(0XFFBBBDC1).withOpacity(0.18),
          border: Border.all(color: error ? Colors.red : Colors.transparent),
          borderRadius: BorderRadius.circular(8.0)),
      width: double.infinity,
      child: TextFormField(
        textInputAction: keyboardType == TextInputType.multiline
            ? TextInputAction.newline
            : TextInputAction.done,
        controller: controller,
        keyboardType: keyboardType ?? TextInputType.name,
        minLines: 1,
        //maxLength: 100,
        maxLines: maxLine ?? null,
        inputFormatters: [MaxLinesTextInputFormatter(4)],
        onChanged: onChange,
        cursorColor: Colors.black,
        decoration: InputDecoration(
          // counterText: '',
          hintText: hintText ?? '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(left: ScreenUtil().setWidth(17.0)),
        ),
      ),
    );
  }
}

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
