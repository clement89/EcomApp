import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/screens/base_screen.dart';
import 'package:Nesto/screens/search_screen.dart';
import 'package:Nesto/values.dart' as values;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'headerButton.dart';

Widget headerBar({@required String title, BuildContext context, Function onBackPress}) {
  return PreferredSize(
    preferredSize: Size.fromHeight(ScreenUtil().setHeight(130.0)),
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(12.0)),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(left: ScreenUtil().setWidth(24.0)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  child: headerButton(
                      icon: Icons.chevron_left,
                      iconSize: 27.0,
                      bgColor: Colors.white,
                      borderColor: Color(0XFFBBBDC1),
                      onPress: onBackPress??((){
                        Navigator.of(context).maybePop();
                      })
                      ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: ScreenUtil().setHeight(44.19),
            width: double.infinity,
            child: Center(
              child: Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: Color(0XFF111A2C),
                ),
              ),
            ),
          )
        ],
      ),
    ),
  );
}



Widget modifiedHeaderRow(
    {IconData rightIcon,
    double rightIconSize,
    Function onPressBack,
    Function onPressRightIcon,
    @required String title,
    Color iconBgColor,
    Color iconBorderColor,
    bool isSearch = false,
    @required BuildContext context}) {
  return PreferredSize(
    preferredSize: Size.fromHeight(80.0),
    child: Container(
      padding: EdgeInsets.only(
          left: ScreenUtil().setWidth(20.0),
          right: ScreenUtil().setWidth(20.0),
          bottom: ScreenUtil().setHeight(20.0)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          headerButton(
              icon: Icons.chevron_left,
              iconSize: 27.0,
              bgColor: Colors.white,
              borderColor: Color(0XFFBBBDC1),
              onPress: () {
                Navigator.of(context).maybePop();
              }),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: Color(0XFF111A2C),
            ),
          ),
          isSearch
              ? headerButton(
                  icon: Icons.search,
                  iconSize: 27.0,
                  iconColor: values.NESTO_GREEN,
                  bgColor: Colors.white,
                  borderColor: Color(0XFFBBBDC1),
                  onPress: () {
                    Navigator.of(context).pushNamed(SearchScreen.routeName);
                  })
              : headerButton(
                  icon: rightIcon,
                  iconSize: rightIconSize ?? 25,
                  borderColor: iconBorderColor ?? Colors.transparent,
                  bgColor: iconBgColor ?? Color(0XFF00983D).withOpacity(0.2),
                  onPress: onPressRightIcon,
                )
        ],
      ),
    ),
  );
}

Widget headerRow(
    {IconData rightIcon,
    double rightIconSize,
    Function onPressBack,
    Function onPressRightIcon,
    @required String title,
    Color iconBgColor,
    Color iconBorderColor,
    bool isCart = false,
    @required BuildContext context}) {
  return PreferredSize(
    preferredSize: Size.fromHeight(80.0),
    child: Container(
      padding: EdgeInsets.only(
          left: ScreenUtil().setWidth(20.0),
          right: ScreenUtil().setWidth(20.0),
          bottom: ScreenUtil().setHeight(20.0)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          headerButton(
              icon: Icons.chevron_left,
              iconSize: 27.0,
              bgColor: Colors.white,
              borderColor: Color(0XFFBBBDC1),
              onPress: () {
                Navigator.of(context).maybePop();
              }),
          SizedBox(
            width: ScreenUtil().setWidth(260),
            child: Text(
              title.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: Color(0XFF111A2C),
              ),
            ),
          ),
          isCart
              ? CartHeaderButton()
              : headerButton(
                  icon: rightIcon,
                  iconSize: rightIconSize ?? 25,
                  borderColor: iconBorderColor ?? Colors.transparent,
                  bgColor: iconBgColor ?? Color(0XFF00983D).withOpacity(0.2),
                  onPress: onPressRightIcon,
                )
        ],
      ),
    ),
  );
}

class CartHeaderButton extends StatelessWidget {
  const CartHeaderButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<StoreProvider>(context);

    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(
            BaseScreen.routeName,
                (Route<dynamic> route) =>
            false,
            arguments: {"index": 3});
      },
      child: Container(
        width: ScreenUtil().setWidth(44.19),
        height: ScreenUtil().setHeight(44.19),
        padding: EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Color(0XFF00983D).withOpacity(0.2),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 22,
                  color: Colors.black,
                ),
              ],
            ),
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                height: 13,
                width: 13,
                padding: EdgeInsets.all(2),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0XFF00983D),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    provider.cartCount.toString(),
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
