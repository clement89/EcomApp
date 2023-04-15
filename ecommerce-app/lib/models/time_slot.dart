import 'package:flutter/material.dart';

class TimeSlot with ChangeNotifier {
  //Values which cannot be changed
  final String id;
  final String recordId,
      fromTime,
      toTime,
      quoteLimit,
      extraCharge,
      cutOffTime,
      startTime,
      slotType;
  final int position;

  DateTime day;

  TimeSlot({
    @required this.id,
    @required this.recordId,
    @required this.fromTime,
    @required this.toTime,
    @required this.quoteLimit,
    @required this.extraCharge,
    @required this.cutOffTime,
    @required this.startTime,
    @required this.position,
    @required this.slotType,
  });
}
