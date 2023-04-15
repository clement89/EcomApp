import 'package:Nesto/models/dynamic_home_page/all_categories_section.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/widgets/dynamic_homepage_widgets/individual_category_subsection_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AllCategoriesSectionWidget extends StatelessWidget {

  final AllCategoriesSection allCategoriesSection;

  AllCategoriesSectionWidget(this.allCategoriesSection);

  @override
  Widget build(BuildContext context) {

    //Screen Util Init
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height:
          ScreenUtil().setHeight(values.SPACING_MARGIN_SMALL),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(20)),
          child: allCategoriesSection.title!=""?Text(
            allCategoriesSection.title,
            style: TextStyle(
                color: Colors.black87,
                fontSize: 17,
                fontWeight: FontWeight.w700),
          ):SizedBox(),
        ),
        SizedBox(
          height:
          ScreenUtil().setHeight(values.SPACING_MARGIN_SMALL),
        ),
        SizedBox(
          height: ScreenUtil().setWidth(160),
          child: ListView.builder(
            cacheExtent: ScreenUtil().setWidth(414) * allCategoriesSection.widgets.length,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            physics: BouncingScrollPhysics(),
            itemCount: allCategoriesSection.widgets.length,
            itemBuilder: (context, index) {
              if(index==0) return Container(margin: EdgeInsets.only(left: ScreenUtil().setWidth(20)),child: IndividualCategorySubsectionWidget( allCategoriesSection.widgets[index]));
              if(index==allCategoriesSection.widgets.length-1) return Container(margin: EdgeInsets.only(right: ScreenUtil().setWidth(20)),child: IndividualCategorySubsectionWidget( allCategoriesSection.widgets[index]));
              else return IndividualCategorySubsectionWidget( allCategoriesSection.widgets[index]);
            },
          ),
        ),
        SizedBox(
          height: ScreenUtil()
              .setHeight(values.SPACING_MARGIN_STANDARD),
        ),
      ],
    );
  }
}
