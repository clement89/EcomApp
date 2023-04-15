import 'package:Nesto/models/merchandise_category.dart';
import 'package:flutter/cupertino.dart';

class SubCategory with ChangeNotifier {
  //Values which cannot be changed
  final int id, parentId, position, productCount;
  String name, description, imageUrl;
  final bool isActive;
  final List<MerchandiseCategory> merchandiseCategories;

  SubCategory(
      {@required this.id,
      @required this.parentId,
      @required this.position,
      @required this.productCount,
      @required this.name,
      @required this.description,
      @required this.imageUrl,
      @required this.isActive,
      @required this.merchandiseCategories});
}
