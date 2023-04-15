import 'package:Nesto/models/subcategory.dart';
import 'package:flutter/cupertino.dart';

class MainCategory with ChangeNotifier {
  //Values which cannot be changed
  final int id, parentId, position, productCount, offer;
  String name, description, imageUrl;
  final bool isActive;
  final List<SubCategory> subCategories;

  MainCategory(
      {@required this.id,
      @required this.parentId,
      @required this.position,
      @required this.productCount,
      @required this.name,
      @required this.description,
      @required this.imageUrl,
      @required this.offer,
      @required this.isActive,
      @required this.subCategories});
}
