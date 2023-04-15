import 'package:Nesto/models/home_builder/home_page_section.dart';
import 'package:flutter/cupertino.dart';

class HomePageModel {
  final String id;
  final String pageName;
  final String type;
  final String title;
  final List<HomePageSection> pageSections;

  HomePageModel({
    @required this.id,
    @required this.pageName,
    @required this.type,
    @required this.title,
    @required this.pageSections,
  });

  factory HomePageModel.fromJson(Map<String, dynamic> json) {
    List<HomePageSection> sectionsTemp = [];
    sectionsTemp = List<HomePageSection>.from(
      ((json['content'] ?? []) as List<dynamic>).map(
        (contents) => HomePageSection.fromJson(contents),
      ),
    );

    return HomePageModel(
      id: json['_id'],
      type: json['pageType'],
      pageName: json['name'],
      title: json['title'] ?? '',
      pageSections: sectionsTemp,

      //add title.
    );
  }
}
