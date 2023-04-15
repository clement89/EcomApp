import 'package:flutter/cupertino.dart';

class AdBannerModel {
  //Values which cannot be changed
  final String code;
  final String imageUrl;
  final String itemCode;
  final String redirectType;
  final String widgetCode;

  AdBannerModel({
    @required this.code,
    @required this.imageUrl,
    @required this.itemCode,
    @required this.redirectType,
    @required this.widgetCode,
  });

  factory AdBannerModel.fromJson(Map<String, dynamic> element) {
    return AdBannerModel(
      code: element['widgetCode'],
      imageUrl: element['details']['imageUrl'],
      itemCode: element['details']['itemCode'],
      redirectType: element['details']['redirectType'],
      widgetCode: element['widgetCode'],
    );
  }
}
