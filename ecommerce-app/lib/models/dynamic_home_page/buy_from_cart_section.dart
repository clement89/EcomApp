import 'package:Nesto/models/dynamic_home_page/individual_category_sub_section.dart';
import 'package:flutter/cupertino.dart';

class BuyFromCartSection with ChangeNotifier {
  //Values which cannot be changed
  String title,link,ctaLink;
  List<IndividualCategorySubSection> widgets;
  int maxWidgets,parentLink;

  BuyFromCartSection({@required this.title,@required this.widgets,@required this.link,@required this.maxWidgets,@required this.ctaLink,@required this.parentLink});
}
