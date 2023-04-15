import 'package:Nesto/models/notifications_response.dart';
import 'package:Nesto/values.dart' as values;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:Nesto/strings.dart' as strings;
import 'optimized_cache_image_widget.dart';

class NotificationScreenDescriptionWidget extends StatefulWidget {
  final Datum element;
  final bool markAllAsReadStatus;
  final Function onTapSingleNotification;
  final Function onTapDeleteButton;
  final Function onTapDeleteAllReadButton;

  NotificationScreenDescriptionWidget(
      {this.element,
      this.markAllAsReadStatus,
      this.onTapSingleNotification,
      this.onTapDeleteButton,
      this.onTapDeleteAllReadButton});

  @override
  _NotificationScreenDescriptionWidgetState createState() =>
      _NotificationScreenDescriptionWidgetState();
}

class _NotificationScreenDescriptionWidgetState
    extends State<NotificationScreenDescriptionWidget> {
  bool showHamburgerDropDown;

  @override
  void initState() {
    showHamburgerDropDown = false;
    super.initState();
  }

  String getNotificationTime() {
    if ((DateTime.now().difference(widget.element.createdAt))
            .inDays
            .toString() ==
        "0") {
      if ((DateTime.now().difference(widget.element.createdAt))
              .inHours
              .toString() ==
          "0") {
        if (((DateTime.now().difference(widget.element.createdAt))
                .inMinutes
                .toString()) ==
            "0") {
          if (((DateTime.now().difference(widget.element.createdAt))
                  .inSeconds
                  .toString()) ==
              "0") {
            return "";
          } else {
            return (DateTime.now().difference(widget.element.createdAt))
                    .inSeconds
                    .toString() +
                strings.SECONDS;
          }
        } else {
          return (DateTime.now().difference(widget.element.createdAt))
                  .inMinutes
                  .toString() +
              strings.MINUTES;
        }
      } else {
        return (DateTime.now().difference(widget.element.createdAt))
                .inHours
                .toString() +
            strings.HOURS;
      }
    } else {
      return (DateTime.now().difference(widget.element.createdAt))
              .inDays
              .toString() +
          strings.DAYS;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, left: 3.0, right: 3.0),
      child: GestureDetector(
        onTap: widget.onTapSingleNotification,
        child: Container(
          width: ScreenUtil().screenWidth,
          decoration: BoxDecoration(
            color:
                // ((widget.element.seen == true) ||
                //         (widget.markAllAsReadStatus == true))
                //     ? Colors.white
                //     :
                Color(0xffFAFAFA),
            //border:
            // Border.all(
            //     color: ((widget.element.seen == true) ||
            //             (widget.markAllAsReadStatus == true))
            //         ? Colors.black.withOpacity(0.5)
            //         : Color(0xffFAFAFA),
            //     width: 0.5),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // GestureDetector(
              //   onTap: widget.onTapSingleNotification,
              //   child: Container(
              //     height: ScreenUtil().setHeight(60),
              //     width: ScreenUtil().setWidth(50),
              //     color: Colors.transparent,
              //     child: FittedBox(
              //       fit: BoxFit.contain,
              //       child: OptimizedCacheImageWidget(
              //         maxHeightDiskCache: 900,
              //         maxWidthDiskCache: 900,
              //         fadeInDuration: Duration(milliseconds: 1),
              //         imageUrl: widget.element.image == null
              //             ? ""
              //             : widget.element.image,
              //       ),
              //     ),
              //   ),
              // ),
              Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      // setState(() {
                      //   showHamburgerDropDown = false;
                      // });
                    },
                    child: Container(
                      width: ScreenUtil().setWidth(350.0),
                      color: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: ScreenUtil().setWidth(335),
                                  color: Colors.transparent,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: widget.onTapSingleNotification,
                                        child: Container(
                                            color: Colors.transparent,
                                            width: ScreenUtil().setWidth(300),
                                            child:
                                                ((widget.element.title ==
                                                            "Order out for delivery!") ||
                                                        (widget.element.title ==
                                                            "Order ready for delivery!") ||
                                                        (widget.element.title ==
                                                            "Order Delivered!"))
                                                    ? RichText(
                                                        text: TextSpan(
                                                            text: widget
                                                                .element.title,
                                                            style: TextStyle(
                                                                color: Color(
                                                                    0xFF27AE60),
                                                                fontSize: 14.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                            children: <
                                                                TextSpan>[
                                                              TextSpan(
                                                                text: ((widget.element.data !=
                                                                            null) &&
                                                                        (widget.element.data.salesIncrementalId !=
                                                                            null))
                                                                    ? ("  - #" +
                                                                        widget
                                                                            .element
                                                                            .data
                                                                            .salesIncrementalId)
                                                                    : "",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                              )
                                                            ]),
                                                      )
                                                    : Text(
                                                        widget.element.title +
                                                            (((widget.element
                                                                            .data !=
                                                                        null) &&
                                                                    (widget
                                                                            .element
                                                                            .data
                                                                            .salesIncrementalId !=
                                                                        null))
                                                                ? ("  - #" +
                                                                    widget
                                                                        .element
                                                                        .data
                                                                        .salesIncrementalId)
                                                                : ("")),
                                                        overflow: TextOverflow
                                                            .visible,
                                                        style: TextStyle(
                                                            color:
                                                                // ((widget.element.seen ==
                                                                //             true) ||
                                                                //         (widget.markAllAsReadStatus ==
                                                                //             true))
                                                                //     ? values.hintcolor
                                                                //     :
                                                                Colors.black,
                                                            fontSize: 14.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      )),
                                      ),
                                      widget.element.seen == false
                                          ? Container(
                                              width: 12.0,
                                              height: 12.0,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.red,
                                                    width: 1.0,
                                                  ),
                                                  shape: BoxShape.circle),
                                              child: Center(
                                                child: Container(
                                                  width: 8.0,
                                                  height: 8.0,
                                                  decoration: BoxDecoration(
                                                      color: Colors.red,
                                                      shape: BoxShape.circle),
                                                ),
                                              ),
                                            )
                                          : Container(),
                                      // GestureDetector(
                                      //   onTap: () {
                                      //     if (showHamburgerDropDown == false) {
                                      //       setState(() {
                                      //         showHamburgerDropDown = true;
                                      //       });
                                      //     } else {
                                      //       setState(() {
                                      //         showHamburgerDropDown = false;
                                      //       });
                                      //     }
                                      //   },
                                      //   child: Container(
                                      //     width: 15.0,
                                      //     height: ScreenUtil().setHeight(25.0),
                                      //     color: Colors.transparent,
                                      //     child: Center(
                                      //       child: SvgPicture.asset(
                                      //         "assets/svg/menu_icon.svg",
                                      //         color: Colors.black,
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: ScreenUtil().setHeight(5.0),
                                ),
                                GestureDetector(
                                  onTap: widget.onTapSingleNotification,
                                  child: Container(
                                    color: Colors.transparent,
                                    width: ScreenUtil().setWidth(240),
                                    child: Text(
                                      widget.element.body,
                                      overflow: (widget.element.seen == true) ||
                                              (widget.markAllAsReadStatus ==
                                                  true)
                                          ? TextOverflow.visible
                                          : TextOverflow.ellipsis,
                                      maxLines: (widget.element.seen == true) ||
                                              (widget.markAllAsReadStatus ==
                                                  true)
                                          ? 1000
                                          : 1,
                                      style: TextStyle(
                                          fontSize: 13.0,
                                          fontWeight: FontWeight.w500,
                                          color: values.hintcolor),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: ScreenUtil().setHeight(8.0),
                                ),
                                GestureDetector(
                                  onTap: widget.onTapSingleNotification,
                                  child: Container(
                                    color: Colors.transparent,
                                    width: ScreenUtil().setWidth(240),
                                    child: Text(
                                      getNotificationTime() + strings.AGO,
                                      overflow: TextOverflow.visible,
                                      style: TextStyle(
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.w400,
                                        color: widget.element.seen == true
                                            ? values.hintcolor
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  showHamburgerDropDown == true
                      ? Positioned(
                          top: ScreenUtil().setHeight(50.0),
                          right: 0.0,
                          child: Container(
                            width: ScreenUtil().setWidth(110.0),
                            color: Colors.white,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: widget.onTapDeleteButton,
                                  child: Container(
                                    width: ScreenUtil().setWidth(110.0),
                                    color: Colors.white,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          strings.DELETE,
                                          overflow: TextOverflow.visible,
                                          style: TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: ScreenUtil().setHeight(10.0),
                                ),
                                GestureDetector(
                                  onTap: widget.onTapDeleteAllReadButton,
                                  child: Container(
                                    width: ScreenUtil().setWidth(110.0),
                                    color: Colors.white,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          strings.DELETE_ALL_READ,
                                          overflow: TextOverflow.visible,
                                          style: TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container()
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
