import 'package:flutter/cupertino.dart';

class CircularGridModel {
  //Values which cannot be changed
  final String title;
  final String imageUrl;
  final String itemCode;
  final String redirectType;
  final String borderColor;
  final String widgetCode;
  final String startGradient;
  final String endGradient;
  final int position;
  final String borderEndGradient;
  final String borderStartGradient;

  CircularGridModel({
    @required this.title,
    @required this.imageUrl,
    @required this.itemCode,
    @required this.redirectType,
    @required this.borderColor,
    @required this.widgetCode,
    @required this.position,
    @required this.startGradient,
    @required this.endGradient,
    @required this.borderEndGradient,
    @required this.borderStartGradient,
  });

  factory CircularGridModel.fromJson(Map<String, dynamic> element) {
    return CircularGridModel(
      title: element['details']['title'],
      imageUrl: element['details']['imageUrl'],
      itemCode: element['details']['itemCode'],
      redirectType: element['details']['redirectType'],
      borderColor: element['details']['borderColor'],
      widgetCode: element['widgetCode'],
      position: element['details']['position'],
      startGradient: element['details']['startGradient'] ?? '',
      endGradient: element['details']['endGradient'] ?? '',
      borderStartGradient: element['details']['borderStartGradient'] ?? '',
      borderEndGradient: element['details']['borderEndGradient'] ?? '',
    );
  }
}
