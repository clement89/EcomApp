import 'package:Nesto/models/dynamic_home_page/deal_card.dart';
import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/screens/product_details.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../optimized_cache_image_widget.dart';

class DealCardWidget extends StatefulWidget {
  final DealCard dealCard;
  final String dealName;
  final String creativeSlot;

  DealCardWidget(this.dealCard, this.dealName, this.creativeSlot);
  @override
  _DealCardWidgetState createState() => _DealCardWidgetState();
}

class _DealCardWidgetState extends State<DealCardWidget> {
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
            promotionID: widget.dealCard?.link ?? "",
            promotionName: widget.dealCard?.imageUrl ?? "",
            creativeName: widget.dealName ?? "",
            creativeSlot: widget.creativeSlot ?? "",
            sku: widget.dealCard?.link,
            tileType: "deal_card",
          );

          // storeProvider.setSelectedProductBySKU(dealCard.link);
          // Navigator.of(context).pushNamed(ProductDetail.routeName);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return ProductDetail(
                  sku: widget.dealCard.link ?? "",
                );
              },
            ),
          );
        },
        child: VisibilityDetector(
          key: key,
          onVisibilityChanged: (VisibilityInfo info) {
            if (info.visibleFraction == 1 && notLogged) {
              notLogged = false;
              //firebase analytics logging.
              firebaseAnalytics.logViewPromotion(
                promotionID: widget.dealCard?.link ?? "",
                promotionName: widget.dealCard?.imageUrl ?? "",
                creativeName: widget.dealName ?? "",
                creativeSlot: widget.creativeSlot ?? "",
              );
            }
          },
          child: Container(
              margin: EdgeInsets.only(
                right: ScreenUtil().setWidth(20),
              ),
              child: AspectRatio(
                aspectRatio:
                    ScreenUtil().setWidth(200) / ScreenUtil().setWidth(140),
                child: ImageWidget(
                  imageUrl: widget.dealCard.imageUrl,
                  fit: BoxFit.fill,
                  placeholder: (context, url) =>
                      Image.asset("assets/images/deal_card.png"),
                  errorWidget: (context, error, stackTrace) =>
                      Image.memory(kTransparentImage),
                ),
              )),
        ));
  }
}
