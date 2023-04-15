import 'package:Nesto/models/dynamic_home_page/sponsored_ad.dart';
import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/screens/product_details.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../optimized_cache_image_widget.dart';

class SponsoredAdWidget extends StatefulWidget {
  final SponsoredAd sponsoredAd;
  final String sponsoredSectionName;
  final String creativeSlot;

  SponsoredAdWidget(
      this.sponsoredAd, this.sponsoredSectionName, this.creativeSlot);
  @override
  _SponsoredAdWidgetState createState() => _SponsoredAdWidgetState();
}

class _SponsoredAdWidgetState extends State<SponsoredAdWidget> {
  bool notLogged = true;
  GlobalKey<State> key = new GlobalKey();
  @override
  Widget build(BuildContext context) {
    //Screen Util Init
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);

    //Provider data
    // var storeProvider = Provider.of<StoreProvider>(context);

    return GestureDetector(
        onTap: () {
          //firebase analytics logging.
          firebaseAnalytics.logSelectPromotion(
            promotionID: widget.sponsoredAd?.link ?? "",
            promotionName: widget.sponsoredAd?.imageUrl ?? "",
            creativeName: (widget.sponsoredSectionName ?? "").trim() == ""
                ? "Sponsored Ad"
                : widget.sponsoredSectionName,
            creativeSlot: widget.creativeSlot ?? "",
            sku: widget.sponsoredAd?.link,
            tileType: "sponsored_ad",
          );

          // storeProvider.setSelectedProductBySKU(sponsoredAd.link);
          // Navigator.of(context).pushNamed(ProductDetail.routeName);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return ProductDetail(
                  sku: widget.sponsoredAd.link ?? "",
                );
              },
            ),
          );
        },
        child: VisibilityDetector(
          key: key,
          onVisibilityChanged: (VisibilityInfo info) {
            if (info.visibleFraction > 0.9 && notLogged) {
              notLogged = false;
              //firebase analytics logging.
              firebaseAnalytics.logViewPromotion(
                promotionID: widget.sponsoredAd?.link ?? "",
                promotionName: widget.sponsoredAd?.imageUrl ?? "",
                creativeName: (widget.sponsoredSectionName ?? "").trim() == ""
                    ? "Sponsored Ad"
                    : widget.sponsoredSectionName,
                creativeSlot: widget.creativeSlot ?? "",
              );
            }
          },
          child: AspectRatio(
            aspectRatio:
                ScreenUtil().setWidth(419) / ScreenUtil().setWidth(184),
            child: ImageWidget(
                fadeInDuration: Duration(milliseconds: 1),
                imageUrl: widget.sponsoredAd.imageUrl,
                fit: BoxFit.fill,
                placeholder: (context, url) =>
                    Image.asset("assets/images/sponsored_ad.png"),
                errorWidget: (context, error, stackTrace) =>
                    Image.memory(kTransparentImage)),
          ),
        ));
  }
}
