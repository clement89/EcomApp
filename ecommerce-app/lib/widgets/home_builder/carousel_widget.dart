import 'package:Nesto/models/home_builder/full_image_carousel.dart';
import 'package:Nesto/models/home_builder/home_page_section.dart';
import 'package:Nesto/utils/style.dart';
import 'package:Nesto/widgets/home_builder/home_redirection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:transparent_image/transparent_image.dart';

import '../optimized_cache_image_widget.dart';

class FullImageCarouselWidget extends StatefulWidget {
  final HomePageSection pageSection;

  FullImageCarouselWidget({this.pageSection});
  @override
  _FullImageCarouselWidgetState createState() =>
      _FullImageCarouselWidgetState();
}

class _FullImageCarouselWidgetState extends State<FullImageCarouselWidget> {
  @override
  Widget build(BuildContext context) {
    return _fullWidthItemList();
  }

  Widget _fullWidthItemList() {
    List<CarouselModel> widgets =
        widget.pageSection.widgets.cast<CarouselModel>();
    var size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.only(
        bottom: paddingBetweenSections,
      ),
      child: SizedBox(
        height: size.height * 0.2,
        width: size.width,
        child: Swiper(
          loop: widgets.length > 1 ? true : false,
          itemBuilder: (BuildContext context, int index) {
            return fullWidthItem(widget.pageSection.widgets[index]);
          },
          pagination: widgets.length > 1
              ? SwiperPagination(
                  margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 15.0),
                  builder: DotSwiperPaginationBuilder(
                    color: Colors.white30,
                    activeColor: Colors.white,
                    size: 8.0,
                    activeSize: 8.0,
                  ),
                )
              : null,
          autoplay: widgets.length > 1 ? true : false,
          itemCount: widgets.length,
          control: SwiperControl(
            iconPrevious: null,
            iconNext: null,
          ),
        ),
      ),
    );
  }

  Widget fullWidthItem(CarouselModel item) {
    return GestureDetector(
      onTap: () {
        // firebase analytics logging.

        // firebaseAnalytics.logSelectPromotion(
        //   promotionID: widget.mainOfferBanner?.link ?? "",
        //   promotionName: widget.mainOfferBanner?.imageUrl ?? "",
        //   creativeSlot: widget.creativeSlot ?? "",
        //   creativeName: widget.mainOfferBanner?.title ?? "",
        //   categoryID: widget.mainOfferBanner?.link ?? "",
        //   tileType: "main_offer_banner",
        // );

        homeRedirection(
          redirectType: item.redirectType,
          itemCode: item.itemCode,
          context: context,
        );
      },
      child: ImageWidget(
        fadeInDuration: Duration(milliseconds: 1),
        imageUrl: item.imageUrl,
        fit: BoxFit.fill,
        // placeholder: (context, url) =>
        //     Image.asset("assets/images/main_offer.png"),
        errorWidget: (context, error, stackTrace) =>
            Image.memory(kTransparentImage),
      ),
    );
  }
}
