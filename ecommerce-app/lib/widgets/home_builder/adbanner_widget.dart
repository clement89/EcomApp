import 'package:Nesto/models/home_builder/ad_banner_model.dart';
import 'package:Nesto/models/home_builder/home_page_section.dart';
import 'package:Nesto/utils/style.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

import '../optimized_cache_image_widget.dart';
import 'home_redirection.dart';

class AdBannerWidget extends StatelessWidget {
  final HomePageSection pageSection;

  AdBannerWidget({this.pageSection});

  final double borderRadios = 12;

  @override
  Widget build(BuildContext context) {
    AdBannerModel item = pageSection.widgets.first;

    if (item.widgetCode == 'AD_BANNER_IMAGE') {
      return _adBannerImage(context, item);
    } else {
      return Container();
    }
  }

  Widget _adBannerImage(BuildContext context, AdBannerModel item) {
    var size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        homeRedirection(
          redirectType: item.redirectType,
          itemCode: item.itemCode,
          context: context,
        );
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          homePageSidePadding,
          0,
          homePageSidePadding,
          paddingBetweenSections,
        ),
        child: Container(
          child: Container(
            height: size.height * 0.11,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6.0),
              child: ImageWidget(
                fadeInDuration: Duration(milliseconds: 1),
                imageUrl: item.imageUrl,
                fit: BoxFit.fill,
                placeholder: (context, url) =>
                    Image.asset("assets/images/main_offer.png"),
                errorWidget: (context, error, stackTrace) =>
                    Image.memory(kTransparentImage),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
