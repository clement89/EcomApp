import 'package:Nesto/screens/search_screen.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/values.dart' as values;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';

class GradientAppBar extends StatelessWidget with PreferredSizeWidget {
  final String title;
  final Function backAction;

  final List<Widget> rightActions;
  final bool showBottomSearchBar;

  const GradientAppBar({
    @required this.title,
    this.backAction,
    this.rightActions,
    this.showBottomSearchBar = false,
  });

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [
              values.NESTO_GREEN.withOpacity(0.6),
              values.NESTO_GREEN.withOpacity(0.3),
            ],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(1.0, 0.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp),
      ),
      child: showBottomSearchBar
          ? Column(
              children: [
                _appBar(context),
                GestureDetector(
                  onTap: () {
                    //CJC removed from here
                    // //firebase analytics logging
                    firebaseAnalytics.logSearchClicked();
                    Navigator.of(context).pushNamed(SearchScreen.routeName);
                  },
                  onTapDown: (TapDownDetails details) {
                    // setState(() {
                    //   isPressed = true;
                    // });
                  },
                  onTapUp: (TapUpDetails details) {
                    // setState(() {
                    //   isPressed = false;
                    // });
                  },
                  onTapCancel: () {
                    // setState(() {
                    //   isPressed = false;
                    // });
                  },
                  child: Container(
                    height: 44, //CJC ScreenUtil().setWidth(48),
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(20)),
                    decoration: BoxDecoration(
                      color: Color(0xFFF5F5F8),
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
              ],
            )
          : _appBar(context),
    );
  }

  Widget _appBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      centerTitle: false,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Colors.black,
          size: 18,
        ),
        onPressed: () {
          if (backAction != null) {
            backAction();
          } else {
            Navigator.of(context).pop();
          }
        },
      ),
      title: Text(
        title,
        style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 17,
            letterSpacing: 1),
      ),
      elevation: 0,
      actions: rightActions == null ? [] : rightActions,
    );
  }
}
