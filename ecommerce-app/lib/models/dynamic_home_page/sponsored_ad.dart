import 'package:flutter/cupertino.dart';

class SponsoredAd with ChangeNotifier {
  //Values which cannot be changed
  String imageUrl,link;
  bool isExternal;

  SponsoredAd({@required this.imageUrl,@required this.link,@required this.isExternal});
}
