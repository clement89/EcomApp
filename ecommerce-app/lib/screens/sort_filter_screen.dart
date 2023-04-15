import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/utils/util.dart';
import 'package:Nesto/widgets/custom_appbar.dart';
import 'package:Nesto/widgets/custom_widgets.dart';
import 'package:Nesto/widgets/headers.dart';
import 'package:Nesto/widgets/primary_button.dart';
import 'package:flutter/material.dart';

import 'package:Nesto/models/sort_filter_section_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/strings.dart' as strings;
import 'package:provider/provider.dart';

class SortFilterScreen extends StatefulWidget {
  static String routeName = '/sort_filter';
  final Option selectedSortOption;
  final Option selectedFilterOption;
  const SortFilterScreen(
      {Key key, this.selectedFilterOption, this.selectedSortOption})
      : super(key: key);

  @override
  _SortFilterScreenState createState() => _SortFilterScreenState();
}

class _SortFilterScreenState extends State<SortFilterScreen> {
  List<SortFilterSection> sections = [];
  Option sortOption;
  Option filterOption;
  @override
  void initState() {
    if (widget.selectedFilterOption != null) {
      filterOption = widget.selectedFilterOption;
    }
    if (widget.selectedSortOption != null) {
      sortOption = widget.selectedSortOption;
    }
    var provider = Provider.of<StoreProvider>(context, listen: false);
    if (provider?.sections?.length == 0) {
      provider.fetchFilterOptions();
    } else {
      sections = provider.sections;
    }
    super.initState();
  }

  void updateFilterOptions() async {
    var provider = Provider.of<StoreProvider>(context, listen: false);
    await provider.fetchFilterOptions();
    setState(() {
      sections = provider.sections;
    });
  }

  void onToggle(SortFilterType type, Option option) {
    setState(() {
      if (type == SortFilterType.filter) {
        if (option.optionName == filterOption?.optionName) {
          filterOption = null;
        } else {
          filterOption = option;
        }
      } else if (type == SortFilterType.sort) {
        if (option.optionName == sortOption?.optionName) {
          sortOption = null;
        } else {
          sortOption = option;
        }
      }
    });
  }

  void applyOptions() {
    Navigator.pop(
        context,
        SortFilterArguments(
            selectedFilterOption: filterOption,
            selectedSortOption: sortOption));
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);
    return Scaffold(
      appBar: GradientAppBar(
        title: strings.SORT_AND_FILTER,
      ),
      // appBar: headerBar(title: strings.SORT_AND_FILTER, context: context),
      body: Container(
          padding: EdgeInsets.only(top: ScreenUtil().setHeight(20.0)),
          child: Column(children: [
            Expanded(
              child: ListView.separated(
                  separatorBuilder: (context, index) =>
                      SizedBox(height: ScreenUtil().setHeight(30.0)),
                  itemCount: sections.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Section(
                      section: sections[index],
                      onToggle: onToggle,
                      sortOption: sortOption,
                      filterOption: filterOption,
                    );
                  }),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CustomFilledButton(
                title: 'Apply',
                action: applyOptions,
              ),
            ),
            // (
            //   label: "Apply",
            //   onPressed: applyOptions,
            // ),
            SizedBox(height: 30),
          ])),
    );
  }
}

class Section extends StatefulWidget {
  final SortFilterSection section;
  final Function onToggle;
  final Option sortOption;
  final Option filterOption;
  Section(
      {Key key,
      @required this.section,
      @required this.onToggle,
      this.sortOption,
      this.filterOption})
      : super(key: key);

  @override
  _SectionState createState() => _SectionState();
}

class _SectionState extends State<Section> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setHeight(20.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(20.0)),
            child: Text(widget.section.heading,
                style: TextStyle(
                    fontWeight: FontWeight.w700, color: Colors.black)),
          ),
          ListView.separated(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              itemBuilder: (BuildContext context, int index) => OptionWidget(
                    option: widget.section.options[index],
                    isSelected: widget?.sortOption?.optionName ==
                            widget.section.options[index].optionName ||
                        widget?.filterOption?.optionName ==
                            widget.section.options[index].optionName,
                    onTap: () {
                      widget.onToggle(
                          widget.section.type, widget.section.options[index]);
                    },
                  ),
              // itemBuilder: (context, index) => Container(),
              separatorBuilder: (BuildContext context, int index) =>
                  Divider(height: 1),
              itemCount: widget.section.options.length),
        ],
      ),
    );
  }
}

class OptionWidget extends StatelessWidget {
  final Option option;
  final bool isSelected;
  final Function onTap;
  const OptionWidget(
      {Key key,
      @required this.option,
      @required this.isSelected,
      @required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: isSelected ? values.NESTO_GREEN.withOpacity(0.1) : null,
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setHeight(10.0)),
        height: ScreenUtil().setHeight(60),
        child: Row(
          children: [
            Expanded(child: Text(option.optionName)),
            isSelected
                ? Icon(
                    Icons.check,
                    color: values.NESTO_GREEN,
                    size: 17,
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
