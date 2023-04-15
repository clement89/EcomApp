import 'package:Nesto/models/dynamic_home_page/individual_category_sub_section.dart';
import 'package:Nesto/widgets/dynamic_homepage_widgets/category_header_widget.dart';
import 'package:Nesto/widgets/dynamic_homepage_widgets/subcategory_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class IndividualCategorySubsectionWidget extends StatelessWidget {
  final IndividualCategorySubSection individualCategorySubsection;

  IndividualCategorySubsectionWidget(this.individualCategorySubsection);

  @override
  Widget build(BuildContext context) {
    //Screen Util Init
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);

    return Container(
      height: ScreenUtil().setWidth(180),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: individualCategorySubsection.widgets.length == 8
            ? [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CategoryHeaderWidget(
                        individualCategorySubsection.widgets[0]),
                    SizedBox(
                      width: ScreenUtil().setWidth(8),
                    ),
                    SubCategoryTileWidget(
                        individualCategorySubsection.widgets[1]),
                    SizedBox(
                      width: ScreenUtil().setWidth(8),
                    ),
                    SubCategoryTileWidget(
                        individualCategorySubsection.widgets[2]),
                  ],
                ),
                SizedBox(
                  height: ScreenUtil().setWidth(8.0),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SubCategoryTileWidget(
                        individualCategorySubsection.widgets[3]),
                    SizedBox(
                      width: ScreenUtil().setWidth(8),
                    ),
                    SubCategoryTileWidget(
                        individualCategorySubsection.widgets[4]),
                    SizedBox(
                      width: ScreenUtil().setWidth(8),
                    ),
                    SubCategoryTileWidget(
                        individualCategorySubsection.widgets[5]),
                    SizedBox(
                      width: ScreenUtil().setWidth(8),
                    ),
                    SubCategoryTileWidget(
                        individualCategorySubsection.widgets[6]),
                    SizedBox(
                      width: ScreenUtil().setWidth(8),
                    ),
                    SubCategoryTileWidget(
                        individualCategorySubsection.widgets[7]),
                    SizedBox(
                      width: ScreenUtil().setWidth(8),
                    ),
                  ],
                )
              ]
            : individualCategorySubsection.widgets.length == 7
                ? [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CategoryHeaderWidget(
                            individualCategorySubsection.widgets[0]),
                        SizedBox(
                          width: ScreenUtil().setWidth(8),
                        ),
                        SubCategoryTileWidget(
                            individualCategorySubsection.widgets[1]),
                        SizedBox(
                          width: ScreenUtil().setWidth(8),
                        ),
                        SubCategoryTileWidget(
                            individualCategorySubsection.widgets[2]),
                      ],
                    ),
                    SizedBox(
                      height: ScreenUtil().setWidth(8.0),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SubCategoryTileWidget(
                            individualCategorySubsection.widgets[3]),
                        SizedBox(
                          width: ScreenUtil().setWidth(8),
                        ),
                        SubCategoryTileWidget(
                            individualCategorySubsection.widgets[4]),
                        SizedBox(
                          width: ScreenUtil().setWidth(8),
                        ),
                        SubCategoryTileWidget(
                            individualCategorySubsection.widgets[5]),
                        SizedBox(
                          width: ScreenUtil().setWidth(8),
                        ),
                        SubCategoryTileWidget(
                            individualCategorySubsection.widgets[6]),
                        SizedBox(
                          width: ScreenUtil().setWidth(8),
                        ),
                        SizedBox(
                          height: ScreenUtil().setWidth(69),
                          width: ScreenUtil().setWidth(69),
                        ),
                        SizedBox(
                          width: ScreenUtil().setWidth(8),
                        ),
                      ],
                    )
                  ]
                : individualCategorySubsection.widgets.length == 6
                    ? [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CategoryHeaderWidget(
                                individualCategorySubsection.widgets[0]),
                            SizedBox(
                              width: ScreenUtil().setWidth(8),
                            ),
                            SubCategoryTileWidget(
                                individualCategorySubsection.widgets[1]),
                            SizedBox(
                              width: ScreenUtil().setWidth(8),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: ScreenUtil().setWidth(8.0),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SubCategoryTileWidget(
                                individualCategorySubsection.widgets[2]),
                            SizedBox(
                              width: ScreenUtil().setWidth(8),
                            ),
                            SubCategoryTileWidget(
                                individualCategorySubsection.widgets[3]),
                            SizedBox(
                              width: ScreenUtil().setWidth(8),
                            ),
                            SubCategoryTileWidget(
                                individualCategorySubsection.widgets[4]),
                            SizedBox(
                              width: ScreenUtil().setWidth(8),
                            ),
                            SubCategoryTileWidget(
                                individualCategorySubsection.widgets[5]),
                            SizedBox(
                              width: ScreenUtil().setWidth(8),
                            ),
                          ],
                        )
                      ]
                    : [],
      ),
    );
  }
}
