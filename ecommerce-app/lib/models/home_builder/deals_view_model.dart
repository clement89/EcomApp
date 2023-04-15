import 'package:flutter/cupertino.dart';

class DealsViewModel {
  //Values which cannot be changed
  final String title;
  final String imageUrl;
  final String itemCode;
  final String redirectType;
  final String backgroundColor;
  final String price;
  final String widgetCode;
  final int position;

  DealsViewModel({
    @required this.title,
    @required this.imageUrl,
    @required this.itemCode,
    @required this.redirectType,
    @required this.backgroundColor,
    @required this.price,
    @required this.widgetCode,
    @required this.position,
  });

  factory DealsViewModel.fromJson(Map<String, dynamic> element) {
    if (element['widgetCode'] == 'COMBINATION_DEAL_ITEM') {
      return DealsViewModel(
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

    return DealsViewModel(
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
