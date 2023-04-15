import 'package:Nesto/models/dynamic_home_page/main_offer_banner.dart';
import 'package:Nesto/screens/merchandise_category_listing_screen.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../optimized_cache_image_widget.dart';

class MainOfferBannerWidget extends StatefulWidget {
  final MainOfferBanner mainOfferBanner;
  final String creativeSlot;

  MainOfferBannerWidget(this.mainOfferBanner, this.creativeSlot);
  @override
  _MainOfferBannerWidgetState createState() => _MainOfferBannerWidgetState();
}

class _MainOfferBannerWidgetState extends State<MainOfferBannerWidget> {
  @override
  Widget build(BuildContext context) {
    //Screen Util Init
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);

    //Provider data
    return GestureDetector(
      onTap: () {
        //firebase analytics logging.
        firebaseAnalytics.logSelectPromotion(
          promotionID: widget.mainOfferBanner?.link ?? "",
          promotionName: widget.mainOfferBanner?.imageUrl ?? "",
          creativeSlot: widget.creativeSlot ?? "",
          creativeName: widget.mainOfferBanner?.title ?? "",
          categoryID: widget.mainOfferBanner?.link ?? "",
          tileType: "main_offer_banner",
        );

        if (widget.mainOfferBanner.link.isNotEmpty) {
          // provider.selectedCategoryForViewMore = SubCategory(
          //   id: int.parse(mainOfferBanner.link),
          //   name: mainOfferBanner.title,
          //   merchandiseCategories: [],
          // );
          // Navigator.of(context).pushNamed(
          //     ViewMoreScreenWithNavigation.routeName,
          //     arguments: {"widget_type": "main_offer_banner"});
          int catID;
          try {
            catID = int.tryParse(widget.mainOfferBanner?.link ?? "0");
          } catch (e) {
            catID = null;
          }
          if (catID != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return MerchandiseCategoryListingScreen(
                    categoryID: int.parse(widget.mainOfferBanner?.link ?? "0"),
                    dealType: "main_offer_banner",
                    title: widget.mainOfferBanner.title,
                  );
                },
              ),
            );
          }
        }
      },
      child: Container(
        child: ImageWidget(
          fadeInDuration: Duration(milliseconds: 1),
          imageUrl: widget.mainOfferBanner.imageUrl,
          fit: BoxFit.fill,
          placeholder: (context, url) =>
              Image.asset("assets/images/main_offer.png"),
          errorWidget: (context, error, stackTrace) =>
              Image.memory(kTransparentImage),
        ),
      ),
    );
  }
}
