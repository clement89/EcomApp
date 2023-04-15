import 'package:Nesto/models/dynamic_home_page/main_offer_banner.dart';
import 'package:flutter/cupertino.dart';

class MainOfferSection with ChangeNotifier {
  //Values which cannot be changed
  String title;
  List<MainOfferBanner> widgets;

  MainOfferSection({@required this.title,@required this.widgets});
}
