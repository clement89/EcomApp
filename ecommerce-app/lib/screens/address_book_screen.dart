import 'package:Nesto/models/address.dart';
import 'package:Nesto/providers/auth_provider.dart';
import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/screens/add_address.dart';
import 'package:Nesto/screens/edit_address_screen.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/services/notification_service.dart';
import 'package:Nesto/strings.dart' as strings;
import 'package:Nesto/utils/util.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/widgets/headers.dart';
import 'package:Nesto/widgets/no_addresses_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class AddressBookScreen extends StatefulWidget {
  static String routeName = '/address_book_screen';

  @override
  _AddressBookScreenState createState() => _AddressBookScreenState();
}

class _AddressBookScreenState extends State<AddressBookScreen> {
  bool showSpinner;

  deleteAddress(int index) async {
    setState(() {
      showSpinner = true;
    });
    logNesto('delete address');
    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    var provider = Provider.of<StoreProvider>(context, listen: false);
    await authProvider.deleteAddressesFromMagento(index).then((value) {
      setState(() {
        showSpinner = false;
      });
    });
    provider.shippingAddress = null;
  }

  void editAddress(int index) {
    logNesto('edit address');
    Navigator.pushNamed(context, EditAddressScreen.routeName,
        arguments: {"index": index});
  }

  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "Address Book Screen");
    setState(() {
      showSpinner = false;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Screen Util
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);

    var authProvider = Provider.of<AuthProvider>(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: headerRow(
            context: context,
            rightIcon: Icons.add,
            rightIconSize: 25,
            onPressRightIcon: () =>
                Navigator.pushNamed(context, AddAddress.routeName),
            title: strings.ADDRESS_BOOK .toUpperCase(),
            iconBgColor: Colors.white,
            iconBorderColor: Color(0XFFB2B2B2)),
        body: Stack(
          children: [
            authProvider.magentoUser.addresses.length > 0
                ? Container(
                    height: double.infinity,
                    width: double.infinity,
                    padding: EdgeInsets.only(
                      left: ScreenUtil().setWidth(22.0),
                      right: ScreenUtil().setWidth(22.0),
                      top: ScreenUtil().setHeight(30.0),
                    ),
                    // color: Colors.green[100],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(strings.SAVED_ADDRESS,
                            style: TextStyle(
                                fontFamily: 'assets/fonts/sf_pro_display.ttf',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF000000),
                                fontStyle: FontStyle.normal)),
                        SizedBox(
                          height: ScreenUtil().setHeight(19.0),
                        ),
                        Expanded(
                          child: ListView.separated(
                            itemCount:
                                authProvider.magentoUser.addresses.length,
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return SizedBox(
                                  height: ScreenUtil().setHeight(19.0));
                            },
                            itemBuilder: (BuildContext context, int index) {
                              Address item =
                                  authProvider.magentoUser.addresses[index];
                              return Container(
                                padding: EdgeInsets.only(
                                  left: ScreenUtil().setWidth(10.0),
                                  right: ScreenUtil().setWidth(46.0),
                                  top: ScreenUtil().setHeight(15.0),
                                  bottom: ScreenUtil().setHeight(15.0),
                                ),
                                decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Color(0XFFF2F2F2))),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //name
                                    Text(
                                      item.name,
                                      style: TextStyle(
                                          fontFamily:
                                              'assets/fonts/sf_pro_display.ttf',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF000000),
                                          fontStyle: FontStyle.normal),
                                    ),
                                    SizedBox(
                                      height: ScreenUtil().setHeight(5.0),
                                    ),
                                    //address
                                    Container(
                                      width: double.infinity,
                                      child: Text(
                                        item.street,
                                        style: TextStyle(
                                            fontFamily:
                                                'assets/fonts/sf_pro_display.ttf',
                                            color: Color(0XFF010202),
                                            fontSize: 15,
                                            fontWeight: FontWeight.w300,
                                            fontStyle: FontStyle.normal),
                                      ),
                                    ),
                                    SizedBox(
                                      height: ScreenUtil().setHeight(19.0),
                                    ),
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () => editAddress(index),
                                          child: Container(
                                            width: ScreenUtil().setWidth(76),
                                            height: ScreenUtil().setHeight(25),
                                            decoration: BoxDecoration(
                                                color: values.NESTO_GREEN,
                                                borderRadius:
                                                    BorderRadius.circular(5.9)),
                                            child: Center(
                                              child: Text(
                                                strings.EDIT,
                                                style: TextStyle(
                                                    fontFamily:
                                                        'assets/fonts/sf_pro_display.ttf',
                                                    fontSize: 12.0,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: ScreenUtil().setWidth(12),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            notificationServices.showCustomDialog(
                                                title: strings.DELETE_ADDRESS,
                                                description: strings.DELETE_ADDRESS_DESCRIPTION,
                                                negativeText: strings.CANCEL,
                                                positiveText: strings.DELETE_WITH_CAP_D,
                                                action: () => deleteAddress(index));
                                          },
                                          child: Container(
                                            width: ScreenUtil().setWidth(76),
                                            height: ScreenUtil().setHeight(25),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(
                                                    color: Color(0XFFC71712)),
                                                borderRadius:
                                                    BorderRadius.circular(5.9)),
                                            child: Center(
                                              child: Text(
                                                strings.DELETE_WITH_CAP_D,
                                                style: TextStyle(
                                                    fontFamily:
                                                        'assets/fonts/sf_pro_display.ttf',
                                                    color: Color(0XFFC71712),
                                                    fontSize: 12.0,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(color: Colors.white, child: NoAddressesWidget()),
            showSpinner
                ? Center(
                    child: CircularProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation<Color>(
                            values.NESTO_GREEN)))
                : Container()
          ],
        ),
      ),
    );
  }
}
