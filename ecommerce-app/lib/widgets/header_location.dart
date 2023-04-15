import 'package:Nesto/strings.dart' as strings;
import 'package:Nesto/utils/util.dart';
import 'package:Nesto/values.dart' as values;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HeaderLocationWidget extends StatefulWidget {
  final bool showNotificationBell;

  HeaderLocationWidget({@required this.showNotificationBell});

  @override
  _HeaderLocationWidgetState createState() => _HeaderLocationWidgetState();
}

class _HeaderLocationWidgetState extends State<HeaderLocationWidget> {
  String place;
  bool showNotificationBellIcon;

  @override
  void initState() {
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
    //Screen Util Init
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);
    var size = MediaQuery.of(context).size;

    setState(() {
      showNotificationBellIcon = isAuthTokenValid();
    });
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        color: values.NESTO_GREEN.withOpacity(0.2),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(20.0), vertical: 8),
              child: Row(
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.YOUR_LOCATION.toUpperCase(),
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              height: 1.19,
                              fontWeight: FontWeight.w700),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              constraints:
                                  BoxConstraints(maxWidth: size.width * 0.80),
                              child: Text(
                                place == null || place == ''
                                    ? strings.SELECT_LOCATION
                                    : place,
                                style: TextStyle(
                                  color: Color(0XFF111A2C),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.black,
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  // Visibility(
                  //   //TODO:CONFIGURE NOTIFICATION BELL'S VISIBILITY HERE
                  //   visible: showNotificationBellIcon,
                  //   child: InkWell(
                  //     onTap: () {
                  //       //firebase analytics logging.
                  //       firebaseAnalytics.homeScreenNotificationClicked();
                  //
                  //       Navigator.push(
                  //           context,
                  //           MaterialPageRoute(
                  //               builder: (context) =>
                  //                   NotificationListingScreen()));
                  //     },
                  //     child: headerButton(
                  //       icon: Icons.notifications_none_outlined,
                  //       iconSize: 27.0,
                  //       bgColor: Colors.white,
                  //       borderColor: Color(0xFFBBBBDC1),
                  //     ),
                  //   ),
                  // )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
