import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:Nesto/strings.dart' as strings;

class NotificationScreenHeaderWidget extends StatefulWidget {
  final bool showRightIcon;
  final String title;
  final Function onChangedCheckBox;
  final bool checkBoxStatus;
  final bool showCheckBox;
  final Function onTapClearAll;

  NotificationScreenHeaderWidget(
      {this.title,
      this.showRightIcon,
      this.checkBoxStatus,
      this.onChangedCheckBox,
      this.showCheckBox,
      this.onTapClearAll});

  @override
  _NotificationScreenHeaderWidgetState createState() =>
      _NotificationScreenHeaderWidgetState();
}

class _NotificationScreenHeaderWidgetState
    extends State<NotificationScreenHeaderWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 3.0, right: 3.0),
      child: Container(
        width: ScreenUtil().screenWidth,
        height: ScreenUtil().setHeight(35.0),
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: ScreenUtil().setWidth(160.0),
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                        fontFamily: 'assets/fonts/sf_pro_display.ttf',
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: ScreenUtil().setWidth(45.0),
            ),
            // widget.showCheckBox == true
            //     ? Container(
            //         width: ScreenUtil().setWidth(175.0),
            //         child: Row(
            //           mainAxisAlignment: MainAxisAlignment.spaceAround,
            //           crossAxisAlignment: CrossAxisAlignment.center,
            //           children: [
            //             widget.showRightIcon == true
            //                 ? Checkbox(
            //                     value: widget.checkBoxStatus,
            //                     onChanged: widget.onChangedCheckBox,
            //                   )
            //                 : Container(),
            //             widget.showRightIcon == true
            //                 ? Text(
            //                     "All mark as read",
            //                     style: TextStyle(
            //                         fontSize: 14, fontWeight: FontWeight.w600),
            //                   )
            //                 : Container(),
            //           ],
            //         ),
            //       )
            //     : Container(),
            Container(
              color: Colors.transparent,
              width: ScreenUtil().setWidth(160.0),
              child: widget.showCheckBox == true
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: widget.onTapClearAll,
                          child: Container(
                            width: ScreenUtil().setWidth(15.0),
                            height: ScreenUtil().setHeight(25.0),
                            color: Colors.transparent,
                            child: SvgPicture.asset(
                              "assets/svg/notification_screen_clear_all.svg",
                              color: Color(0xFF27AE60),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: widget.onTapClearAll,
                          child: SizedBox(
                            width: ScreenUtil().setWidth(6.0),
                          ),
                        ),
                        GestureDetector(
                          onTap: widget.onTapClearAll,
                          child: Container(
                            child: Text(
                              strings.CLEAR_ALL,
                              style: TextStyle(
                                  fontFamily: 'assets/fonts/sf_pro_display.ttf',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF27AE60)),
                            ),
                          ),
                        )
                      ],
                    )
                  : Container(),
            )
          ],
        ),
      ),
    );
  }
}
