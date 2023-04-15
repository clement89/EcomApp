import 'package:Nesto/models/home_builder/home_page_section.dart';
import 'package:Nesto/models/home_builder/offer_banner_model.dart';
import 'package:Nesto/utils/style.dart';
import 'package:Nesto/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

import '../optimized_cache_image_widget.dart';
import 'home_redirection.dart';

class OfferBannerWidget extends StatelessWidget {
  final HomePageSection pageSection;

  OfferBannerWidget({this.pageSection});

  final double borderRadios = 12;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        homePageSidePadding,
        0,
        homePageSidePadding,
        paddingBetweenSections,
      ),
      child: _fullWidthItem(context),
    );
  }

  Widget _fullWidthItem(BuildContext context) {
    OfferBannerModel fullWidthItem = pageSection.widgets.first;

    var size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        homeRedirection(
          redirectType: fullWidthItem.redirectType,
          itemCode: fullWidthItem.itemCode,
          context: context,
        );
      },
      child: Container(
        height: size.height * 0.12,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(borderRadios),
          ),
          gradient: LinearGradient(
            colors: [
              hexToColor(fullWidthItem.startGradient),
              hexToColor(fullWidthItem.endGradient),
            ],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(1.0, 0.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(width: 0),
            Flexible(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: size.width * 0.035,
                    horizontal: size.width * 0.026),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullWidthItem.discountLabel ?? '',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: size.width * 0.048,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    fullWidthItem.title == null
                        ? Container()
                        : Text(
                            fullWidthItem.title ?? '',
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: size.width * 0.03,
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                  ],
                ),
              ),
            ),
            Spacer(),
            Flexible(
              flex: 3,
              child: ImageWidget(
                fadeInDuration: Duration(milliseconds: 1),
                imageUrl: fullWidthItem.imageUrl,
                fit: BoxFit.fill,
                // placeholder: (context, url) =>
                //     Image.asset("assets/images/main_offer.png"),
                errorWidget: (context, error, stackTrace) =>
                    Image.memory(kTransparentImage),
              ),
            ),
            SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1)}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}
