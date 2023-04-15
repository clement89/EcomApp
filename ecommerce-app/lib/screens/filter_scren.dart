
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/widgets/connectivity_widget.dart';
import 'package:Nesto/widgets/headers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../values.dart' as values;

class FilterScreen extends StatefulWidget {
  static String routeName = '/filter_screen';
  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  List<String> prices = ['100-200', '200-300', '300-400', '400-500', '500-600'];

  int selectedIndex = 0;

  var _brands = ["Nestle", "Milma", "Puma", "Addidas", "Nike", "Hubblot"];

  var _countries = ['India', 'UAE', 'USA', 'Japan'];
  String _currentSelectedValue = "Nestle";
  String _currentCountry = 'UAE';
  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "Filter Screen");
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    // /Screen Util
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: headerBar(title: 'fiters', context: context),
        body:ConnectivityWidget(
          child: Container(
            height: double.infinity,
            width: double.infinity,
            // color: Colors.green[100],
            padding: EdgeInsets.only(
                top: ScreenUtil().setHeight(45.0),
                bottom: ScreenUtil().setHeight(23.0),
                left: ScreenUtil().setWidth(24.0),
                right: ScreenUtil().setWidth(30.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    titleText('Price'),
                    Container(
                      margin: EdgeInsets.only(left: ScreenUtil().setWidth(14.0)),
                      height: ScreenUtil().setHeight(17.14),
                      width: ScreenUtil().setWidth(40.0),
                      decoration: BoxDecoration(
                          border: Border.all(color: values.NESTO_GREEN),
                          borderRadius: BorderRadius.circular(2.54)),
                      child: Center(
                        child: Text(
                          'AED',
                          style: TextStyle(
                              fontSize: 8.89,
                              color: values.NESTO_GREEN,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(19.0),
                ),
                Wrap(
                  alignment: WrapAlignment.start,
                  spacing: ScreenUtil().setWidth(12.0),
                  runSpacing: ScreenUtil().setHeight(12.0),
                  children: List.generate(
                    prices.length,
                    (index) => GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      child: Container(
                        height: ScreenUtil().setHeight(33.8),
                        width: ScreenUtil().setWidth(78.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3.47),
                            color: index == selectedIndex
                                ? values.NESTO_GREEN
                                : Color(0XFFF5F5F8)),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              prices[index],
                              style: TextStyle(
                                  color: index == selectedIndex
                                      ? Colors.white
                                      : Color(0XFF898B9A)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(37.4),
                ),
                Divider(),
                SizedBox(
                  height: ScreenUtil().setHeight(20.0),
                ),
                titleText('Brand'),
                SizedBox(
                  height: ScreenUtil().setHeight(19.0),
                ),
                FormField<String>(
                  builder: (FormFieldState<String> state) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(19.0),
                        vertical: ScreenUtil().setHeight(19.0),
                      ),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          iconSize: 30,
                          iconDisabledColor: values.NESTO_GREEN,
                          iconEnabledColor: values.NESTO_GREEN,
                          value: _currentSelectedValue,
                          isDense: true,
                          onChanged: (String newValue) {
                            setState(() {
                              _currentSelectedValue = newValue;
                              state.didChange(newValue);
                            });
                          },
                          items: _brands.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(31.0),
                ),
                Divider(),
                SizedBox(
                  height: ScreenUtil().setHeight(31.0),
                ),
                titleText('Country'),
                SizedBox(
                  height: ScreenUtil().setHeight(19.0),
                ),
                FormField<String>(
                  builder: (FormFieldState<String> state) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(19.0),
                        vertical: ScreenUtil().setHeight(19.0),
                      ),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          iconSize: 30,
                          iconDisabledColor: values.NESTO_GREEN,
                          iconEnabledColor: values.NESTO_GREEN,
                          value: _currentCountry,
                          isDense: true,
                          onChanged: (String newValue) {
                            setState(() {
                              _currentCountry = newValue;
                              state.didChange(newValue);
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
                    );
                  },
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      children: [
                        Container(
                          height: ScreenUtil().setHeight(56),
                          width: ScreenUtil().setWidth(138),
                          decoration: BoxDecoration(
                              border: Border.all(color: values.NESTO_GREEN),
                              borderRadius: BorderRadius.circular(8.83)),
                          child: Center(
                            child: Text(
                              'Clear',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: values.NESTO_GREEN),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(
                                left: ScreenUtil().setWidth(10.0)),
                            height: ScreenUtil().setHeight(56.0),
                            decoration: BoxDecoration(
                                color: values.NESTO_GREEN,
                                borderRadius: BorderRadius.circular(8.84)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Apply',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      left: ScreenUtil().setWidth(5.0)),
                                  height: ScreenUtil().setHeight(20),
                                  width: ScreenUtil().setWidth(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6.67),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '2',
                                      style: TextStyle(
                                          color: values.NESTO_GREEN,
                                          fontSize: 11.67,
                                          fontWeight: FontWeight.w700),
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Text titleText(text) {
    return Text(
      text,
      style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),
    );
  }
}

//styles
const labelTextStyle = TextStyle(fontSize: 13.87, fontWeight: FontWeight.w500);
