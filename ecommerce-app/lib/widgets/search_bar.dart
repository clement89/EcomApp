import 'package:Nesto/providers/auth_provider.dart';
import 'package:Nesto/screens/notification_listing_screen.dart';
import 'package:Nesto/screens/search_screen.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/utils/util.dart';
import 'package:Nesto/values.dart' as values;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class SearchBar extends StatefulWidget {
  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  bool isPressed = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Screen Util Init

    var safePadding = MediaQuery.of(context).padding.top;

    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);

    var size = MediaQuery.of(context).size;
    var authProvider = Provider.of<AuthProvider>(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [
              values.NESTO_GREEN.withOpacity(0.5),
              values.NESTO_GREEN.withOpacity(0.3),
            ],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(1.0, 0.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp),
      ),
      child: Column(
        children: [
          SizedBox(
            height: safePadding + 5,
          ),
          Row(
            children: [
              SizedBox(
                width: size.width * 0.90,
                child: GestureDetector(
                  onTap: () {
                    //CJC removed from here
                    // //firebase analytics logging
                    // firebaseAnalytics.logSearchClicked();
                    Navigator.of(context).pushNamed(SearchScreen.routeName);
                  },
                  onTapDown: (TapDownDetails details) {
                    setState(() {
                      isPressed = true;
                    });
                  },
                  onTapUp: (TapUpDetails details) {
                    setState(() {
                      isPressed = false;
                    });
                  },
                  onTapCancel: () {
                    setState(() {
                      isPressed = false;
                    });
                  },
                  child: Container(
                    height: 44, //CJC ScreenUtil().setWidth(48),
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(20)),
                    decoration: BoxDecoration(
                      color: isPressed ? Colors.grey[200] : Color(0xFFF5F5F8),
                      borderRadius: BorderRadius.circular(10),
                      // border: Border.all(color: values.NESTO_GREEN),
                    ),
                    child: Center(
                      child: Row(
                        children: [
                          SizedBox(
                            width: ScreenUtil().setWidth(20),
                          ),
                          Icon(
                            Icons.search_outlined,
                            color: Colors.black87,
                          ),
                          SizedBox(
                            width: ScreenUtil()
                                .setWidth(values.SPACING_MARGIN_SMALL),
                          ),
                          Text(
                            "Search for products",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              isAuthTokenValid()
                  ? InkWell(
                      onTap: () {
                        //firebase analytics logging.
                        firebaseAnalytics.homeScreenNotificationClicked();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    NotificationListingScreen()));
                      },
                      child: Icon(
                        Icons.notifications_none_outlined,
                      ),
                    )
                  : Container(),
            ],
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
