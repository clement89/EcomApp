import 'package:flutter/cupertino.dart';

class DealCard with ChangeNotifier {
  //Values which cannot be changed
  String imageUrl,link;
  bool isExternal;

  DealCard({@required this.imageUrl,@required this.link,@required this.isExternal});
}
