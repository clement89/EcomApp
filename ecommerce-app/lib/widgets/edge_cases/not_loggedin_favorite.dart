import 'package:Nesto/screens/login_screen.dart';
import 'package:Nesto/values.dart' as values;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:Nesto/strings.dart' as strings;

class NoFavoritesWidgetForLogOut extends StatefulWidget {
  @override
  _NoFavoritesWidgetForLogOutState createState() =>
      _NoFavoritesWidgetForLogOutState();
}

class _NoFavoritesWidgetForLogOutState
    extends State<NoFavoritesWidgetForLogOut> {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              "assets/svg/no_favorites.svg",
              height: ScreenUtil().setWidth(238),
              width: ScreenUtil().setWidth(238),
            ),
            SizedBox(
              height: ScreenUtil().setWidth(39),
            ),
            Text(
              strings.FIRSTLY_LETS_SIGN_YOU_IN,
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 28,
                  fontWeight: FontWeight.w700),
            ),
            SizedBox(
              height: ScreenUtil().setWidth(values.SPACING_MARGIN_TEXT),
            ),
            Text(
              strings.FAVOURITE_SIGN_IN_DESCRIPTION,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 17),
            ),
            SizedBox(
              height: ScreenUtil().setWidth(values.SPACING_MARGIN_TEXT),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(LoginScreen.routeName);
              },
              child: Text(strings.SIGN_IN, style: TextStyle(fontSize: 14)),
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                backgroundColor:
                    MaterialStateProperty.all<Color>(values.NESTO_GREEN),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      side: BorderSide(color: values.NESTO_GREEN)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
