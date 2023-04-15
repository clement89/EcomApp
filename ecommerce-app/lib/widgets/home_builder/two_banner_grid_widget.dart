import 'package:Nesto/models/home_builder/home_page_section.dart';
import 'package:Nesto/models/home_builder/two_banner_grid.dart';
import 'package:Nesto/utils/style.dart';
import 'package:Nesto/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:transparent_image/transparent_image.dart';

import '../optimized_cache_image_widget.dart';
import 'home_redirection.dart';

class TwoBannerGridWidget extends StatelessWidget {
  final HomePageSection pageSection;

  TwoBannerGridWidget({this.pageSection});

  @override
  Widget build(BuildContext context) {
    if (pageSection.widgets.isEmpty) {
      return Container();
    }

    return Container(
      // color: Colors.white,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          homePageSidePadding,
          0,
          homePageSidePadding,
          paddingBetweenSections,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: homePageTitlePadding),
            Row(
              children: [
                pageSection.title != null
                    ? Text(
                        pageSection.title.toTitleCase(),
                        style: homeSectionHeading,
                      )
                    : SizedBox(height: 0),
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
            SizedBox(height: homePageTitlePadding),
            _buildItems(context),
          ],
        ),
      ),
    );
  }

  Widget _buildItems(BuildContext context) {
    List<TwoBannerGridModel> widgets =
        pageSection.widgets.cast<TwoBannerGridModel>();

    return _buildItemsRow(context, [widgets[0], widgets[1]]);
  }

  Widget _buildItemsRow(BuildContext context, List<TwoBannerGridModel> items) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 1,
          child: _buildEachItem(context, items[0]),
        ),
        SizedBox(width: 10),
        Expanded(
          flex: 1,
          child: _buildEachItem(context, items[1]),
        ),
      ],
    );
  }

  Widget _buildEachItem(BuildContext context, TwoBannerGridModel item) {
    if (item.widgetCode == 'TWO_BANNER_IMAGE_V1') {
      return _itemOne(context, item);
    } else {
      return _itemTwo(context, item);
    }
  }

  Widget _itemOne(BuildContext context, TwoBannerGridModel item) {
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
        height: size.width * 0.25,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
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
          children: [
            Flexible(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(7.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SizedBox(
                        width: size.width * 0.24,
                        child: Text(
                          item.discountLabel,
                          maxLines: 2,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    //SizedBox(height: 15),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(4),
                        ),
                        color: hexToColor(item.buttonColor),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Text(
                          item.buttonName,
                          style: TextStyle(
                            fontSize: 12,
                            color: hexToColor(item.buttonFontColor),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: size.width * 0.16,
                child: ImageWidget(
                  fadeInDuration: Duration(milliseconds: 1),
                  imageUrl: item.imageUrl,
                  fit: BoxFit.fill,
                  // placeholder: (context, url) =>
                  //     Image.asset("assets/images/main_offer.png"),
                  errorWidget: (context, error, stackTrace) =>
                      Image.memory(kTransparentImage),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemTwo(BuildContext context, TwoBannerGridModel item) {
    var size = MediaQuery.of(context).size;
    int days = calculateTimeDifferenceBetween(item);

    var readLines = item.title.split(' ');
    StringBuffer sb = new StringBuffer();
    int i = 0;
    for (String line in readLines) {
      if (i == 2) {
        sb.write(line + "\n");
      }
      sb.write(line + " ");

      i++;
    }
    String newTitle = sb.toString();

    return GestureDetector(
      onTap: () {
        homeRedirection(
          redirectType: item.redirectType,
          itemCode: item.itemCode,
          context: context,
        );
      },
      child: Stack(
        children: [
          Container(
            // height: size.width * 0.33,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(5),
              ),
              gradient: LinearGradient(
                colors: [
                  hexToColor(item.startGradient),
                  hexToColor(item.endGradient),
                ],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(1.0, 0.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Flexible(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(7.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Text(
                                item.discount,
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(width: 5),
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '%',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'OFF',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Text(
                              //   'on',
                              //   style: TextStyle(
                              //     fontSize: 14,
                              //     color: Colors.black,
                              //     fontWeight: FontWeight.normal,
                              //   ),
                              // ),
                              SizedBox(
                                height: size.height * 0.042,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FittedBox(
                                      child: Text(
                                        newTitle,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          // fontSize: 11.5,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.originalPrice + ' AED',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              FittedBox(
                                child: Text(
                                  item.discountPrice + ' AED',
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ImageWidget(
                        fadeInDuration: Duration(milliseconds: 1),
                        imageUrl: item.imageUrl,
                        fit: BoxFit.fill,
                        // placeholder: (context, url) =>
                        //     Image.asset("assets/images/main_offer.png"),
                        errorWidget: (context, error, stackTrace) =>
                            Image.memory(kTransparentImage),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          days > 0
              ? Positioned(
                  right: 0,
                  top: 10,
                  child: SizedBox(
                    width: size.width * 0.27,
                    child: Stack(
                      children: [
                        Image.asset(
                          'assets/images/offerBanner.png',
                        ),
                        Positioned(
                          right: 10,
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Text(
                                days.toString() + ' DAY OFFER',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SizedBox(
                  height: 0,
                ),
        ],
      ),
    );
  }

  int calculateTimeDifferenceBetween(TwoBannerGridModel item) {
    DateTime startDate = DateFormat("yyyy-MM-dd").parse(item.startDate);
    DateTime endDate = DateFormat("yyyy-MM-dd").parse(item.endDate);

    if (item.startDate.isNotEmpty && item.endDate.isNotEmpty) {
      return startDate.difference(endDate).inDays.abs();
    } else {
      return 0;
    }
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
