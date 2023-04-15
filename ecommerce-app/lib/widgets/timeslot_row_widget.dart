import 'package:Nesto/providers/store_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:Nesto/strings.dart' as strings;

class TimeslotRowWidget extends StatelessWidget {
  bool isTimeslotLoading = false;

  @override
  Widget build(BuildContext context) {
    //Screen Util Init
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);

    var provider = Provider.of<StoreProvider>(context);

    return ((provider.todayTimeSlots.isNotEmpty ||
                provider.tomorrowTimeSlots.isNotEmpty) &&
            (provider.nextTimeSlotInHours != '--' &&
                provider.nextAvailableTimeSlot != '--'))
        ? Padding(
            padding:
                EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TimeSlotContainer(
                    icon: Icons.bolt,
                    iconContainerColor: Color(0xFFFFEAB6),
                    subText: strings.DELIVERING_NOW_IN,
                    mainText: provider.nextTimeSlotInHours),
                TimeSlotContainer(
                  icon: Icons.query_builder,
                  iconContainerColor: Color(0XFFFFDED1),
                  subText: strings.NEXT_AVAILABLE_TIMESLOT,
                  mainText: provider.nextAvailableTimeSlot,
                ),
              ],
            ))
        : Container(
            padding: EdgeInsets.only(left: ScreenUtil().setWidth(7.0)),
            margin: EdgeInsets.only(
                right: ScreenUtil()
                    .setWidth(provider.fetchingTimeslot ? 200 : 10.0)),
            decoration: BoxDecoration(
              color: Color(0XFFF5F5F8),
              borderRadius: BorderRadius.circular(10.0),
            ),
            height: ScreenUtil().setHeight(42.0),
            width: ScreenUtil().setWidth(provider.fetchingTimeslot ? 165 : 355),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: ScreenUtil().setHeight(31),
                  width: ScreenUtil().setWidth(31),
                  decoration: BoxDecoration(
                      color: Color(0XFFFFDED1),
                      borderRadius: BorderRadius.circular(4.0)),
                  child: Center(child: Icon(Icons.query_builder)),
                ),
                SizedBox(width: ScreenUtil().setWidth(7.0)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      provider.fetchingTimeslot
                          ? strings.LOADING+".."
                          : strings.ALL_AVAILABLE_SLOT_ARE_BOOKED_NOW,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    provider.fetchingTimeslot
                        ? Container(
                            height: ScreenUtil().setHeight(20),
                            width: ScreenUtil().setWidth(20),
                            margin: EdgeInsets.only(
                                left: ScreenUtil().setWidth(10.0)),
                            child: CircularProgressIndicator(
                              strokeWidth: 1,
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                  Colors.black),
                            ),
                          )
                        : IconButton(
                            splashRadius: 0.1,
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.refresh),
                            onPressed: () {
                              provider.fetchTimeSlots();
                            },
                          )
                  ],
                ),
              ],
            ),
          );
  }
}

class TimeSlotContainer extends StatelessWidget {
  TimeSlotContainer(
      {@required this.iconContainerColor,
      @required this.icon,
      @required this.mainText,
      @required this.subText});

  final Color iconContainerColor;
  final IconData icon;
  final String mainText, subText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: ScreenUtil().setWidth(7.0)),
      decoration: BoxDecoration(
        color: Color(0XFFF5F5F8),
        borderRadius: BorderRadius.circular(10.0),
      ),
      height: ScreenUtil().setHeight(42.0),
      width: ScreenUtil().setWidth(185),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: ScreenUtil().setHeight(31),
            width: ScreenUtil().setWidth(31),
            decoration: BoxDecoration(
                color: iconContainerColor,
                borderRadius: BorderRadius.circular(4.0)),
            child: Center(child: Icon(icon)),
          ),
          SizedBox(width: ScreenUtil().setWidth(7.0)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                subText,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  height: 1.2,
                  color: Color(0XFFA2A2A2),
                ),
              ),
              Text(
                mainText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
