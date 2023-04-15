import 'package:Nesto/utils/util.dart';
import 'package:dio/dio.dart';

enum SortFilterType { filter, sort, none }

class SortFilterSection {
  String heading;
  SortFilterType type;
  List<Option> options = [];

  SortFilterSection({this.heading, this.type, this.options});

  factory SortFilterSection.fromJson(Map<String, dynamic> json) {
    List<Option> _option = [];
    List<dynamic> optionList = (json["options"] ?? [])
        .map((element) => Option.fromJson(element))
        .toList();
    optionList.forEach((element) {
      if (element != null) {
        _option.add(element);
      }
    });

    return SortFilterSection(
        heading: json["heading"],
        type: json["type"] == "filter"
            ? SortFilterType.filter
            : json["type"] == "sort"
                ? SortFilterType.sort
                : SortFilterType.none,
        options: _option);
  }
}

class Option {
  String optionName;
  String optionKey;
  String optionValue;
  Option({this.optionName, this.optionKey, this.optionValue});
  factory Option.fromJson(Map<String, dynamic> json) => Option(
      optionName: json["optName"],
      optionKey: json["optKey"],
      optionValue: json["optValue"]);
}

class SortFilterArguments {
  final Option selectedFilterOption;
  final Option selectedSortOption;

  SortFilterArguments({this.selectedFilterOption, this.selectedSortOption});
}
