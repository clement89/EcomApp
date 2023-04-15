import 'package:Nesto/models/home_builder/home_page_section.dart';
import 'package:Nesto/providers/home_builder_provider.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/widgets/bottom_bar.dart';
import 'package:Nesto/widgets/custom_appbar.dart';
import 'package:Nesto/widgets/edge_cases/api_failed_widget.dart';
import 'package:Nesto/widgets/edge_cases/fetching_items.dart';
import 'package:Nesto/widgets/edge_cases/no_products_found.dart';
import 'package:Nesto/widgets/milestone_view.dart';
import 'package:Nesto/widgets/home_builder/multi_widget_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:provider/provider.dart';

import 'base_screen.dart';

class CategoryPage extends StatefulWidget {
  static String routeName = "/categoryPage";

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "Category Page");
    super.initState();
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    //Screen Util Init
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);
    //Provider data
    var homeProvider = Provider.of<MultiHomePageProvider>(context);

    List<HomePageSection> categoryWidgets = homeProvider.categoryPageWidgets;

    categoryWidgets.sort((a, b) => a.position.compareTo(b.position));

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
        bottomNavigationBar: BottomBar(
          onTapAction: (int index) {
            Navigator.of(context).pushNamedAndRemoveUntil(
                BaseScreen.routeName, (Route<dynamic> route) => false,
                arguments: {"index": index});
          },
          currentIndex: 1,
        ),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: GradientAppBar(
            title: homeProvider.categoryPage != null
                ? homeProvider.categoryPage.title
                : '',
            showBottomSearchBar: true,
          ),
        ),
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
                        ? categoryWidgets.isEmpty
                            ? NoProductsFoundWidget()
                            : MultiWidgetList(
                                widgetList: categoryWidgets,
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
