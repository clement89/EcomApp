import 'package:Nesto/values.dart' as values;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:Nesto/strings.dart' as strings;

class LocationDenied extends StatefulWidget {
  final Function callLocation;
  LocationDenied({
    this.callLocation,
  });
  @override
  LocationDeniedState createState() => LocationDeniedState();
}

class LocationDeniedState extends State<LocationDenied> {
  bool isopen = false;

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
              "assets/svg/no_gps.svg",
              height: ScreenUtil().setWidth(121),
              width: ScreenUtil().setWidth(121),
            ),
            SizedBox(
              height: ScreenUtil().setWidth(39),
            ),
            Text(
              strings.LOCATION_PERMISSION_DENIED,
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 28,
                  fontWeight: FontWeight.w700),
            ),
            SizedBox(
              height: ScreenUtil().setWidth(values.SPACING_MARGIN_TEXT),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 40, left: 40),
              child: Text(
                strings.PLEASE_ENABLE_LOCATION_PERMISSION,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 17),
              ),
            ),
            SizedBox(
              height: ScreenUtil().setWidth(30),
            ),
            Container(
                width: ScreenUtil().setWidth(145),
                height: ScreenUtil().setWidth(46),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: values.NESTO_GREEN, width: 3)),
                child: isopen == false
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            //TODO check ios specific bug
                            isopen = true;
                            LocationPermissions()
                                .openAppSettings()
                                .then((bool hasOpened) {
                              //isopen=true;
                              debugPrint('App Settings opened: ' +
                                  hasOpened.toString());
                            });
                          });
                        },
                        child: Center(
                          child: Text(
                            strings.OPEN_SETTINGS,
                            style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 16),
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          isopen = false;
                          widget?.callLocation();
                          // Navigator.pushReplacementNamed(
                          //     context, LocationScreen.routeName);
                        },
                        child: Center(
                          child: Text(
                            strings.TRY_AGAIN,
                            style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 16),
                          ),
                        ),
                      ))
          ],
        ),
      ),
    );
  }
}
