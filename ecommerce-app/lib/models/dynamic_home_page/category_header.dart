import 'package:flutter/cupertino.dart';

class CategoryHeader with ChangeNotifier {
  //Values which cannot be changed
  String imageUrl,link,title;
  bool isExternal;

  CategoryHeader({@required this.imageUrl,@required this.title,@required this.link,@required this.isExternal});
}
