import 'package:Nesto/models/home_builder/ad_banner_model.dart';
import 'package:Nesto/models/home_builder/deals_v2_model.dart';
import 'package:Nesto/models/home_builder/deals_view_model.dart';
import 'package:Nesto/models/home_builder/full_image_carousel.dart';
import 'package:Nesto/models/home_builder/grid_view_model.dart';
import 'package:Nesto/models/home_builder/no_margin_banner_model.dart';
import 'package:Nesto/models/home_builder/offer_banner_model.dart';
import 'package:Nesto/models/home_builder/three_banner_model.dart';
import 'package:Nesto/models/home_builder/two_banner_grid.dart';
import 'package:flutter/cupertino.dart';

import 'circular_grid_model.dart';

const String ITEM_TYPE_CATEGORY = 'cat';
const String FULL_WIDTH_BANNER = 'full_width_banner';

class HomePageSection {
  String type;
  int position;
  String name;
  String title;
  String title2;
  String subTitle1;
  String priceRange;
  String currentPrice;
  String originalPrice;

  String backgroundColor;
  bool viewAll;
  String startDate;
  String endDate;
  String startGradient;
  String endGradient;

  String redirectType;
  String itemCode;

  List<dynamic> widgets;
  HomePageSection({
    @required this.type,
    @required this.position,
    @required this.widgets,
    @required this.name,
    @required this.title,
    @required this.title2,
    @required this.subTitle1,
    @required this.priceRange,
    @required this.backgroundColor,
    @required this.viewAll,
    @required this.startDate,
    @required this.endDate,
    @required this.startGradient,
    @required this.endGradient,
    @required this.currentPrice,
    @required this.originalPrice,
    @required this.redirectType,
    @required this.itemCode,
  });

