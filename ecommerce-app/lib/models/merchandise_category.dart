import 'package:flutter/cupertino.dart';

class MerchandiseCategory with ChangeNotifier {
  //Values which cannot be changed
  final int id, parentId, position, productCount;
  String name, description, imageUrl;
  final bool isActive;

  MerchandiseCategory(
      {@required this.id,
      @required this.parentId,
      @required this.position,
      @required this.productCount,
      @required this.name,
      @required this.description,
      @required this.imageUrl,
      @required this.isActive});
}
