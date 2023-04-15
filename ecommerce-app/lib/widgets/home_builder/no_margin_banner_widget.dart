import 'package:Nesto/models/home_builder/home_page_section.dart';
import 'package:Nesto/models/home_builder/no_margin_banner_model.dart';
import 'package:Nesto/utils/style.dart';
import 'package:Nesto/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:transparent_image/transparent_image.dart';

import '../optimized_cache_image_widget.dart';
import 'home_redirection.dart';

class NoMarginBannerWidget extends StatelessWidget {
  final HomePageSection pageSection;

  NoMarginBannerWidget({this.pageSection});

  final double borderRadios = 12;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        0,
        0,
        0,
        paddingBetweenSections,
      ),
      child: Column(
        children: [
          _buildTitle(context),
          _fullWidthItem(context),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
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
        SizedBox(height: homePageTitlePadding),
      ],
    );
  }

  Widget _fullWidthItem(BuildContext context) {
    NoMarginBannerModel item = pageSection.widgets.first;

    if (item.widgetCode == 'NO_MARGIN_ITEM') {
      return _item(context);
    } else {
      return _onlyImageItem(context);
    }
  }

  Widget _item(BuildContext context) {
    NoMarginBannerModel fullWidthItem = pageSection.widgets.first;

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
        height: size.height * 0.15,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(0),
          ),
          // color: Color(0XFFFFCCD2),
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
          children: [
            SizedBox(width: 10),
            Flexible(
              flex: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: size.width * 0.5,
                    child: Text(
                      fullWidthItem.title,
                      textAlign: TextAlign.left,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: size.width * 0.05,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(4),
                      ),
                      color: hexToColor(fullWidthItem.buttonColor),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(7.0),
                      child: Text(
                        fullWidthItem.buttonName,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 12,
                          color: hexToColor(fullWidthItem.buttonFontColor),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
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

  Widget fullWidthItem(NoMarginBannerModel item, BuildContext context) {
    var size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        homeRedirection(
          redirectType: item.redirectType,
          itemCode: item.itemCode,
          context: context,
        );
      },
      child: Container(
        child: Container(
          height: size.height * 0.2,
          width: size.width,
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
    );
  }

  Widget _onlyImageItem(BuildContext context) {
    List<NoMarginBannerModel> widgets =
        pageSection.widgets.cast<NoMarginBannerModel>();

    var size = MediaQuery.of(context).size;

    return SizedBox(
      height: size.height * 0.2,
      width: size.width,
      child: Swiper(
        loop: widgets.length > 1 ? true : false,
        itemBuilder: (BuildContext context, int index) {
          return fullWidthItem(pageSection.widgets[index], context);
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
