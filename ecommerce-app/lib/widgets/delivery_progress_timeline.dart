import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:timelines/timelines.dart';

const kTileHeight = 50.0;

const completeColor = Color(0xff249140);
const inProgressColor = Color(0xff229140);
Color todoColor = Color(0xffd1d2d7).withOpacity(0.5);

class DeliveryProgressTimeline extends StatefulWidget {
  final String status;

  const DeliveryProgressTimeline({Key key, this.status}) : super(key: key);

  @override
  _DeliveryProgressTimelineState createState() =>
      _DeliveryProgressTimelineState();
}

class _DeliveryProgressTimelineState extends State<DeliveryProgressTimeline> {
  int _processIndex = 2;

  Color getColor(int index) {
    if (index == _processIndex) {
      return inProgressColor;
    } else if (index < _processIndex) {
      return completeColor;
    } else {
      return todoColor;
    }
  }

  bool getTickStatus(int index) {
    if (index == _processIndex) {
      return false;
    } else if (index < _processIndex) {
      return true;
    } else {
      return false;
    }
  }

  bool getBorderStatus(int index) {
    if (index == _processIndex) {
      return true;
    } else if (index < _processIndex) {
      return false;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    _processes = [
      'Pending',
      'Picking',
      'Packing',
      'In transit',
      'Delivered',
    ];
    if (widget.status == 'pending' || widget.status == 'picking_initiated')
      _processIndex = 1;
    else if (widget.status == 'payment_review') {
      _processIndex = 0;
    } else if (widget.status == 'processing') {
      _processIndex = 0;
    } else if (widget.status == 'picking_completed' ||
        widget.status == 'packing_initiated')
      _processIndex = 2;
    else if (widget.status == 'ready_for_delivery' ||
        widget.status == 'packing_completed')
      _processIndex = 3;
    else if (widget.status == 'out_for_delivery')
      _processIndex = 4;
    else if (widget.status == 'delivered')
      _processIndex = 5;
    else if (widget.status == 'return_initiated') {
      _processIndex = 6;
      _processes = [
        'Pending',
        'Picking',
        'Packing',
        'In transit',
        'Delivered',
        'Return\nInitiated',
        'Return\nCollected',
        'Returned',
      ];
    } else if (widget.status == 'return_collected') {
      _processIndex = 7;
      _processes = [
        'Pending',
        'Picking',
        'Packing',
        'In transit',
        'Delivered',
        'Return\nInitiated',
        'Return\nCollected',
        'Returned',
      ];
    } else if (widget.status == 'returned') {
      _processIndex = 8;
      _processes = [
        'Pending',
        'Picking',
        'Packing',
        'In transit',
        'Delivered',
        'Return\nInitiated',
        'Return\nCollected',
        'Returned',
      ];
    } else if (widget.status == 'closed') {
      _processIndex = 8;
      _processes = [
        'Pending',
        'Picking',
        'Packing',
        'In transit',
        'Delivered',
        'Return\nInitiated',
        'Return\nCollected',
        'Closed',
      ];
    } else
      _processIndex = 0;

   
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        height: 135.0,
        width: 90.0 * _processes.length,
        color: Colors.white,
        child: Timeline.tileBuilder(
          theme: TimelineThemeData(
            direction: Axis.horizontal,
            connectorTheme: ConnectorThemeData(
              space: 30.0,
              thickness: 2.0,
            ),
          ),
          builder: TimelineTileBuilder.connected(
            connectionDirection: ConnectionDirection.before,
            itemExtentBuilder: (_, __) => 90.0,
            oppositeContentsBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(top: 15.0),
              );
            },
            contentsBuilder: (context, index) {
              return Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Text(
                    _processes[index],
                    // maxLines: 2,
                    // overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                      color: getColor(index + 1),
                    ),
                  ));
            },
            indicatorBuilder: (_, index) {
              var color;
              var child;
              if (index == _processIndex) {
                color = inProgressColor;
                child = Padding(
                  padding: const EdgeInsets.all(8.0),
                  
                );
              } else if (index < _processIndex) {
                color = completeColor;
                child = Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 15.0,
                );
              } else {
                color = todoColor;
              }

