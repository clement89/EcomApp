import 'package:Nesto/models/product.dart';
import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/screens/base_screen.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/strings.dart' as strings;
import 'package:Nesto/utils/util.dart';
import 'package:Nesto/widgets/custom_appbar.dart';
import 'package:Nesto/widgets/edge_cases/no_favorites.dart';
import 'package:Nesto/widgets/edge_cases/not_loggedin_favorite.dart';
import 'package:Nesto/widgets/product_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class WishListScreen extends StatefulWidget {
  static const String routeName = "/wishlist_screen";

  @override
  _WishListScreenState createState() => _WishListScreenState();
}

class _WishListScreenState extends State<WishListScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  int selectedIndex = 0;

  List<Product> filteredItems = [];
  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "Wishlist Screen");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Screen Util Init
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);

    //Provider data
    var provider = Provider.of<StoreProvider>(context);

    Set<Product> allItems = provider.wishlist;

    List<String> uniqueSubCategories = provider.uniqueSubCategories;
    uniqueSubCategories.insert(0, strings.ALL);
    if (selectedIndex == 0) {
      setState(() {
        filteredItems.clear();
        filteredItems.addAll(allItems);
      });
    }

    return Scaffold(
        appBar: GradientAppBar(
          title: 'Favorites',
        ),
        key: _scaffoldKey,
        // appBar: rootHeaderBar(
        //   showSearchBar: true,
        //   onPress: () =>
        //       Navigator.of(context).pushNamed(SearchScreen.routeName),
        //   title: strings.FAVORITES,
        // ),
        body: !isAuthTokenValid()
            ? NoFavoritesWidgetForLogOut()
            : provider.wishlist.isEmpty
                ? NoFavoritesWidget()
                : Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          // SearchBar(),
                          // SizedBox(
                          //   height: ScreenUtil().setHeight(16),
                          // ),
                          // SizedBox(
                          //   height: ScreenUtil().setWidth(40),
                          //   child: ListView.builder(
                          //     physics: BouncingScrollPhysics(),
                          //     scrollDirection: Axis.horizontal,
                          //     itemCount: uniqueSubCategories.length,
                          //     itemBuilder: (BuildContext context, int index) {
                          //       return GestureDetector(
                          //           onTap: () {
                          //             setState(() {
                          //               filteredItems.clear();
                          //               filteredItems.addAll(allItems
                          //                   .where((element) =>
                          //                       element.subCategory.name ==
                          //                       uniqueSubCategories[index])
                          //                   .toList());
                          //               selectedIndex = index;
                          //             });
                          //           },
                          //           child: Container(
                          //               constraints: BoxConstraints(
                          //                 minWidth: MediaQuery.of(context)
                          //                         .size
                          //                         .width /
                          //                     5,
                          //               ),
                          //               decoration: BoxDecoration(
                          //                 // color: Colors.yellow[50],
                          //                 border: Border(
                          //                   bottom: BorderSide(
                          //                       width:
                          //                           ScreenUtil().setWidth(4.0),
                          //                       color: selectedIndex == index
                          //                           ? values.NESTO_GREEN
                          //                           : Colors.transparent),
                          //                 ),
                          //               ),
                          //               margin: EdgeInsets.only(
                          //                   right: ScreenUtil().setWidth(
                          //                       values.SPACING_MARGIN_LARGE)),
                          //               child: Center(
                          //                 child: Text(
                          //                   uniqueSubCategories[index],
                          //                   style: TextStyle(
                          //                       color: selectedIndex == index
                          //                           ? values.NESTO_GREEN
                          //                           : Colors.black87,
                          //                       fontSize: 16,
                          //                       fontWeight: FontWeight.w600),
                          //                 ),
                          //               )));
                          //     },
                          //   ),
                          // ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: WaterfallFlow.builder(
                                itemCount: filteredItems.length,
                                padding: EdgeInsets.zero,
                                gridDelegate:
                                    SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 1.0,
                                        mainAxisSpacing: 1.0),
                                itemBuilder: (ctx, index) {
                                  // return SearchContainer(
                                  //   product: filteredItems[index],
                                  //   provider: provider,
                                  //   scaffoldKey: _scaffoldKey,
                                  // );
                                  return ProductWidget(
                                    product: filteredItems[index],
                                    scaffoldKey: _scaffoldKey,
                                    type2: true,
                                  );
                                },
                              ),
                            ),
                          )
                        ]),
                  ));
  }
}
