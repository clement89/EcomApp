import 'package:Nesto/models/home_builder/circular_grid_model.dart';
import 'package:Nesto/models/home_builder/home_page_section.dart';
import 'package:Nesto/utils/style.dart';
import 'package:Nesto/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

import '../optimized_cache_image_widget.dart';
import 'home_redirection.dart';

class CircularGridWidget extends StatelessWidget {
  final HomePageSection pageSection;

  CircularGridWidget({this.pageSection});

  @override
  Widget build(BuildContext context) {
    //Screen Util Init

    if (pageSection.widgets.length == 0) {
      return Container();
    }

    List<CircularGridModel> widgets =
        pageSection.widgets.cast<CircularGridModel>();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        homePageSidePadding,
        0,
        homePageSidePadding,
        paddingBetweenSections,
      ),
      child: Column(
        children: [
          _titleWidget(context),
          Center(
            child: Wrap(
              alignment: WrapAlignment.start,
              spacing: 20.0, // gap between adjacent chips
              runSpacing: 15.0, // gap between lines
              children: items(widgets, context),
            ),
          ),
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
      ],
    );
  }

  List<Widget> items(List<CircularGridModel> widgets, BuildContext context) {
    List<Widget> itemList = [];
    widgets.forEach((element) {
      itemList.add(_gridItem(context, element));
    });
    return itemList;
  }

  Widget _gridItem(BuildContext context, CircularGridModel item) {
    return InkWell(
      onTap: () {
        homeRedirection(
          redirectType: item.redirectType,
          itemCode: item.itemCode,
          context: context,
        );
      },
      child: _item(
        context,
        item,
      ),
    );
  }

  Widget _item(BuildContext context, CircularGridModel item) {
    if (item.widgetCode == 'SQUARE_GRID_ITEMS') {
      return _squareItem(context, item);
    } else if (item.borderStartGradient.isNotEmpty &&
        item.borderEndGradient.isNotEmpty) {
      return _circularItem(context, item);
    }

    return _circularGradientItem(context, item);
  }

  Widget _circularItem(BuildContext context, CircularGridModel item) {
    var size = MediaQuery.of(context).size;

    double width = size.width * 0.2;

    BoxDecoration kInnerDecoration = BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white,
      border: Border.all(color: Colors.white),
    );

    // print('okkk - ${item.startGradient.length}');

    if (item.startGradient.length > 0 && item.endGradient.length > 0) {
      kInnerDecoration = BoxDecoration(
        borderRadius: BorderRadius.circular(width / 2),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            hexToColor(item.startGradient),
            hexToColor(item.endGradient),
          ],
        ),
      );
    }

    BoxDecoration kGradientBoxDecoration = BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        colors: [
          hexToColor(item.borderStartGradient.length > 1
              ? item.borderStartGradient
              : 'A3E4DB'),
          hexToColor(item.borderEndGradient.length > 1
              ? item.borderEndGradient
              : 'CDDEFF'),
        ],
      ),
    );

    return Column(
      children: [
        SizedBox(
          width: width,
          height: width,
          child: Container(
            decoration: kGradientBoxDecoration,
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                decoration: kInnerDecoration,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(width / 2),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ImageWidget(
                      fadeInDuration: Duration(milliseconds: 1),
                      imageUrl: item.imageUrl,
                      fit: BoxFit.fitHeight,
                      placeholder: (context, url) =>
                          Image.memory(kTransparentImage),
                      errorWidget: (context, error, stackTrace) =>
                          Image.memory(kTransparentImage),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 5),
        SizedBox(
          width: width,
          child: Text(
            item.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: textStyleSmall.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        )
      ],
    );
  }

  Widget _squareItem(BuildContext context, CircularGridModel item) {
    var size = MediaQuery.of(context).size;

    double width = size.width * 0.2;

    BoxDecoration kGradientBoxDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(6),
      gradient: LinearGradient(
        colors: [
          hexToColor(item.startGradient),
          hexToColor(item.endGradient),
        ],
      ),
    );

    return Column(
      children: [
        SizedBox(
          width: width,
          height: width,
          child: Container(
            decoration: kGradientBoxDecoration,
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ImageWidget(
                    fadeInDuration: Duration(milliseconds: 1),
                    imageUrl: item.imageUrl,
                    fit: BoxFit.fitHeight,
                    placeholder: (context, url) =>
                        Image.memory(kTransparentImage),
                    errorWidget: (context, error, stackTrace) =>
                        Image.memory(kTransparentImage),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 5),
        SizedBox(
          width: width,
          child: Text(
            item.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: textStyleSmall.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        )
      ],
    );
  }

  Widget _circularGradientItem(BuildContext context, CircularGridModel item) {
    var size = MediaQuery.of(context).size;

    double width = size.width * 0.2;

    // print('startGradient - ${item.startGradient}');
    // print('endGradient - ${item.endGradient}');

    BoxDecoration kGradientBoxDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(width / 2),
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          hexToColor(item.startGradient),
          hexToColor(item.endGradient),
        ],
      ),
    );

    return Column(
      children: [
        SizedBox(
          width: width,
          height: width,
          child: Container(
            decoration: kGradientBoxDecoration,
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ImageWidget(
                    fadeInDuration: Duration(milliseconds: 1),
                    imageUrl: item.imageUrl,
                    fit: BoxFit.fitHeight,
                    placeholder: (context, url) =>
                        Image.memory(kTransparentImage),
                    errorWidget: (context, error, stackTrace) =>
                        Image.memory(kTransparentImage),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 5),
        SizedBox(
          width: width,
          child: Text(
            item.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: textStyleSmall.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        )
      ],
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
