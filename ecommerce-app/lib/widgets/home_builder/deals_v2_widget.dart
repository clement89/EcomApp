import 'package:Nesto/models/home_builder/deals_v2_model.dart';
import 'package:Nesto/models/home_builder/grid_view_model.dart';
import 'package:Nesto/models/home_builder/home_page_section.dart';
import 'package:Nesto/utils/style.dart';
import 'package:Nesto/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

import '../optimized_cache_image_widget.dart';
import 'home_redirection.dart';

class DealsV2Widget extends StatelessWidget {
  final HomePageSection pageSection;

  DealsV2Widget({this.pageSection});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        0,
        0,
        0,
        paddingBetweenSections,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              pageSection.startGradient != null
                  ? hexToColor(pageSection.startGradient)
                  : Colors.white,
              pageSection.endGradient != null
                  ? hexToColor(pageSection.endGradient)
                  : Colors.white,
            ],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(1.0, 0.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            homePageSidePadding,
            0,
            homePageSidePadding,
            homePageSidePadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: homePageTitlePadding),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Text(
                      pageSection.title != null
                          ? pageSection.title.toTitleCase()
                          : '',
                      style: homeSectionHeading.copyWith(color: Colors.white),
                    ),
                    Spacer(),
                    // Row(
                    //   children: [
                    //     Text(
                    //       'See all deals',
                    //       style: textStyleSmall.copyWith(color: Colors.black),
                    //     ),
                    //     SizedBox(width: 5),
                    //     Icon(
                    //       Icons.arrow_forward_ios_outlined,
                    //       color: Colors.black,
                    //       size: 12,
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
              SizedBox(height: homePageTitlePadding),
              _buildItems(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItems(BuildContext context) {
    var size = MediaQuery.of(context).size;

    List<DealsV2Model> widgets = pageSection.widgets.cast<DealsV2Model>();

    DealsV2Model combinationItem = widgets.firstWhere((element) =>
        element.widgetCode ==
        (pageSection.type == 'DEALS_VIEW'
            ? 'COMBINATION_DEAL_ITEM'
            : 'DEALS_V2_MAIN_ITEM'));

    List<DealsV2Model> sliderItems = widgets
        .where((element) =>
            element.widgetCode ==
            (pageSection.type == 'DEALS_VIEW'
                ? 'DEALS_SLIDER_ITEM'
                : 'DEALS_V2_SLIDER_ITEM'))
        .toList();

    return Column(
      children: [
        Container(
          height: size.height * 0.46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(8),
            ),
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                Flexible(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: GestureDetector(
                      onTap: () {
                        homeRedirection(
                          redirectType: combinationItem.redirectType,
                          itemCode: combinationItem.itemCode,
                          context: context,
                        );
                      },
                      child: ImageWidget(
                        fadeInDuration: Duration(milliseconds: 1),
                        imageUrl: combinationItem.imageUrl,
                        fit: BoxFit.fill,
                        // placeholder: (context, url) =>
                        //     Image.asset("assets/images/main_offer.png"),
                        errorWidget: (context, error, stackTrace) =>
                            Image.memory(kTransparentImage),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pageSection.subTitle1 != null
                          ? pageSection.subTitle1
                          : '',
                      style: textStyleLight.copyWith(color: Colors.black),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          pageSection.originalPrice != null
                              ? pageSection.originalPrice
                              : '',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          pageSection.currentPrice != null
                              ? pageSection.currentPrice
                              : '',
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.normal,
                            decoration: TextDecoration.lineThrough,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      pageSection.title2 != null
                          ? pageSection.title2.toTitleCase()
                          : '',
                      style: homeSectionHeading.copyWith(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                SizedBox(
                  height: size.height * 0.13,
                  child: ListView.builder(
                    itemCount: sliderItems.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, int index) {
                      return _productWidget(context, sliderItems[index]);
                    },
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _productWidget(BuildContext context, DealsV2Model item) {
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
        padding: const EdgeInsets.only(right: 10),
        child: Container(
          height: size.height * 0.22,
          width: size.width * 0.3,
          decoration: BoxDecoration(
            color: Colors.white,
          ),
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
      ),
    );
  }

  Widget _buildItemsRow(BuildContext context, List<GridViewModel> items) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 1,
          child: _buildEachItem(context, items[0]),
        ),
        SizedBox(width: 5),
        Expanded(
          flex: 1,
          child: _buildEachItem(context, items[1]),
        ),
        SizedBox(width: 5),
        Expanded(
          flex: 1,
          child: _buildEachItem(context, items[2]),
        ),
      ],
    );
  }

  Widget _buildEachItem(BuildContext context, GridViewModel item) {
    var size = MediaQuery.of(context).size;

    return Container(
      height: size.width * 0.33,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(5),
          ),
          color: Colors.white),
      child: Column(
        children: [
          Flexible(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
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
          Flexible(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: textStyleVerySmall.copyWith(color: Colors.black),
                      ),
                      SizedBox(height: 5),
                      FittedBox(
                        child: Text(
                          item.discountLabel,
                          style: textStyleVerySmall.copyWith(
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEachItemNew(BuildContext context, GridViewModel item) {
    var size = MediaQuery.of(context).size;

    return Container(
      height: size.width * 0.4,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(5),
          ),
          color: Colors.white),
      child: Column(
        children: [
          Flexible(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
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
          Flexible(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: textStyleVerySmall.copyWith(color: Colors.black),
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '2000',
                            style: textStyleBig.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                            child: VerticalDivider(
                              color: Colors.green,
                              width: 20,
                              thickness: 1,
                            ),
                          ),
                          Text(
                            item.discountLabel,
                            style: textStyleBig.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
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
