import 'package:flutter/cupertino.dart';

class NoMarginBannerModel {
  //Values which cannot be changed
  final String title;
  final String imageUrl;
  final String itemCode;
  final String redirectType;
  final String startGradient;
  final String endGradient;
  final String widgetCode;
  final String buttonName;
  final String buttonColor;
  final String buttonFontColor;
  NoMarginBannerModel({
    @required this.title,
    @required this.imageUrl,
    @required this.itemCode,
    @required this.redirectType,
    @required this.startGradient,
    @required this.endGradient,
    @required this.widgetCode,
    @required this.buttonName,
    @required this.buttonColor,
    @required this.buttonFontColor,
  });

  factory NoMarginBannerModel.fromJson(Map<String, dynamic> element) {
    if (element['widgetCode'] == 'NO_MARGIN_ITEM') {
      return NoMarginBannerModel(
        title: element['details']['title'],
        imageUrl: element['details']['imageUrl'],
        itemCode: element['details']['itemCode'],
        redirectType: element['details']['redirectType'],
        startGradient: element['details']['startGradient'],
        endGradient: element['details']['endGradient'],
        widgetCode: element['widgetCode'],
        buttonName: element['details']['buttonName'],
        buttonColor: element['details']['buttonColor'],
        buttonFontColor: element['details']['buttonFontColor'],
      );
    }
    return NoMarginBannerModel(
      title: '',
      imageUrl: element['details']['imageUrl'],
      itemCode: element['details']['itemCode'],
      redirectType: element['details']['redirectType'],
      startGradient: '',
      endGradient: '',
      widgetCode: element['widgetCode'],
      buttonName: '',
      buttonColor: '',
      buttonFontColor: '',
    );
  }
}
