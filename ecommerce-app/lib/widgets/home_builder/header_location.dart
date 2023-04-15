import 'dart:async';

import 'package:Nesto/extensions/number_extension.dart';
import 'package:Nesto/providers/auth_provider.dart';
import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/screens/location_screen.dart';
import 'package:Nesto/strings.dart' as strings;
import 'package:Nesto/utils/style.dart';
import 'package:Nesto/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HeaderLocationWidget extends StatefulWidget {
  final bool showInnam;
  HeaderLocationWidget({
    this.showInnam = true,
  });

  @override
  _HeaderLocationWidgetState createState() => _HeaderLocationWidgetState();
}

class _HeaderLocationWidgetState extends State<HeaderLocationWidget> {
  // final GlobalKey _selectZone = const GlobalObjectKey("selectZone");

  String place;

  @override
  void initState() {
    getInaam();
    Future.delayed(Duration.zero, () async {
      SharedPreferences encryptedSharedPreferences =
          await SharedPreferences.getInstance();

      setState(() {
        place = encryptedSharedPreferences.getString('userlocationname') ?? "";
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print('showCoachMarkTile - ${widget.showOverlay}}');

    //Screen Util Init
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);
    var size = MediaQuery.of(context).size;

    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 0.5, color: Colors.black12),
                ),
                color: Colors.white, //values.NESTO_GREEN.withOpacity(0.2),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(20.0), vertical: 8),
                child: Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        // key: _selectZone,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            flex: 3,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: Colors.black,
                                ),
                                SizedBox(width: 10),
                                InkWell(
                                  onTap: () {
                                    //firebaseAnalytics
                                    //    .homeScreenLocationClicked();
                                    Navigator.pushNamed(
                                      context,
                                      LocationScreen.routeName,
                                      arguments: null,
                                    );
                                  },
                                  child: Container(
                                    // constraints: BoxConstraints(
                                    //     maxWidth: size.width * 0.3),
                                    child: SizedBox(
                                      width: size.width * 0.37,
                                      child: Text(
                                        place == null || place.isEmpty
                                            ? 'Select location'
                                            : place,
                                        style: textStyleVerySmall.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 2,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Next delivery in ',
                                  style: textStyleVerySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  context
                                      .watch<StoreProvider>()
                                      .nextTimeSlotInHours,
                                  style: TextStyle(
                                    color: Color(0XFF111A2C),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Container(
            //   height: 50,
            //   decoration: BoxDecoration(
            //     // border: Border(
            //     //   bottom: BorderSide(width: 0.5, color: Colors.black12),
            //     // ),
            //     color: Colors.white, //values.NESTO_GREEN.withOpacity(0.2),
            //   ),
            //   child: Padding(
            //     padding: EdgeInsets.symmetric(
            //         horizontal: ScreenUtil().setWidth(20.0), vertical: 8),
            //     child: Row(
            //       //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         Expanded(
            //           child: Row(
            //             mainAxisAlignment: MainAxisAlignment.start,
            //             crossAxisAlignment: CrossAxisAlignment.center,
            //             children: [
            //               Icon(
            //                 Icons.delivery_dining,
            //                 size: 18,
            //                 color: Colors.black,
            //               ),
            //               SizedBox(width: 10),
            //               Container(
            //                 constraints:
            //                     BoxConstraints(maxWidth: size.width * 0.80),
            //                 child: Text(
            //                   'Delivery',
            //                   style: textStyleBig.copyWith(
            //                       fontWeight: FontWeight.w300),
            //                   maxLines: 1,
            //                   overflow: TextOverflow.ellipsis,
            //                 ),
            //               ),
            //               Spacer(),
            //               Text(
            //                 context
            //                     .watch<TimeSlotProvider>()
            //                     .nextAvailableTimeSlot,
            //                 style: TextStyle(
            //                   color: Color(0XFF111A2C),
            //                   fontSize: 12,
            //                   fontWeight: FontWeight.w500,
            //                 ),
            //                 maxLines: 1,
            //                 overflow: TextOverflow.ellipsis,
            //               ),
            //             ],
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            _buildInnamPointe(),
          ],
        ),
      ),
    );
  }

  Widget _buildInnamPointe() {
    if (!isAuthTokenValid() || !widget.showInnam) {
      return SizedBox(height: 0);
    }
    double inaamInAed = 0;
    var authProvider = Provider.of<AuthProvider>(context, listen: true);

    if ((authProvider.inaamCode != null) &&
        (authProvider.inaamPointsLifeTime != null)) {
      setState(() {
        inaamInAed = getInaamInAed(authProvider.inaamPoints);
      });
    } else {
      return Container();
    }

    if (inaamInAed == 0) {
      return Container();
    }

    return Container(
      height: 60,
      decoration: BoxDecoration(
        // border: Border(
        //   bottom: BorderSide(width: 0.5, color: Colors.black12),
        // ),
        color: Colors.black87, //values.NESTO_GREEN.withOpacity(0.2),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setWidth(20.0), vertical: 8),
        child: Row(
          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20,
                    child: Image.asset(
                      'assets/images/coin.png',
                    ),
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        authProvider.inaamPoints.twoDecimal() ?? '0.0',
                        style:
                            textStyleNormal.copyWith(color: Color(0XFFE8B971)),
                      ),
                      Text(
                        'INNAM POINTS',
                        style: textStyleSmall.copyWith(
                            fontWeight: FontWeight.w200, color: Colors.white),
                      ),
                    ],
                  ),
                  Spacer(),
                  SizedBox(
                    height: 20,
                    child: Image.asset(
                      'assets/images/cash.png',
                    ),
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'AED ' + inaamInAed.twoDecimal() ?? '0.0',
                        style:
                            textStyleNormal.copyWith(color: Color(0XFFE8B971)),
                      ),
                      Text(
                        'Current Balance',
                        style: textStyleSmall.copyWith(
                            fontWeight: FontWeight.w200, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void getInaam() async {
    try {
      var authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (isAuthTokenValid() && authProvider.magentoUser != null) {
        //init is being called multiple times dont call if already called.
        authProvider
            .getInaamPointsCall(shouldNotify: false)
            .then((value) async {
          if (authProvider.showInaamRetryButton) {
            showError(context,
                strings.COULD_NOT_FETCH_INAAM_DETAILS_PLEASE_TRY_AGAIN);
          }
        });
      }
      if (isAuthTokenValid()) {
        if (authProvider.magentoUser == null) {
          await authProvider.fetchMagentoUser();
          authProvider
              .getInaamPointsCall(shouldNotify: false)
              .then((value) async {
            if (authProvider.showInaamRetryButton) {
              showError(context,
                  strings.COULD_NOT_FETCH_INAAM_DETAILS_PLEASE_TRY_AGAIN);
            }
          });
        } else if (authProvider.magentoUser != null) {
          authProvider
              .getInaamPointsCall(shouldNotify: false)
              .then((value) async {
            if (authProvider.showInaamRetryButton) {
              showError(context,
                  strings.COULD_NOT_FETCH_INAAM_DETAILS_PLEASE_TRY_AGAIN);
            }
          });
        }
      }
    } catch (e) {
      Future.delayed(Duration(milliseconds: 100), () {
        showError(context, strings.SOMETHING_WENT_WRONG_RETRY);
      });
    }

    setState(() {});
  }
}
