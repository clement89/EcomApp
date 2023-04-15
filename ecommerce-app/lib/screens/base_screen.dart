import 'dart:async';

import 'package:Nesto/providers/auth_provider.dart';
import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/screens/cart_screen.dart';
import 'package:Nesto/screens/catogory_listing_page.dart';
import 'package:Nesto/screens/home_builder_screen.dart';
import 'package:Nesto/screens/my_account_screen.dart';
import 'package:Nesto/screens/top_deals_screen.dart';
import 'package:Nesto/services/easy_loading_service.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/services/notification_service.dart';
import 'package:Nesto/strings.dart' as strings;
import 'package:Nesto/widgets/bottom_bar.dart';
import 'package:Nesto/widgets/connectivity_widget.dart';
import 'package:Nesto/widgets/edge_cases/api_failed_widget.dart';
import 'package:Nesto/widgets/edge_cases/fetching_items.dart';
import 'package:Nesto/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../utils/util.dart';

class BaseScreen extends StatefulWidget {
  static const String routeName = "/base_screen";

  @override
  _BaseScreenState createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  List<Widget> _children = [
    DynamicHomepageNew(),
    CategoryListing(),
    TopDealsScreen(),
    CartScreen(),
    MyAccountScreen(),
  ];

  // Initialize index on 0
  // ListQueue<int> _navigationQueue = ListQueue();
  int _index = 0;

  @override
  initState() {
    firebaseAnalytics.screenView(screenName: "Base Screen");
    super.initState();
    print("init state base_screen!");

    //firebase analytics logging.
    String env = FlavorConfig.instance.variables["env"];
    var authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (mounted) {
      Future.delayed(Duration.zero, () async {
        //Modal route arguments
        Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
        bool firstOrderPlaced = args['firstOrderPlaced'] ?? false;
        int bottomNavigationIndex = args['index'] ?? 0;

        logNesto("NAV INDEX:" + bottomNavigationIndex.toString());
        setState(() {
          _index = bottomNavigationIndex;
        });

        shouldShowRateMyAppBottomSheet().then((value) {
          if (firstOrderPlaced || (value && !authProvider.rateMyAppShown)) {
            authProvider.rateMyAppShown = true;
            showBottomSheetInHomePage(context);
          }
        });
      });
    }
  }

  Future<bool> _willPopCallback() async {
    logNesto("INSIDE WILL POP SCOPE:$_index");
    if (_index <= 0 && !easyLoadingService.easyLoadingStatus) {
      notificationServices.showCustomDialog(
          title: strings.EXIT_NESTO,
          description: strings.ARE_YOU_WANT_TO_EXIT_NESTO,
          negativeText: strings.NO,
          positiveText: strings.EXIT,
          action: closeApplication);
    } else if (!easyLoadingService.easyLoadingStatus) {
      setState(() {
        _index--;
        logNesto("CURRENT INDEX:" + _index.toString());
      });
    }
    return false; // return true if the route to be popped
  }

  @override
  Widget build(BuildContext context) {
    var authProvider = Provider.of<AuthProvider>(context);
    // var homeProvider = Provider.of<HomeProvider>(context);
    var storeProvider = Provider.of<StoreProvider>(context);

    //Check if store id is there

    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);

    return WillPopScope(
      onWillPop: _willPopCallback,
      child: Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60), child: SearchBar()),
        backgroundColor: Colors.white,
        bottomNavigationBar: Visibility(
          visible: authProvider.isAreaServicable &&
              !storeProvider.isHomePageLoading &&
              !storeProvider.isHomePageError,
          child: BottomBar(
            onTapAction: (index) {
              if (!easyLoadingService.easyLoadingStatus) {
                setState(() {
                  _index = index;
                  //_navigationQueue.addLast(index);
                });
              }
            },
            currentIndex: _index,
          ),
        ),
        body: storeProvider.isHomePageLoading
            ? FetchingItemsWidget(
                isHomePageLoading: true,
                imageUrl: homepageLoaderImage,
              )
            : !storeProvider.isHomePageError
                ? ConnectivityWidget(
                    child: _children[_index],
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
    );
  }
}
