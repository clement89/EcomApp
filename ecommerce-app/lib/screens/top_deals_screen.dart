import 'package:Nesto/models/home_builder/home_page_section.dart';
import 'package:Nesto/providers/home_builder_provider.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/widgets/edge_cases/api_failed_widget.dart';
import 'package:Nesto/widgets/edge_cases/fetching_items.dart';
import 'package:Nesto/widgets/edge_cases/no_products_found.dart';
import 'package:Nesto/widgets/milestone_view.dart';
import 'package:Nesto/widgets/home_builder/multi_widget_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:provider/provider.dart';

class TopDealsScreen extends StatefulWidget {
  static const String routeName = "/wishlist_screen";

  @override
  _TopDealsScreenState createState() => _TopDealsScreenState();
}

class _TopDealsScreenState extends State<TopDealsScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  int selectedIndex = 0;

  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "Top deals Screen");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Screen Util Init
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);
    //Provider data
    var homeProvider = Provider.of<MultiHomePageProvider>(context);

    List<HomePageSection> dealsWidgets = homeProvider.dealsPageWidgets;

    dealsWidgets.sort((a, b) => a.position.compareTo(b.position));

    return RefreshIndicator(
      color: values.NESTO_GREEN,
      onRefresh: () async {
        setState(() {
          homeProvider.isHomePageLoading = true;
        });
        homeProvider.getAllHomePageData();
      },
      child: Scaffold(
        key: _scaffoldKey,
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
                    : !homeProvider.isHomePageError
                        ? dealsWidgets.isEmpty
                            ? NoProductsFoundWidget()
                            : MultiWidgetList(
                                widgetList: dealsWidgets,
                              )
                        : Center(
                            child: ApiFailedWidget(
                              onPressRetry: () {
                                homeProvider.isHomePageLoading = true;
                                homeProvider.getAllHomePageData();
                              },
                            ),
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
