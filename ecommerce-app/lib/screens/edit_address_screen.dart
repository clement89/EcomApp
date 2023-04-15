import 'dart:convert';

import 'package:Nesto/models/address.dart';
import 'package:Nesto/models/user.dart';
import 'package:Nesto/providers/auth_provider.dart';
import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/screens/location_screen.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/utils/formatters/address_field_formatter.dart';
import 'package:Nesto/utils/util.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/widgets/headers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:Nesto/strings.dart' as strings;

class EditAddressScreen extends StatefulWidget {
  static String routeName = '/edit_address';
  @override
  _EditAddressScreenState createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  bool showSpinner;
  int index;
  User magentoUser;
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
  String _emirate;

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

  void setName(text) => _name = text;

  void setPhone(text) => _phoneNumber = text;

  void setAppartment(text) => _appartment = text;
  void setBuildingName(text) => _buildingName = text;
  void setBuildingBlock(text) => _buildingBlock = text;
  void setStreetName(text) => _streetName = text;

  void setEmirates(text) => _emirates = text;

  void setEmail(text) => _email = text;
  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "Edit Address Screen");
    setState(() {
      showSpinner = false;
    });
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    final Map<String, Object> indexFromArgument =
        ModalRoute.of(context).settings.arguments;
    setState(() {
      index = indexFromArgument["index"];
    });
    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    magentoUser = authProvider.magentoUser;
    if (_name == null) {
      _name = magentoUser?.addresses[index].name;
      _phoneNumber = magentoUser?.addresses[index].telephone;
      List<String> addressSplit =
          magentoUser?.addresses[index].street?.split('\n');
      addressSplit =
          addressSplit.where((element) => element.trim() != '').toList();
      if (addressSplit.length < 4) {
        addressSplit.addAll(List.filled(4 - addressSplit.length, ""));
      } else if (addressSplit.length > 4) {
        String _combinedField = addressSplit.sublist(3).join(" ");
        addressSplit = addressSplit.sublist(0, 3);
        addressSplit.add(_combinedField);
      }
      if (addressSplit.length == 4) {
        _appartment = addressSplit[0]?.trim();
        _buildingName = addressSplit[1]?.trim();
        _buildingBlock = addressSplit[2]?.trim();
        _streetName = addressSplit[3]?.trim();
      } else {
        _appartment = "";
        _buildingName = "";
        _buildingBlock = "";
        _streetName = "";
      }
      _email = magentoUser?.addresses[index].email;
      _emirate = magentoUser?.addresses[index].city;
      _selectedLocation = (magentoUser?.addresses[index].location) != null
          ? (magentoUser?.addresses[index].location)
          : null;
      latitude = (magentoUser?.addresses[index].latitude) != null
          ? (magentoUser?.addresses[index].latitude)
          : null;
      longitude = (magentoUser?.addresses[index].longitude) != null
          ? (magentoUser?.addresses[index].longitude)
          : null;
    }
    super.didChangeDependencies();
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
      storeProvider.shippingAddress = null;
      await authProvider
          .updateAddressInMagento(index, address, context)
          .then((value) {
        setState(() {
          showSpinner = false;
        });
      });
    }

    void _validate() async {
      if (showSpinner == false) {
        var isNameEmpty = _name.isEmpty;
        var isPhoneValid = _phoneNumber.isValidPhoneEdit();
        var isEmailValid = _email.isValidEmailEdit();
        var isAppartmentEmpty = _appartment.isEmpty;
        var isBuildingNameEmpty = _buildingName.isEmpty;
        var isBuildingBlockEmpty = _buildingBlock.isEmpty;
        var isStreetNameEmpty = _streetName.isEmpty;
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
          arguments: EditAddressScreen.routeName,
        ).then((value) {
          var decoded = jsonDecode(value);
          setState(() {
            _selectedLocation = decoded['value'];
          });
          this.latitude = decoded['lat'];
          this.longitude = decoded['lng'];
        });

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: headerBar(title: strings.EDIT_ADDRESS, context: context),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: Stack(
            children: [
              Container(
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
                      CustomTextFieldEditPage(
                        initialValue: _name,
                        onChange: setName,
                        keyboardType: TextInputType.name,
                        error: nameErr,
                      ),
                      titleText(
                          title: strings.PHONE_NUMBER,
                          isError: phoneErr,
                          errText: strings.PLEASE_ENTER_VALID_PHONE),
                      CustomTextFieldEditPage(
                        initialValue: _phoneNumber,
                        onChange: setPhone,
                        keyboardType: TextInputType.phone,
                        error: phoneErr,
                      ),
                      titleText(
                          title: strings.EMAIL,
                          isError: emailErr,
                          errText: strings.PLEASE_ENTER_VALID_EMAIL),
                      CustomTextFieldEditPage(
                        initialValue: _email,
                        onChange: setEmail,
                        keyboardType: TextInputType.emailAddress,
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
                            border:
                                Border.all(color: Color(0XFFF5F5F8), width: 1),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _selectedLocation != null
                                      ? _selectedLocation
                                      : (latitude != null && longitude != null)
                                          ? "$latitude' $longitude'"
                                          : strings.SELECT_LOCATION,
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
                      CustomTextFieldEditPage(
                        initialValue: _appartment,
                        onChange: setAppartment,
                        error: appartmentErr,
                      ),
                      titleText(
                          title: strings.BUILDING_NAME,
                          isError: buildingNameErr,
                          errText: strings.BUILDING_NAME_ERROR),
                      CustomTextFieldEditPage(
                        initialValue: _buildingName,
                        onChange: setBuildingName,
                        error: buildingNameErr,
                      ),
                      titleText(
                          title: strings.BUILDING_BLOCK,
                          isError: buildingBlockErr,
                          errText: strings.BUILDING_BLOCK_ERROR),
                      CustomTextFieldEditPage(
                        initialValue: _buildingBlock,
                        onChange: setBuildingBlock,
                        error: buildingBlockErr,
                      ),
                      titleText(
                          title: strings.STREET_NAME,
                          isError: streetNameErr,
                          errText: strings.STREET_NAME_ERROR),
                      CustomTextFieldEditPage(
                        initialValue: _streetName,
                        onChange: setStreetName,
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
              showSpinner == true
                  ? Center(
                      child: CircularProgressIndicator(
                          valueColor: new AlwaysStoppedAnimation<Color>(
                              values.NESTO_GREEN)))
                  : Container()
            ],
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

class CustomTextFieldEditPage extends StatefulWidget {
  const CustomTextFieldEditPage(
      {Key key,
      this.height,
      this.maxLine,
      this.hintText,
      this.onChange,
      this.keyboardType,
      this.error,
      this.initialValue})
      : super(key: key);

  final double height;
  final String hintText;
  final int maxLine;
  final ValueChanged onChange;
  final TextInputType keyboardType;
  final bool error;
  final String initialValue;
  @override
  _CustomTextFieldEditPageState createState() =>
      _CustomTextFieldEditPageState();
}

class _CustomTextFieldEditPageState extends State<CustomTextFieldEditPage> {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);
    return Container(
      height: ScreenUtil().setWidth(widget.height ?? 48),
      decoration: BoxDecoration(
          color: Color(0XFFBBBDC1).withOpacity(0.18),
          border:
              Border.all(color: widget.error ? Colors.red : Colors.transparent),
          borderRadius: BorderRadius.circular(8.0)),
      width: double.infinity,
      child: TextFormField(
        textInputAction: widget.keyboardType == TextInputType.multiline
            ? TextInputAction.newline
            : TextInputAction.done,
        initialValue: widget.initialValue,
        keyboardType: widget.keyboardType ?? TextInputType.name,
        minLines: 1,
        maxLines: widget.maxLine ?? null,
        inputFormatters: [MaxLinesTextInputFormatter(4)],
        onChanged: widget.onChange,
        cursorColor: Colors.black,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(left: ScreenUtil().setWidth(17.0)),
        ),
      ),
    );
  }
}

extension EmailValidatorEdit on String {
  bool isValidEmailEdit() {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(this);
  }
}

extension NameValidatorEdit on String {
  bool isValidNameEdit() {
    return RegExp(r"^[a-zA-Z]+(([',. -][a-zA-Z ])?[a-zA-Z]*)*$").hasMatch(this);
  }
}

extension PhoneValidatorEdit on String {
  bool isValidPhoneEdit() {
    return RegExp(r'(^(?:[+0]9)?[0-9]{10,16}$)').hasMatch(this);
  }
}
