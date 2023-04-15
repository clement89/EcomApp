import 'package:Nesto/models/dynamic_home_page/sponsored_ad.dart';
import 'package:flutter/cupertino.dart';

class SponsoredAdsSection with ChangeNotifier {
  //Values which cannot be changed
  String title;
  List<SponsoredAd> widgets;

  SponsoredAdsSection({@required this.title,@required this.widgets});
}
