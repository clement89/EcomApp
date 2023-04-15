import 'package:Nesto/models/dynamic_home_page/main_offer_section.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/widgets/dynamic_homepage_widgets/main_offer_banner_widget.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MainOfferSectionWidget extends StatefulWidget {
  final MainOfferSection mainOfferSection;

  MainOfferSectionWidget(this.mainOfferSection);
  @override
  _MainOfferSectionWidgetState createState() => _MainOfferSectionWidgetState();
}

class _MainOfferSectionWidgetState extends State<MainOfferSectionWidget> {
  List<bool> analyticLogData;

  @override
  void initState() {
    super.initState();
    analyticLogData = List<bool>.generate(
        widget?.mainOfferSection?.widgets?.length ?? 0, (i) => true);
  }

  void onPageChanged(int index, dynamic reason) {
    if (analyticLogData[index]) {
      analyticLogData[index] = false;
      firebaseAnalytics.logViewPromotion(
        promotionID: widget.mainOfferSection.widgets[index]?.link ?? "",
        promotionName: widget.mainOfferSection.widgets[index]?.imageUrl ?? "",
        creativeSlot: index.toString() ?? "",
        creativeName: widget.mainOfferSection.widgets[index]?.title ?? "",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    //Screen Util Init
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: (widget.mainOfferSection.title != " " &&
              widget.mainOfferSection.title.isNotEmpty),
          child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
            child: Text(
              widget.mainOfferSection.title,
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 17,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ),
        SizedBox(
          height: ScreenUtil().setHeight(values.SPACING_MARGIN_SMALL),
        ),
        Container(
          height: ScreenUtil().setHeight(150.0),
          width: ScreenUtil().screenWidth,
          child: CarouselSlider.builder(
            itemCount: widget.mainOfferSection.widgets.length,
            options: CarouselOptions(
              onPageChanged: onPageChanged,
              scrollDirection: Axis.horizontal,
              scrollPhysics: BouncingScrollPhysics(),
              autoPlay: true,
              pauseAutoPlayOnTouch: true,
              enlargeCenterPage: true,
              viewportFraction: 0.7,
              initialPage: 0,
              enableInfiniteScroll: true,
              reverse: false,
              autoPlayInterval: Duration(seconds: 3),
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
            ),
            itemBuilder: (context, index, realIdx) {
              if (index == 0)
                return Container(
                    margin: EdgeInsets.only(
                      left: ScreenUtil().setWidth(20),
                    ),
                    child: MainOfferBannerWidget(
                        widget.mainOfferSection.widgets[index],
                        index.toString()));
              else
                return MainOfferBannerWidget(
                    widget.mainOfferSection.widgets[index], index.toString());
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
