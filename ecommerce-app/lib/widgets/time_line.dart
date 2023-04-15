import 'package:flutter/material.dart';
import 'package:Nesto/strings.dart' as strings;

class TimeLine extends StatefulWidget {
  TimeLine({@required this.status});
  final String status;
  @override
  _TimeLineState createState() => _TimeLineState();
}

class _TimeLineState extends State<TimeLine> {
  int ticks = 0;
  void getStatus() {
    switch (widget.status) {
      case 'pending':
        setState(() => ticks = 0);
        break;
      case 'picking':
        setState(() => ticks = 1);
        break;
      case 'packing':
        setState(() => ticks = 2);
        break;
      case 'intransit':
        setState(() => ticks = 3);
        break;
      case 'delivered':
        setState(() => ticks = 4);
        break;
      case 'return_initiated':
        setState(() => ticks = 3);
        break;
      default:
        setState(() => ticks = 0);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    getStatus();
    return Row(
      children: generateTile(),
    );
  }

  List<String> titles = [
    strings.PENDING,
    strings.PICKING,
    strings.PACKING,
    strings.IN_TRANSIT,
    strings.DELIVERED
  ];

  List generateTile() {
    var tiles = List.generate(titles.length, (index) {
      return timelineTile(index);
    });
    return tiles;
  }

  Container timelineTile(int index) {
    return Container(
      width: (MediaQuery.of(context).size.width - 30) / 5,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 2,
                  color: index == 0
                      ? Colors.transparent
                      : index <= ticks
                          ? Colors.green
                          : Color(0XFFE0E0E0),
                ),
              ),
              Container(
                  height: 24,
                  width: 24,
                  decoration: BoxDecoration(
                      color: index <= ticks ? Colors.green : Color(0XFFE0E0E0),
                      shape: BoxShape.circle),
                  child: Center(
                    child: Icon(
                      Icons.check,
                      size: 10,
                      color: Colors.white,
                    ),
                  )),
              Expanded(
                child: Container(
                  height: 2,
                  color: index == titles.length - 1
                      ? Colors.transparent
                      : index < ticks
                          ? Colors.green
                          : index == ticks
                              ? Color(0XFFE0E0E0)
                              : Color(0XFFE0E0E0),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              titles[index],
              style: TextStyle(
                  color: index <= ticks ? Colors.green : Colors.grey,
                  fontSize: 13.0),
            ),
          ),
        ],
      ),
    );
  }
}
