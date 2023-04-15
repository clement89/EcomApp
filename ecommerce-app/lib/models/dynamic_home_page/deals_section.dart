import 'package:Nesto/models/dynamic_home_page/deal_card.dart';
import 'package:flutter/cupertino.dart';

class DealsSection with ChangeNotifier {
  //Values which cannot be changed
  String title;
  int ctaLink;
  List<DealCard> widgets;

  DealsSection({@required this.title,@required this.widgets,@required this.ctaLink});
}
