import 'package:Nesto/models/dynamic_home_page/buy_from_cart_section.dart';
import 'package:Nesto/models/dynamic_home_page/deals_section.dart';
import 'package:Nesto/models/dynamic_home_page/main_offer_banner.dart';
import 'package:Nesto/models/dynamic_home_page/main_offer_section.dart';
import 'package:Nesto/models/product.dart';
import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/screens/base_screen.dart';
import 'package:Nesto/screens/search_screen.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/strings.dart' as strings;
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/widgets/edge_cases/no_products_found.dart';
import 'package:Nesto/widgets/headers.dart';
import 'package:Nesto/widgets/product_widget.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class ViewMoreScreenWithNavigation extends StatefulWidget {
  //Product listing screen with navigation

  static const String routeName = "/view_more_screen_with_navigation";

  @override
  _ViewMoreScreenWithNavigationState createState() =>
      _ViewMoreScreenWithNavigationState();
}

class _ViewMoreScreenWithNavigationState
    extends State<ViewMoreScreenWithNavigation> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  int selectedIndex = 0;
  bool hasScrollSetOnce = false;

  ItemScrollController _scrollController;

  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "View More With NavigationScreen");
    _scrollController = ItemScrollController();
    hasScrollSetOnce = false;
    print("====================>");
    print("VIEW MORE WITH NAVIGATION");
    print("<====================");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Screen Util Init
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);

    //Provider data
    var provider = Provider.of<StoreProvider>(context);
    List<Product> _products = provider.viewMoreProducts;

    //Arguments
    Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    String widgetTypeName = args["widget_type"];

    List<dynamic> dynamicList = [];
    if (widgetTypeName == "buy_from_cart_section")
      dynamicList = provider.dynamicHomepageWidgets
          .where((element) => element is BuyFromCartSection)
          .toList();
    else if (widgetTypeName == "deals_section")
      dynamicList = provider.dynamicHomepageWidgets
          .where((element) => element is DealsSection)
          .toList();
    else if (widgetTypeName == "main_offer_banner") {
      List<dynamic> mainOfferSectionList = provider.dynamicHomepageWidgets
          .where((element) => element is MainOfferSection)
          .toList();
      List<MainOfferBanner> mainOfferBanners = [];
      mainOfferSectionList.forEach((element) {
        mainOfferBanners.addAll(element.widgets);
      });
      dynamicList.addAll(mainOfferBanners);
    }

    List<dynamic> uniqueSubCategoriesForNavigation = dynamicList;

    if (!hasScrollSetOnce) {
      int index = 0;
      uniqueSubCategoriesForNavigation.forEach((element) {
        if (element.title == provider.selectedCategoryForViewMore.name) {
          index = uniqueSubCategoriesForNavigation.indexOf(element);
        }
      });
      setState(() {
        selectedIndex = index;
        Future.delayed(Duration.zero, () {
          _scrollController.jumpTo(
              index: selectedIndex, alignment: ScreenUtil().setWidth(0.05));
          hasScrollSetOnce = true;
        });
      });
    }

    return WillPopScope(
        onWillPop: () {
          Navigator.pop(context);
          return null;
        },
        child: SafeArea(
            child: Scaffold(
                key: _scaffoldKey,
                bottomNavigationBar: BottomNavyBar(
                  selectedIndex: 1,
                  onItemSelected: (index) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        BaseScreen.routeName, (Route<dynamic> route) => false,
                        arguments: {"index": index});
                  },
                  items: [
                    BottomNavyBarItem(
                        icon: ImageIcon(AssetImage(
                          "assets/icons/nesto_bottom_nav_icon.png",
                        )),
                        title: Text(
                          strings.NESTO,
                          style: TextStyle(color: Colors.white),
                        ),
                        activeColor: values.NESTO_GREEN,
                        inactiveColor: Colors.grey),
                    BottomNavyBarItem(
                        icon: Icon(Icons.menu),
                        title: Text(
                          strings.CATEGORIES,
                          style: TextStyle(color: Colors.white),
                        ),
                        activeColor: values.NESTO_GREEN,
                        inactiveColor: Colors.grey),
                    BottomNavyBarItem(
                        icon: Icon(
                          Icons.favorite_border,
                        ),
                        title: Text(
                          strings.FAVORITES,
                          style: TextStyle(color: Colors.white),
                        ),
                        activeColor: values.NESTO_GREEN,
                        inactiveColor: Colors.grey),
                    BottomNavyBarItem(
                        showBadge: true,
                        badgeCount: provider.cartCount,
                        icon: Icon(Icons.shopping_cart_outlined),
                        title: Text(
                          strings.CART,
                          style: TextStyle(color: Colors.white),
                        ),
                        activeColor: values.NESTO_GREEN,
                        inactiveColor: Colors.grey),
                    BottomNavyBarItem(
                        icon: Icon(Icons.person_outline),
                        title: Text(
                          strings.ACCOUNT,
                          style: TextStyle(color: Colors.white),
                        ),
                        activeColor: values.NESTO_GREEN,
                        inactiveColor: Colors.red),
                  ],
                ),
                appBar: headerRow(
                    title:
                        uniqueSubCategoriesForNavigation[selectedIndex].title,
                    context: context,
                    rightIcon: Icons.search,
                    onPressRightIcon: () =>
                        Navigator.of(context).pushNamed(SearchScreen.routeName),
                    isCart: false),
                body: Column(
                  children: [
                    Visibility(
                      visible: dynamicList.length != 0,
                      child: SizedBox(
                        height: ScreenUtil().setWidth(40),
                        child: ScrollablePositionedList.builder(
                          itemScrollController: _scrollController,
                          physics: BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemCount: uniqueSubCategoriesForNavigation.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    //logNesto("INDEX:" + index.toString());
                                    dynamic selectedItem =
                                        uniqueSubCategoriesForNavigation[index];
                                    if (selectedItem is DealsSection)
                                      provider.fetchProductsForViewMore(
                                          (selectedItem.ctaLink));
                                    else
                                      provider.fetchProductsForViewMore(
                                          int.parse(selectedItem.link));
                                    selectedIndex = index;
                                  });
                                },
                                child: Container(
                                    constraints: BoxConstraints(
                                      minWidth:
                                          MediaQuery.of(context).size.width / 5,
                                    ),
                                    decoration: BoxDecoration(
                                      // color: Colors.yellow[50],
                                      border: Border(
                                        bottom: BorderSide(
                                            width: ScreenUtil().setWidth(4.0),
                                            color: selectedIndex == index
                                                ? values.NESTO_GREEN
                                                : Colors.transparent),
                                      ),
                                    ),
                                    margin: EdgeInsets.only(
                                        left: index == 0
                                            ? ScreenUtil().setWidth(
                                                values.SPACING_MARGIN_STANDARD)
                                            : 0,
                                        right: ScreenUtil().setWidth(
                                            values.SPACING_MARGIN_LARGE)),
                                    child: Center(
                                      child: Text(
                                        uniqueSubCategoriesForNavigation[index]
                                            .title,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: selectedIndex == index
                                                ? values.NESTO_GREEN
                                                : Colors.black87,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    )));
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: !provider.isLoading
                            ? _products.isNotEmpty
                                ? WaterfallFlow.builder(
                                    itemCount: _products.length,
                                    padding: EdgeInsets.zero,
                                    gridDelegate:
                                        SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: 1.0,
                                            mainAxisSpacing: 1.0),
                                    itemBuilder: (ctx, index) {
                                      return ProductWidget(
                                        product: _products[index],
                                        scaffoldKey: _scaffoldKey,
                                        type2: true,
                                      );
                                    },
                                  )
                                : NoProductsFoundWidget()
                            : Center(
                                child: CircularProgressIndicator(
                                    valueColor:
                                        new AlwaysStoppedAnimation<Color>(
                                            values.NESTO_GREEN)),
                              ),
                      ),
                    )
                  ],
                ))));
  }
}
