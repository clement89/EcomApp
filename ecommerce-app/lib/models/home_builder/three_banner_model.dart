import 'package:flutter/cupertino.dart';

class ThreeBannerGridModel {
  //Values which cannot be changed
  final String title;
  final String imageUrl;
  final String itemCode;
  final String redirectType;
  final String startGradient;
  final String endGradient;
  final String widgetCode;

  ThreeBannerGridModel({
    @required this.title,
    @required this.imageUrl,
    @required this.itemCode,
    @required this.redirectType,
    @required this.startGradient,
    @required this.endGradient,
    @required this.widgetCode,
  });

  factory ThreeBannerGridModel.fromJson(Map<String, dynamic> element) {
    return ThreeBannerGridModel(
      title: element['details']['title'],
      imageUrl: element['details']['imageUrl'],
      itemCode: element['details']['itemCode'],
      redirectType: element['details']['redirectType'],
      startGradient: element['details']['startGradient'],
      endGradient: element['details']['endGradient'],
      widgetCode: element['widgetCode'],
    );
  }
}
