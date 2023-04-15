import 'package:flutter/cupertino.dart';

class OfferBannerModel {
  //Values which cannot be changed
  final String title;
  final String imageUrl;
  final String itemCode;
  final String redirectType;
  final String discountLabel;
  final String widgetCode;
  final String startGradient;
  final String endGradient;

  OfferBannerModel({
    @required this.title,
    @required this.imageUrl,
    @required this.itemCode,
    @required this.redirectType,
    @required this.discountLabel,
    @required this.widgetCode,
    @required this.startGradient,
    @required this.endGradient,
  });

  factory OfferBannerModel.fromJson(Map<String, dynamic> element) {
    return OfferBannerModel(
      title: element['details']['title'],
      imageUrl: element['details']['imageUrl'],
      itemCode: element['details']['itemCode'],
      redirectType: element['details']['redirectType'],
      discountLabel: element['details']['discountLabel'],
      widgetCode: element['widgetCode'],
      startGradient: element['details']['startGradient'],
      endGradient: element['details']['endGradient'],
    );
  }
}
