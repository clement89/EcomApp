import 'package:Nesto/models/home_builder/home_page_section.dart';
import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/widgets/home_builder/three_banner_widget.dart';
import 'package:Nesto/widgets/home_builder/two_banner_grid_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:provider/provider.dart';

import 'adbanner_widget.dart';
import 'carousel_widget.dart';
import 'circular_grid_widget.dart';
import 'deals_v2_widget.dart';
import 'deals_view_widget.dart';
import 'grid_view_widget.dart';
import 'no_margin_banner_widget.dart';
import 'offer_banner_widget.dart';

class MultiWidgetList extends StatelessWidget {
  final List<HomePageSection> widgetList;
  final Widget header;
  const MultiWidgetList({
    @required this.widgetList,
    this.header,
  });

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);
    return SafeArea(
      child: _homeWidgets(context),
    );
  }

  Widget _homeWidgets(BuildContext context) {
    int cartLength = context.read<StoreProvider>().cartCount ?? 0;

    return ListView.builder(
      padding: EdgeInsets.only(bottom: cartLength > 0 ? 60 : 0),
      cacheExtent: widgetList.length * ScreenUtil().setHeight(896),
      itemCount: header == null ? widgetList.length : widgetList.length + 1,
      itemBuilder: (context, index) {
        if (index == 0 && header != null) {
          return header;
        } else {
          HomePageSection pageSection =
              header == null ? widgetList[index] : widgetList[index - 1];
          if (pageSection.type == 'FULL_IMAGE_CAROUSEL') {
            return FullImageCarouselWidget(
              pageSection: pageSection,
            );
          } else if (pageSection.type == 'GRID') {
            return CircularGridWidget(
              pageSection: pageSection,
            );
          } else if (pageSection.type == 'AD_BANNER') {
            return AdBannerWidget(
              pageSection: pageSection,
            );
          } else if (pageSection.type == 'THREE_BANNER_GRID') {
            return ThreeBannerGridWidget(
              pageSection: pageSection,
            );
          } else if (pageSection.type == 'OFFER_BANNER') {
            return OfferBannerWidget(
              pageSection: pageSection,
            );
          } else if (pageSection.type == 'NO_MARGIN_BANNER') {
            return NoMarginBannerWidget(
              pageSection: pageSection,
            );
          } else if (pageSection.type == 'GRID_VIEW') {
            return GridViewWidget(
              pageSection: pageSection,
            );
          } else if (pageSection.type == 'TWO_BANNER_GRID') {
            return TwoBannerGridWidget(
              pageSection: pageSection,
            );
          } else if (pageSection.type == 'DEALS_VIEW') {
            return DealsViewWidget(
              pageSection: pageSection,
            );
          } else if (pageSection.type == 'DEALS_VIEW_V2') {
            return DealsV2Widget(
              pageSection: pageSection,
            );
          }
        }
        return SizedBox();
      },
      // Builds 1000 ListTiles
    );
  }
}
