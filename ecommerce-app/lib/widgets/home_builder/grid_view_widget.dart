import 'package:Nesto/models/home_builder/grid_view_model.dart';
import 'package:Nesto/models/home_builder/home_page_section.dart';
import 'package:Nesto/utils/style.dart';
import 'package:Nesto/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:transparent_image/transparent_image.dart';

import '../optimized_cache_image_widget.dart';
import 'home_redirection.dart';

class GridViewWidget extends StatelessWidget {
  final HomePageSection pageSection;

  GridViewWidget({this.pageSection});

  @override
  Widget build(BuildContext context) {
    Color startGradient = Colors.white;
    Color endGradient = Colors.white;

    try {
      startGradient = hexToColor(pageSection.startGradient);
      endGradient = hexToColor(pageSection.endGradient);
    } catch (e) {
      print('ERROR in gradient 1 - $e');
    }
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
              startGradient,
              endGradient,
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
            paddingBetweenSections,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: homePageTitlePadding),
              Row(
                children: [
                  Text(
                    pageSection.title.toTitleCase(),
                    style: homeSectionHeading.copyWith(color: Colors.white),
                  ),
                  Spacer(),
                  pageSection.endDate != null && pageSection.endDate != ''
                      ? Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                            color: Colors.green,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 8),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                SizedBox(width: 7),
                                Text(
                                  calculateTimeDifferenceBetween(
                                    endDate: DateFormat("yyyy-MM-dd")
                                        .parse(pageSection.endDate),
                                  ),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container()
                  // pageSection.viewAll != null && pageSection.viewAll == '1'
                  //     ? InkWell(
                  //         onTap: () {
                  //           print('view all');
                  //         },
                  //         child: Padding(
                  //           padding: const EdgeInsets.all(8.0),
                  //           child: Row(
                  //             children: [
                  //               Text(
                  //                 'View all',
                  //                 style: textStyleSmallGreen,
                  //               ),
                  //               SizedBox(width: 5),
                  //               Icon(
                  //                 Icons.arrow_forward_ios_outlined,
                  //                 color: Colors.green,
                  //                 size: 12,
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //       )
                  //     : Container(),
                ],
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
    List<GridViewModel> widgets = pageSection.widgets.cast<GridViewModel>();

    return Column(
      children: [
        widgets.length > 2
            ? _buildItemsRow(context, [widgets[0], widgets[1], widgets[2]])
            : SizedBox(
                height: 0,
              ),
        SizedBox(height: 5),
        widgets.length > 5
            ? _buildItemsRow(context, [widgets[3], widgets[4], widgets[5]])
            : SizedBox(
                height: 0,
              ),
        SizedBox(height: 5),
        widgets.length >= 8
            ? _buildItemsRow(context, [widgets[6], widgets[7], widgets[8]])
            : SizedBox(
                height: 0,
              ),
      ],
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

  String calculateTimeDifferenceBetween({@required DateTime endDate}) {
    DateTime startDate = DateTime.now();

    int seconds = startDate.difference(endDate).inSeconds.abs();
    if (seconds < 60)
      return 'Ends in $seconds seconds';
    else if (seconds >= 60 && seconds < 3600)
      return 'Ends in ${startDate.difference(endDate).inMinutes.abs()} minutes';
    else if (seconds >= 3600 && seconds < 86400)
      return 'Ends in ${startDate.difference(endDate).inHours.abs()} hours';
    else
      return 'Ends in ${startDate.difference(endDate).inDays.abs()} days';
  }

  Widget _buildEachItem(BuildContext context, GridViewModel item) {
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
        height: size.width * 0.33,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(5),
          ),
          color: Colors.white,
        ),
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
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        item.title,
                        style: textStyleVerySmall.copyWith(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 7),
                    FittedBox(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          item.discountLabel,
                          style: TextStyle(
                            // fontSize: size.width * 0.03,
                            color: Color(0XFF2D9140),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
            flex: 4,
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
                            style: TextStyle(
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
                            style: TextStyle(
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
