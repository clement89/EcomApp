import 'package:flutter/cupertino.dart';

class MainOfferBanner with ChangeNotifier {
  //Values which cannot be changed
  String imageUrl,link,title;
  bool isExternal;

  MainOfferBanner({@required this.imageUrl,@required this.link,@required this.title,@required this.isExternal});
}
