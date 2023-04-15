import 'package:flutter/cupertino.dart';

class SubCategoryTile with ChangeNotifier {
  //Values which cannot be changed
  String imageUrl,link,title;
  bool isExternal;

  SubCategoryTile({@required this.imageUrl,@required this.title,@required this.link,@required this.isExternal});
}
