import 'package:Nesto/models/home_builder/home_page_section.dart';
import 'package:Nesto/providers/home_builder_provider.dart';
import 'package:Nesto/screens/location_screen.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/widgets/edge_cases/api_failed_widget.dart';
import 'package:Nesto/widgets/edge_cases/fetching_items.dart';
import 'package:Nesto/widgets/milestone_view.dart';
import 'package:Nesto/widgets/home_builder/header_location.dart';
import 'package:Nesto/widgets/home_builder/multi_widget_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DynamicHomepageNew extends StatefulWidget {
  static String routeName = "/dynamic_home_page_new";

  @override
  _DynamicHomepageNewState createState() => _DynamicHomepageNewState();
}

class _DynamicHomepageNewState extends State<DynamicHomepageNew> {
  // bool isOverlayShowed = false;
  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "Dynamic Home Page");
    super.initState();
    firebaseAnalytics.logHomeScreenLoaded();

    checkZoneSelected();
  }

  void checkZoneSelected() async {
    // SharedPreferences sp = await SharedPreferences.getInstance();
    // isOverlayShowed = sp.getBool('overlay_home_showed') ?? false;

    // var zoneProvider =
    //     Provider.of<ZoneProvider>(context, listen: false); //CJC added

    // bool selected = await zoneProvider.isAnyZoneSelected();

    SharedPreferences encryptedSharedPreferences =
        await SharedPreferences.getInstance();

    String place =
        encryptedSharedPreferences.getString('userlocationname') ?? "";

    if (place.isEmpty) {
      //CJC Zone
      Future.delayed(const Duration(seconds: 1), () async {
        await Navigator.pushNamed(
          context,
          LocationScreen.routeName,
          arguments: null,
        );
      });

      //   if (zoneProvider.zoneString == 'Select your Location' &&
      //       zoneProvider.zoneOverlayShowed &&
      //       !isOverlayShowed) {
      //     print(
      //         'values---- ${zoneProvider.zoneString}, ${zoneProvider.zoneOverlayShowed}, $isOverlayShowed');

      //     setState(() {
      //       isOverlayShowed = true;
      //     });
      //   } else {
      //     setState(() {
      //       isOverlayShowed = false;
      //     });
      //   }
      // });
    } else {
      // context.read<TimeSlotProvider>().getAllTimeSlots();
    }
  }

  @override
  Widget build(BuildContext context) {
    //Screen Util Init
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);
    //Provider data
    var homeProvider = Provider.of<MultiHomePageProvider>(context);

    List<HomePageSection> dynamicHomepageSections =
        homeProvider.dynamicHomepageWidgets;

    dynamicHomepageSections.sort((a, b) => a.position.compareTo(b.position));

    print('Updated...');

    return RefreshIndicator(
      color: values.NESTO_GREEN,
      onRefresh: () async {
        setState(() {
          homeProvider.isHomePageLoading = true;
        });
        homeProvider.getAllHomePageData();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                switchInCurve: Curves.easeIn,
                child: homeProvider.isHomePageLoading
                    ? FetchingItemsWidget()
                    : !homeProvider.isHomePageError &&
                            homeProvider.dynamicHomepageWidgets.isNotEmpty
                        ? MultiWidgetList(
                            widgetList: dynamicHomepageSections,
                            header: HeaderLocationWidget(),
                          )
                        : Stack(
                            children: [
                              HeaderLocationWidget(
                                showInnam: false,
                              ),
                              Center(
                                child: ApiFailedWidget(
                                  onPressRetry: () {
                                    homeProvider.isHomePageLoading = true;
                                    homeProvider.getAllHomePageData();
                                  },
                                ),
                              ),
                            ],
                          ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: homeProvider.isHomePageError
                  ? Container()
                  : HomeMilestoneView(),
            ),
          ],
        ),
      ),
    );
  }
}
