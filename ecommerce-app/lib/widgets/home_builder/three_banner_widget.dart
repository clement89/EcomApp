import 'package:Nesto/models/home_builder/home_page_section.dart';
import 'package:Nesto/models/home_builder/three_banner_model.dart';
import 'package:Nesto/utils/style.dart';
import 'package:Nesto/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

import '../optimized_cache_image_widget.dart';
import 'home_redirection.dart';

class ThreeBannerGridWidget extends StatelessWidget {
  final HomePageSection pageSection;

  ThreeBannerGridWidget({this.pageSection});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _titleWidget(context),
          _fullWidthItem(context),
          SizedBox(height: 5),
          _halfWidthRow(context),
        ],
      ),
    );
  }

  Widget _titleWidget(BuildContext context) {
    if (pageSection.title == null) {
      return SizedBox(height: 0);
    }
    if (pageSection.title.isEmpty) {
      return SizedBox(height: 0);
    }
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: homePageTitlePadding),
          child: Row(
            children: [
              pageSection.title != null
                  ? Text(
                      pageSection.title.toTitleCase(),
                      style: homeSectionHeading,
                    )
                  : Container(),
              Spacer(),
              pageSection.viewAll
                  ? InkWell(
                      onTap: () {
                        print('view all');
                        homeRedirection(
                          redirectType: pageSection.redirectType,
                          itemCode: pageSection.itemCode,
                          context: context,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Text(
                              'View all',
                              style: textStyleSmallGreen,
                            ),
                            SizedBox(width: 5),
                            Icon(
                              Icons.arrow_forward_ios_outlined,
                              color: Colors.green,
                              size: 12,
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _fullWidthItem(BuildContext context) {
    List<ThreeBannerGridModel> widgets =
        pageSection.widgets.cast<ThreeBannerGridModel>();

    ThreeBannerGridModel fullWidthItem = widgets.firstWhere(
        (element) => element.widgetCode == 'FULL_WIDTH_BANNER', orElse: () {
      return null;
    });

    var size = MediaQuery.of(context).size;

    Color startGradient = Colors.redAccent;
    Color endGradient = Colors.redAccent;

    try {
      startGradient = hexToColor(fullWidthItem.startGradient);
      endGradient = hexToColor(fullWidthItem.endGradient);
    } catch (e) {
      print('ERROR in gradient 1 - $fullWidthItem');
    }

    return GestureDetector(
      onTap: () {
        homeRedirection(
          redirectType: fullWidthItem.redirectType,
          itemCode: fullWidthItem.itemCode,
          context: context,
        );
      },
      child: Container(
        height: size.height * 0.18,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(borderRadios),
          ),
          gradient: LinearGradient(
            colors: [
              startGradient,
              endGradient,
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
            SizedBox(width: 10),
            Flexible(
              flex: 1,
              child: Text(
                fullWidthItem.title,
                maxLines: 2,
                style: TextStyle(
                  fontSize: size.width * 0.07,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 10),
            Flexible(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
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
            ),
            SizedBox(width: 10),
          ],
        ),
      ),
    );
  }

  Widget _halfWidthRow(
    BuildContext context,
  ) {
    List<ThreeBannerGridModel> widgets =
        pageSection.widgets.cast<ThreeBannerGridModel>();

    List<ThreeBannerGridModel> halfWidthItems = [];

    halfWidthItems = widgets
        .where((element) => element.widgetCode == 'HALF_WIDTH_BANNER')
        .toList();

    if (halfWidthItems.length < 2) {
      return Container();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 1,
          child: _halfWidthItem(context, halfWidthItems[0]),
        ),
        SizedBox(width: 5),
        Flexible(
          flex: 1,
          child: _halfWidthItem(context, halfWidthItems[1]),
        ),
      ],
    );
  }

  Widget _halfWidthItem(BuildContext context, ThreeBannerGridModel item) {
    var size = MediaQuery.of(context).size;

    Color startGradient = Colors.redAccent;
    Color endGradient = Colors.redAccent;

    try {
      startGradient = hexToColor(item.startGradient);
      endGradient = hexToColor(item.endGradient);
    } catch (e) {
      print('ERROR in gradient 2 - $e');
    }

    return GestureDetector(
      onTap: () {
        homeRedirection(
          redirectType: item.redirectType,
          itemCode: item.itemCode,
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
              startGradient,
              endGradient,
            ],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(1.0, 0.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              flex: 7,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  item.title,
                  maxLines: 4,
                  style: TextStyle(
                    fontSize: size.width * 0.033,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 5,
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
