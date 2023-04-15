import 'package:flutter/cupertino.dart';

class DealsV2Model {
  //Values which cannot be changed
  final String title;
  final String imageUrl;
  final String itemCode;
  final String redirectType;
  final String backgroundColor;
  final String price;
  final String widgetCode;
  final int position;

  DealsV2Model({
    @required this.title,
    @required this.imageUrl,
    @required this.itemCode,
    @required this.redirectType,
    @required this.backgroundColor,
    @required this.price,
    @required this.widgetCode,
    @required this.position,
  });

  factory DealsV2Model.fromJson(Map<String, dynamic> element) {
    if (element['widgetCode'] == 'COMBINATION_DEAL_ITEM') {
      return DealsV2Model(
        title: element['details']['title'],
        imageUrl: element['details']['imageUrl'],
        itemCode: element['details']['itemCode'],
        redirectType: element['details']['redirectType'],
        backgroundColor: element['details']['backgroundColor'],
        price: element['details']['price'],
        widgetCode: element['widgetCode'],
        position: element['details']['position'],
      );
    }

    return DealsV2Model(
      title: element['details']['title'],
      imageUrl: element['details']['imageUrl'],
      itemCode: element['details']['itemCode'],
      redirectType: element['details']['redirectType'],
      backgroundColor: element['details']['backgroundColor'],
      price: element['details']['price'],
      widgetCode: element['widgetCode'],
      position: element['details']['position'],
    );
  }
}
