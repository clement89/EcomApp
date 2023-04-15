import 'package:flutter/cupertino.dart';

class TwoBannerGridModel {
  //Values which cannot be changed
  final String title;
  final String imageUrl;
  final String itemCode;
  final String redirectType;
  final String discountLabel;
  final String widgetCode;
  final String discount;
  final String originalPrice;
  final String discountPrice;
  final String startGradient;
  final String endGradient;
  final String buttonColor;
  final String buttonFontColor;
  final String buttonName;
  final String startDate;
  final String endDate;

  TwoBannerGridModel({
    @required this.title,
    @required this.imageUrl,
    @required this.itemCode,
    @required this.redirectType,
    @required this.discountLabel,
    @required this.widgetCode,
    @required this.discount,
    @required this.originalPrice,
    @required this.discountPrice,
    @required this.startGradient,
    @required this.endGradient,
    @required this.buttonColor,
    @required this.buttonFontColor,
    @required this.buttonName,
    @required this.startDate,
    @required this.endDate,
  });

  factory TwoBannerGridModel.fromJson(Map<String, dynamic> element) {
    if (element['widgetCode'] == 'TWO_BANNER_IMAGE_V1') {
      return TwoBannerGridModel(
        title: element['details']['title'],
        imageUrl: element['details']['imageUrl'],
        itemCode: element['details']['itemCode'],
        redirectType: element['details']['redirectType'],
        discountLabel: element['details']['discountLabel'],
        widgetCode: element['widgetCode'],
        discount: '',
        originalPrice: '',
        discountPrice: '',
        startGradient: element['details']['startGradient'],
        endGradient: element['details']['endGradient'],
        buttonColor: element['details']['buttonColor'],
        buttonFontColor: element['details']['buttonFontColor'],
        buttonName: element['details']['buttonName'],
        startDate: '',
        endDate: '',
      );
    }
    return TwoBannerGridModel(
      title: element['details']['title'],
      imageUrl: element['details']['imageUrl'],
      itemCode: element['details']['itemCode'],
      redirectType: element['details']['redirectType'],
      discountLabel: '',
      widgetCode: element['widgetCode'],
      discount: element['details']['discount'],
      originalPrice: element['details']['originalPrice'],
      discountPrice: element['details']['discountPrice'],
      startGradient: element['details']['startGradient'],
      endGradient: element['details']['endGradient'],
      buttonColor: '',
      buttonFontColor: '',
      buttonName: '',
      startDate: element['details']['startDate'],
      endDate: element['details']['endDate'],
    );
  }
}
