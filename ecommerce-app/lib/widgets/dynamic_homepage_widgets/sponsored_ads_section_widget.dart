import 'package:Nesto/models/dynamic_home_page/sponsered_ads_section.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/widgets/dynamic_homepage_widgets/sponsored_ad_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SponsoredAdsSectionWidget extends StatefulWidget {
  final SponsoredAdsSection sponsoredAdsSection;

  SponsoredAdsSectionWidget(this.sponsoredAdsSection);
  @override
  _SponsoredAdsSectionWidgetState createState() =>
      _SponsoredAdsSectionWidgetState();
}

class _SponsoredAdsSectionWidgetState extends State<SponsoredAdsSectionWidget> {
  @override
  Widget build(BuildContext context) {
    //Screen Util Init
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: ScreenUtil().setWidth(184),
          child: ListView.builder(
            cacheExtent: ScreenUtil().setWidth(380) *
                widget.sponsoredAdsSection.widgets.length,
            // ScreenUtil().setWidth(419) / ScreenUtil().setWidth(184),
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            physics: BouncingScrollPhysics(),
            itemCount: widget.sponsoredAdsSection.widgets.length,
            itemBuilder: (context, index) {
              if (index != widget.sponsoredAdsSection.widgets.length - 1)
                return Container(
                    margin: EdgeInsets.only(right: ScreenUtil().setWidth(20)),
                    child: SponsoredAdWidget(
                        widget.sponsoredAdsSection.widgets[index],
                        widget.sponsoredAdsSection?.title ?? "",
                        index.toString()));
              else
                return SponsoredAdWidget(
                    widget.sponsoredAdsSection.widgets[index],
                    widget.sponsoredAdsSection?.title ?? "",
                    index.toString());
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