              if (index <= _processIndex) {
                return Stack(
                  children: [
                    CustomPaint(
                      size: Size(30.0, 30.0),
                      painter: _BezierPainter(
                        color: color,
                        drawStart: index > 0,
                        drawEnd: index < _processIndex,
                      ),
                    ),
                    DotIndicator(
                      size: 30.0,
                      color: color,
                      child: child,
                    ),
                  ],
                );
              } else {
                return Stack(
                  children: [
                    CustomPaint(
                      size: Size(15.0, 15.0),
                      painter: _BezierPainter(
                        color: color,
                        drawEnd: index < _processes.length - 1,
                      ),
                    ),
                    OutlinedDotIndicator(
                      borderWidth: 4.0,
                      color: color,
                    ),
                  ],
                );
              }
            },
            connectorBuilder: (_, index, type) {
              if (index > 0) {
                if (index == _processIndex) {
                  final prevColor = getColor(index + 1);
                  final color = getColor(index + 1);
                  var gradientColors;
                  if (type == ConnectorType.start) {
                    gradientColors = [Color.lerp(prevColor, color, 0.5), color];
                  } else {
                    gradientColors = [
                      prevColor,
                      Color.lerp(prevColor, color, 0.5)
                    ];
                  }
                  return DecoratedLineConnector(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                      ),
                    ),
                  );
                } else {
                  return SolidLineConnector(
                    color: getColor(index),
                  );
                }
              } else {
                return null;
              }
            },
            itemCount: _processes.length,
          ),
        ),
      ),
    );

    // return Padding(
    //   padding: const EdgeInsets.only(
    //       left: 15.0, right: 15.0, top: 20.0, bottom: 8.0),
    //   child: Container(
    //     width: ScreenUtil().screenWidth,
    //     decoration: BoxDecoration(
    //         borderRadius: BorderRadius.circular(8.0),
    //         border: Border.all(color: Colors.orangeAccent, width: 1.0)),
    //     child: Padding(
    //       padding: const EdgeInsets.all(8.0),
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //         crossAxisAlignment: CrossAxisAlignment.center,
    //         children: [
    //           Padding(
    //             padding: EdgeInsets.only(
    //                 left: ScreenUtil().setWidth(15.0),
    //                 right: ScreenUtil().setWidth(15.0)),
    //             child: Row(
    //               crossAxisAlignment: CrossAxisAlignment.center,
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children: [
    //                 _processes.contains("Pending")
    //                     ? OrderScreenWidget(
    //                         color: getColor(0),
    //                         showBorder: getBorderStatus(0),
    //                         showTick: getTickStatus(0),
    //                       )
    //                     : Container(),
    //                 _processes.contains("Picking")
    //                     ? Container(
    //                         width: ScreenUtil().setWidth(78.5),
    //                         height: 2,
    //                         color: getColor(1),
    //                       )
    //                     : Container(),
    //                 _processes.contains("Picking")
    //                     ? OrderScreenWidget(
    //                         color: getColor(1),
    //                         showBorder: getBorderStatus(1),
    //                         showTick: getTickStatus(1),
    //                       )
    //                     : Container(),
    //                 _processes.contains("Packing")
    //                     ? Container(
    //                         width: ScreenUtil().setWidth(78.5),
    //                         height: 2,
    //                         color: getColor(2),
    //                       )
    //                     : Container(),
    //                 _processes.contains("Packing")
    //                     ? OrderScreenWidget(
    //                         color: getColor(2),
    //                         showBorder: getBorderStatus(2),
    //                         showTick: getTickStatus(2),
    //                       )
    //                     : Container(),
    //                 _processes.contains("In transit")
    //                     ? Container(
    //                         width: ScreenUtil().setWidth(78.5),
    //                         height: 2,
    //                         color: getColor(3),
    //                       )
    //                     : Container(),
    //                 _processes.contains("In transit")
    //                     ? OrderScreenWidget(
    //                         color: getColor(3),
    //                         showBorder: getBorderStatus(3),
    //                         showTick: getTickStatus(3),
    //                       )
    //                     : Container(),
    //               ],
    //             ),
    //           ),
    //           SizedBox(
    //             height: ScreenUtil().setHeight(5.0),
    //           ),
    //           Row(
    //             crossAxisAlignment: CrossAxisAlignment.center,
    //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //             children: [
    //               _processes.contains("Pending")
    //                   ? Text("Pending",
    //                       style: TextStyle(
    //                           color: Colors.black,
    //                           fontWeight: FontWeight.w400,
    //                           fontSize: 12))
    //                   : Container(),
    //               _processes.contains("Picking")
    //                   ? Text("Picking",
    //                       style: TextStyle(
    //                           color: Colors.black,
    //                           fontWeight: FontWeight.w400,
    //                           fontSize: 12))
    //                   : Container(),
    //               _processes.contains("Packing")
    //                   ? Text("Packing",
    //                       style: TextStyle(
    //                           color: Colors.black,
    //                           fontWeight: FontWeight.w400,
    //                           fontSize: 12))
    //                   : Container(),
    //               _processes.contains("In transit")
    //                   ? Text("In transit",
    //                       style: TextStyle(
    //                           color: Colors.black,
    //                           fontWeight: FontWeight.w400,
    //                           fontSize: 12))
    //                   : Container(),
    //             ],
    //           ),
    //           SizedBox(
    //             height: ScreenUtil().setHeight(15.0),
    //           ),
    //           Padding(
    //             padding: EdgeInsets.only(
    //                 left: ScreenUtil().setWidth(15.0),
    //                 right: ScreenUtil().setWidth(15.0)),
    //             child: Row(
    //               crossAxisAlignment: CrossAxisAlignment.center,
    //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //               children: [
    //                 _processes.contains("Delivered")
    //                     ? OrderScreenWidget(
    //                         color: getColor(4),
    //                         showBorder: getBorderStatus(4),
    //                         showTick: getTickStatus(4),
    //                       )
    //                     : Container(),
    //                 _processes.contains("R..Initiated")
    //                     ? Container(
    //                         width: ScreenUtil().setWidth(78.5),
    //                         height: 2,
    //                         color: getColor(5),
    //                       )
    //                     : Container(),
    //                 _processes.contains("R..Initiated")
    //                     ? OrderScreenWidget(
    //                         color: getColor(5),
    //                         showBorder: getBorderStatus(5),
    //                         showTick: getTickStatus(5),
    //                       )
    //                     : Container(),
    //                 _processes.contains("R..Collected")
    //                     ? Container(
    //                         width: ScreenUtil().setWidth(78.5),
    //                         height: 2,
    //                         color: getColor(6),
    //                       )
    //                     : Container(),
    //                 _processes.contains("R..Collected")
    //                     ? OrderScreenWidget(
    //                         color: getColor(6),
    //                         showBorder: getBorderStatus(6),
    //                         showTick: getTickStatus(6),
    //                       )
    //                     : Container(),
    //                 _processes.contains("Returned")
    //                     ? Container(
    //                         width: ScreenUtil().setWidth(78.5),
    //                         height: 2,
    //                         color: getColor(7),
    //                       )
    //                     : Container(),
    //                 _processes.contains("Returned")
    //                     ? OrderScreenWidget(
    //                         color: getColor(7),
    //                         showBorder: getBorderStatus(7),
    //                         showTick: getTickStatus(7),
    //                       )
    //                     : Container(),
    //                 _processes.contains("Closed")
    //                     ? Container(
    //                         width: ScreenUtil().setWidth(78.5),
    //                         height: 2,
    //                         color: getColor(7),
    //                       )
    //                     : Container(),
    //                 _processes.contains("Closed")
    //                     ? OrderScreenWidget(
    //                         color: getColor(7),
    //                         showBorder: getBorderStatus(7),
    //                         showTick: getTickStatus(7),
    //                       )
    //                     : Container(),
    //               ],
    //             ),
    //           ),
    //           SizedBox(
    //             height: ScreenUtil().setHeight(5.0),
    //           ),
    //           Row(
    //             crossAxisAlignment: CrossAxisAlignment.center,
    //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //             children: [
    //               _processes.contains("Delivered")
    //                   ? Text("Delivered",
    //                       style: TextStyle(
    //                           color: Colors.black,
    //                           fontWeight: FontWeight.w400,
    //                           fontSize: 12))
    //                   : Container(),
    //               _processes.contains("R..Initiated")
    //                   ? Text("R..Initiated",
    //                       style: TextStyle(
    //                           color: Colors.black,
    //                           fontWeight: FontWeight.w400,
    //                           fontSize: 12))
    //                   : Container(),
    //               _processes.contains("R..Collected")
    //                   ? Text("R..Collected",
    //                       style: TextStyle(
    //                           color: Colors.black,
    //                           fontWeight: FontWeight.w400,
    //                           fontSize: 12))
    //                   : Container(),
    //               _processes.contains("In Returned")
    //                   ? Text("In Returned",
    //                       style: TextStyle(
    //                           color: Colors.black,
    //                           fontWeight: FontWeight.w400,
    //                           fontSize: 12))
    //                   : Container(),
    //               _processes.contains("Closed") ? Text("Closed") : Container(),
    //             ],
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }
}

