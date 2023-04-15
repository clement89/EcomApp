import 'package:Nesto/models/dynamic_home_page/individual_category_sub_section.dart';
import 'package:flutter/cupertino.dart';

class AllCategoriesSection with ChangeNotifier {
  //Values which cannot be changed
  String title;
  List<IndividualCategorySubSection> widgets;

  AllCategoriesSection({@required this.title,@required this.widgets});
}
