import 'package:flutter/cupertino.dart';

class CarouselModel {
  //Values which cannot be changed
  final String code;
  final String imageUrl;
  final String itemCode;
  final String redirectType;

  CarouselModel({
    @required this.code,
    @required this.imageUrl,
    @required this.itemCode,
    @required this.redirectType,
  });

  factory CarouselModel.fromJson(Map<String, dynamic> element) {
    return CarouselModel(
      code: element['widgetCode'],
      imageUrl: element['details']['imageUrl'],
      itemCode: element['details']['itemCode'],
      redirectType: element['details']['redirectType'],
    );
  }
}
