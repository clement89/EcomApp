import 'package:Nesto/services/navigation_service.dart';
import 'package:Nesto/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:Nesto/values.dart' as values;
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:Nesto/strings.dart' as strings;

class CouponAppliedBanner extends StatefulWidget {
  const CouponAppliedBanner({Key key}) : super(key: key);

  @override
  _CouponAppliedBannerState createState() => _CouponAppliedBannerState();
}

class _CouponAppliedBannerState extends State<CouponAppliedBanner> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        notificationServices.showCustomDialog(
            title: strings.COUPON_APPLIED,
            description: strings.COUPON_BANNER_DESCRIPTION,
            positiveText: strings.OK,
            negativeText: "",
            action: () async {});
      },
      child: Container(
        width: ScreenUtil().screenWidth,
        height: ScreenUtil().setHeight(40.0),
        color: values.NESTO_GREEN.withOpacity(0.2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding:
                  EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(4.5)),
              child: SvgPicture.asset("assets/icons/coupon_apply.svg",
                  color: values.NESTO_GREEN),
            ),
            SizedBox(
              width: ScreenUtil().setWidth(13),
            ),
            Text(
              strings.COUPON_APPLIED,
              style: TextStyle(
                  color: values.NESTO_GREEN,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }
}