  factory HomePageSection.fromJson(Map<String, dynamic> json) {
    List<dynamic> widgetsTemp = [];
    String type = '';
    String title = '';
    String title2 = '';
    String subTitle1 = '';
    String priceRange = '';
    String currentPrice = '';
    String originalPrice = '';

    String backgroundColor = '';
    bool viewAll = false;
    String startDate = '';
    String endDate = '';
    String startGradient = '';
    String endGradient = '';

    String redirectType = '';
    String itemCode = '';
    try {
      title = json['subTemplate']['details']['title'] ??
          json['subTemplate']['details']['title'];
      backgroundColor = json['subTemplate']['details']['backgroundColor'] ??
          json['subTemplate']['details']['backgroundColor'];
      // viewAll = json['subTemplate']['details']['viewAll'] ??
      //     json['subTemplate']['details']['viewAll'];

      startDate = json['subTemplate']['details']['startDate'] ??
          json['subTemplate']['details']['startDate'];
      endDate = json['subTemplate']['details']['endDate'] ??
          json['subTemplate']['details']['endDate'];
      startGradient = json['subTemplate']['details']['startGradient'] ??
          json['subTemplate']['details']['startGradient'];
      endGradient = json['subTemplate']['details']['endGradient'] ??
          json['subTemplate']['details']['endGradient'];
      title2 = json['subTemplate']['details']['title2'] ??
          json['subTemplate']['details']['title2'];
      subTitle1 = json['subTemplate']['details']['subTitle1'] ??
          json['subTemplate']['details']['subTitle1'];
      priceRange = json['subTemplate']['details']['priceRange'] ??
          json['subTemplate']['details']['priceRange'];
      currentPrice = json['subTemplate']['details']['currentPrice'] ??
          json['subTemplate']['details']['currentPrice'];
      originalPrice = json['subTemplate']['details']['originalPrice'] ??
          json['subTemplate']['details']['originalPrice'];

      redirectType = json['subTemplate']['details']['redirectType'] ??
          json['subTemplate']['details']['redirectType'];
      itemCode = json['subTemplate']['details']['itemCode'] ??
          json['subTemplate']['details']['itemCode'];

      if (json['subTemplate']['details']['viewAll'] != null) {
        try {
          viewAll = json['subTemplate']['details']['viewAll'];
        } catch (e) {
          if (json['subTemplate']['details']['viewAll'].toString() == '1') {
            viewAll = true;
          }
          print('Error parsing details 1- $e');
          // print(json['subTemplate']['details']);
        }
      }
    } catch (e) {
      print('Error parsing details - $e');
      viewAll = false;
      // print(json['subTemplate']['details']);
    }

    if (json['subTemplate'] != null) {
      type = json['subTemplate']['sectionCode'];

      if (type == 'FULL_IMAGE_CAROUSEL') {
        widgetsTemp = List<dynamic>.from(
          ((json["subTemplate"]['widget'] ?? []) as List<dynamic>).map(
            (allWidgets) => CarouselModel.fromJson(allWidgets),
          ),
        );
      } else if (type == 'THREE_BANNER_GRID') {
        widgetsTemp = List<dynamic>.from(
          ((json["subTemplate"]['widget'] ?? []) as List<dynamic>).map(
            (allWidgets) => ThreeBannerGridModel.fromJson(allWidgets),
          ),
        );
      } else if (type == 'GRID') {
        widgetsTemp = List<dynamic>.from(
          ((json["subTemplate"]['widget'] ?? []) as List<dynamic>).map(
            (allWidgets) => CircularGridModel.fromJson(allWidgets),
          ),
        );
      } else if (type == 'GRID_VIEW') {
        widgetsTemp = List<dynamic>.from(
          ((json["subTemplate"]['widget'] ?? []) as List<dynamic>).map(
            (allWidgets) => GridViewModel.fromJson(allWidgets),
          ),
        );
      } else if (type == 'GRAB_OR_GONE') {
        widgetsTemp = List<dynamic>.from(
          ((json["subTemplate"]['widget'] ?? []) as List<dynamic>).map(
            (allWidgets) => TwoBannerGridModel.fromJson(allWidgets),
          ),
        );
      } else if (type == 'AD_BANNER') {
        widgetsTemp = List<dynamic>.from(
          ((json["subTemplate"]['widget'] ?? []) as List<dynamic>).map(
            (allWidgets) => AdBannerModel.fromJson(allWidgets),
          ),
        );
      } else if (type == 'OFFER_BANNER') {
        widgetsTemp = List<dynamic>.from(
          ((json["subTemplate"]['widget'] ?? []) as List<dynamic>).map(
            (allWidgets) => OfferBannerModel.fromJson(allWidgets),
          ),
        );
      } else if (type == 'NO_MARGIN_BANNER') {
        widgetsTemp = List<dynamic>.from(
          ((json["subTemplate"]['widget'] ?? []) as List<dynamic>).map(
            (allWidgets) => NoMarginBannerModel.fromJson(allWidgets),
          ),
        );
      } else if (type == 'TWO_BANNER_GRID') {
        widgetsTemp = List<dynamic>.from(
          ((json["subTemplate"]['widget'] ?? []) as List<dynamic>).map(
            (allWidgets) => TwoBannerGridModel.fromJson(allWidgets),
          ),
        );
      } else if (type == 'DEALS_VIEW') {
        widgetsTemp = List<dynamic>.from(
          ((json["subTemplate"]['widget'] ?? []) as List<dynamic>).map(
            (allWidgets) => DealsViewModel.fromJson(allWidgets),
          ),
        );
      } else if (type == 'DEALS_VIEW_V2') {
        widgetsTemp = List<dynamic>.from(
          ((json["subTemplate"]['widget'] ?? []) as List<dynamic>).map(
            (allWidgets) => DealsV2Model.fromJson(allWidgets),
          ),
        );
      }
    }

    return HomePageSection(
      type: type,
      position: json['position'],
      widgets: widgetsTemp,
      name: json['name'],
      title: title,
      backgroundColor: backgroundColor,
      viewAll: viewAll,
      startDate: startDate,
      endDate: endDate,
      startGradient: startGradient,
      endGradient: endGradient,
      title2: title2,
      subTitle1: subTitle1,
      priceRange: priceRange,
      currentPrice: currentPrice,
      originalPrice: originalPrice,
      redirectType: redirectType,
      itemCode: itemCode,
    );
  }
}