/// hardcoded bezier painter
/// TODO: Bezier curve into package component
class _BezierPainter extends CustomPainter {
  const _BezierPainter({
    @required this.color,
    this.drawStart = true,
    this.drawEnd = true,
  });

  final Color color;
  final bool drawStart;
  final bool drawEnd;

  Offset _offset(double radius, double angle) {
    return Offset(
      radius * cos(angle) + radius,
      radius * sin(angle) + radius,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    final radius = size.width / 2;

    var angle;
    var offset1;
    var offset2;

    var path;

    if (drawStart) {
      angle = 3 * pi / 4;
      offset1 = _offset(radius, angle);
      offset2 = _offset(radius, -angle);
      path = Path()
        ..moveTo(offset1.dx, offset1.dy)
        ..quadraticBezierTo(0.0, size.height / 2, -radius,
            radius) // TODO connector start & gradient
        ..quadraticBezierTo(0.0, size.height / 2, offset2.dx, offset2.dy)
        ..close();

      canvas.drawPath(path, paint);
    }
    if (drawEnd) {
      angle = -pi / 4;
      offset1 = _offset(radius, angle);
      offset2 = _offset(radius, -angle);

      path = Path()
        ..moveTo(offset1.dx, offset1.dy)
        ..quadraticBezierTo(size.width, size.height / 2, size.width + radius,
            radius) // TODO connector end & gradient
        ..quadraticBezierTo(size.width, size.height / 2, offset2.dx, offset2.dy)
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_BezierPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.drawStart != drawStart ||
        oldDelegate.drawEnd != drawEnd;
  }
}

List _processes = [
  'Pending',
  'Picking',
  'Packing',
  'In transit',
  'Delivered',
];
