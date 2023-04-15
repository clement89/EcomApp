import 'package:Nesto/models/dynamic_home_page/all_categories_section.dart';
import 'package:Nesto/models/dynamic_home_page/buy_from_cart_section.dart';
import 'package:Nesto/models/dynamic_home_page/deals_section.dart';
import 'package:Nesto/models/dynamic_home_page/main_offer_section.dart';
import 'package:Nesto/models/dynamic_home_page/sponsered_ads_section.dart';
import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/widgets/dynamic_homepage_widgets/all_categories_section_widget.dart';
import 'package:Nesto/widgets/dynamic_homepage_widgets/buy_from_cart_section_widget.dart';
import 'package:Nesto/widgets/dynamic_homepage_widgets/deals_section_widget.dart';
import 'package:Nesto/widgets/dynamic_homepage_widgets/main_offer_section_widget.dart';
import 'package:Nesto/widgets/dynamic_homepage_widgets/sponsored_ads_section_widget.dart';
import 'package:Nesto/widgets/edge_cases/api_failed_widget.dart';
import 'package:Nesto/widgets/edge_cases/fetching_items.dart';
import 'package:Nesto/widgets/header_location.dart';
import 'package:Nesto/widgets/timeslot_row_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:provider/provider.dart';

import 'location_screen.dart';

class DynamicHomepage extends StatefulWidget {
  static String routeName = "/dynamic_home_page";

  @override
  _DynamicHomepageState createState() => _DynamicHomepageState();
}

class _DynamicHomepageState extends State<DynamicHomepage> {
  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "Dynamic Home Page");
    super.initState();
    firebaseAnalytics.logHomeScreenLoaded();
  }

  @override
  Widget build(BuildContext context) {
    //Screen Util Init
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);
    //Provider data
    var storeProvider = Provider.of<StoreProvider>(context);

    List<dynamic> dynamicHomepageWidgets = storeProvider.dynamicHomepageWidgets;

    return RefreshIndicator(
      color: values.NESTO_GREEN,
      onRefresh: () async {
        storeProvider.isHomePageLoading = true;
        storeProvider.fetchAll();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 500),
            switchInCurve: Curves.easeIn,
            child: storeProvider.isHomePageLoading
                ? FetchingItemsWidget()
                : !storeProvider.isHomePageError
                    ? ListView.builder(
                        padding: EdgeInsets.zero,
                        cacheExtent:
                            storeProvider.dynamicHomepageWidgets.length *
                                ScreenUtil().setHeight(896),
                        // ScreenUtil().screenWidth - (ScreenUtil().screenWidth / 4),
                        itemCount:
                            storeProvider.dynamicHomepageWidgets.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Column(
                              children: [
                                // SearchBar(),
                                GestureDetector(
                                  onTap: () {
                                    //firebase analytics logging.
                                    firebaseAnalytics
                                        .homeScreenLocationClicked();
                                    Navigator.pushNamed(
                                      context,
                                      LocationScreen.routeName,
                                      arguments: null,
                                    );
                                  },
                                  child: HeaderLocationWidget(
                                    showNotificationBell: true,
                                  ),
                                ),
                                TimeslotRowWidget(),
                                SizedBox(
                                  height: ScreenUtil().setWidth(8),
                                ),
                              ],
                            );
                          } else {
                            var widgetElement =
                                dynamicHomepageWidgets[index - 1];
                            if (dynamicHomepageWidgets[index - 1]
                                is MainOfferSection) {
                              return MainOfferSectionWidget(widgetElement);
                            } else if (dynamicHomepageWidgets[index - 1]
                                is AllCategoriesSection) {
                              return AllCategoriesSectionWidget(widgetElement);
                            } else if (dynamicHomepageWidgets[index - 1]
                                is DealsSection) {
                              return DealsSectionWidget(widgetElement);
                            } else if (dynamicHomepageWidgets[index - 1]
                                is BuyFromCartSection) {
                              return BuyFromCartSectionWidget(widgetElement);
                            } else if (dynamicHomepageWidgets[index - 1]
                                is SponsoredAdsSection) {
                              return SponsoredAdsSectionWidget(widgetElement);
                            }
                          }
                          return SizedBox();
                        },
                        // Builds 1000 ListTiles
                      )
                    : Center(
                        child: ApiFailedWidget(
                          onPressRetry: () {
                            storeProvider.isHomePageLoading = true;
                            storeProvider.fetchAll();
                          },
                        ),
                      ),
          ),
        ),
      ),
    );
  }
}
