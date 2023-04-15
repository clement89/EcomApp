import 'package:flutter/cupertino.dart';

class GridViewModel {
  //Values which cannot be changed
  final String title;
  final String imageUrl;
  final String itemCode;
  final String redirectType;
  final String discountLabel;
  final String widgetCode;
  final String startDate;
  final String endDate;
  GridViewModel({
    @required this.title,
    @required this.imageUrl,
    @required this.itemCode,
    @required this.redirectType,
    @required this.discountLabel,
    @required this.widgetCode,
    @required this.startDate,
    @required this.endDate,
  });

  factory GridViewModel.fromJson(Map<String, dynamic> element) {
    return GridViewModel(
      title: element['details']['title'],
      imageUrl: element['details']['imageUrl'],
      itemCode: element['details']['itemCode'],
      redirectType: element['details']['redirectType'],
      discountLabel: element['details']['discountLabel'],
      widgetCode: element['widgetCode'],
      startDate: element['startDate'],
      endDate: element['endDate'],
    );
  }
}
