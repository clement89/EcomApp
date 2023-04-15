import 'package:Nesto/models/dynamic_home_page/deals_section.dart';
import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/screens/merchandise_category_listing_screen.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/utils/util.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/widgets/dynamic_homepage_widgets/deal_card_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class DealsSectionWidget extends StatefulWidget {
  final DealsSection dealsSection;

  DealsSectionWidget(this.dealsSection);
  @override
  _DealsSectionWidgetState createState() => _DealsSectionWidgetState();
}

class _DealsSectionWidgetState extends State<DealsSectionWidget> {
  @override
  Widget build(BuildContext context) {
    //Screen Util Init
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);

    //Provider data
    var provider = Provider.of<StoreProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: ScreenUtil().setHeight(values.SPACING_MARGIN_SMALL),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
          child: Visibility(
              visible: (widget.dealsSection.title.isNotEmpty &&
                  widget.dealsSection.title != " "),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.dealsSection.title,
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 17,
                        fontWeight: FontWeight.w700),
                  ),
                  SeeMore(onPress: () {
                    //firebase analytics logging.
                    firebaseAnalytics.logSeeMoreClicked(
                      itemListID: widget.dealsSection?.ctaLink.toString(),
                      itemListName: widget.dealsSection?.title,
                      contentType: "deals_section",
                    );

                    // provider.selectedCategoryForViewMore = SubCategory(
                    //   id: dealsSection.ctaLink,
                    //   name: dealsSection.title,
                    //   merchandiseCategories: [],
                    // );
                    // Navigator.of(context).pushNamed(
                    //     ViewMoreScreenWithNavigation.routeName,
                    //     arguments: {"widget_type": "deals_section"});

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return MerchandiseCategoryListingScreen(
                            categoryID: widget.dealsSection?.ctaLink,
                            dealType: "deals_section",
                            title: widget.dealsSection?.title ?? "",
                          );
                        },
                      ),
                    );
                  }),
                ],
              )),
        ),
        SizedBox(
          height: ScreenUtil().setHeight(values.SPACING_MARGIN_SMALL),
        ),
        SizedBox(
          height: ScreenUtil().setWidth(170),
          child: ListView.builder(
            cacheExtent:
                ScreenUtil().setWidth(212) * widget.dealsSection.widgets.length,
            // ScreenUtil().setWidth(100),
            dragStartBehavior: DragStartBehavior.start,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            physics: BouncingScrollPhysics(),
            itemCount: widget.dealsSection.widgets.length,
            itemBuilder: (context, index) {
              if (index == 0)
                return Container(
                    margin: EdgeInsets.only(
                      left: ScreenUtil().setWidth(20),
                    ),
                    child: DealCardWidget(widget.dealsSection.widgets[index],
                        widget.dealsSection?.title ?? "", index.toString()));
              else
                return DealCardWidget(widget.dealsSection.widgets[index],
                    widget.dealsSection?.title ?? "", index.toString());
            },
          ),
        ),
        SizedBox(
          height: ScreenUtil().setHeight(values.SPACING_MARGIN_STANDARD),
        ),
      ],
    );
  }
}
