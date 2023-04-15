import 'dart:io';

import 'package:Nesto/models/dynamic_home_page/buy_from_cart_section.dart';
import 'package:Nesto/models/dynamic_home_page/deals_section.dart';
import 'package:Nesto/models/dynamic_home_page/main_offer_banner.dart';
import 'package:Nesto/models/dynamic_home_page/main_offer_section.dart';
import 'package:Nesto/models/product.dart';
import 'package:Nesto/models/sort_filter_section_model.dart';
import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/screens/base_screen.dart';
import 'package:Nesto/screens/search_screen.dart';
import 'package:Nesto/screens/sort_filter_screen.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/utils/util.dart';
import 'package:Nesto/widgets/connectivity_widget.dart';
import 'package:Nesto/widgets/edge_cases/no_products_found.dart';
import 'package:Nesto/widgets/headers.dart';
import 'package:Nesto/widgets/pagination_loader.dart';
import 'package:Nesto/widgets/product_widget.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:waterfall_flow/waterfall_flow.dart';
import 'package:Nesto/strings.dart' as strings;
import '../values.dart' as values;

class MerchandiseCategoryListingScreen extends StatefulWidget {
  static const String routeName = "/merchandise_category_listing_screen";

  final String dealType;
  final int categoryID;
  final String title;
  MerchandiseCategoryListingScreen(
      {@required this.dealType,
      @required this.categoryID,
      @required this.title});

  @override
  _MerchandiseCategoryListingScreenState createState() =>
      _MerchandiseCategoryListingScreenState();
}

class _MerchandiseCategoryListingScreenState
    extends State<MerchandiseCategoryListingScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Product> _products = [];
  var _horizontalDealList = [];
  Future _future;
  // int _selectedCategoryId = -1;
  int _selectedCategoryIndex = 0;
  bool _isLoading = false;
  int _pageNumber = 1;
  bool hasMoreProducts = true;
  Option sortOption;
  Option filterOption;

  ItemScrollController _scrollController;
  _showLoading() => setState(() => _isLoading = true);
  _stopLoading() => setState(() => _isLoading = false);

  _scrollToSelectedIndex() {
    int index = _horizontalDealList.indexWhere((element) {
      switch (element.runtimeType) {
        case DealsSection:
          return (element.ctaLink == widget.categoryID ||
              element.title == widget.title);
          break;
        default:
          return (int.parse(element.link) == widget.categoryID ||
              element.title == widget.title);
          break;
      }
    });

    print("===============================>");
    print("SCROLL INDEX: $index");
    print("<===============================");

    if (index != -1) {
      Future.delayed(Duration.zero, () {
        setState(() {
          _selectedCategoryIndex = index;
          _scrollController.jumpTo(
              index: index, alignment: ScreenUtil().setWidth(0.05));
        });
      });
    }
  }

  _getHorizontalCategoryList() {
    var provider = Provider.of<StoreProvider>(context, listen: false);
    var dhpList = provider.dynamicHomepageWidgets;

    switch (widget.dealType) {
      case "buy_from_cart_section":
        _horizontalDealList =
            dhpList.where((element) => element is BuyFromCartSection).toList();
        break;
      case "deals_section":
        _horizontalDealList =
            dhpList.where((element) => element is DealsSection).toList();
        break;
      case "main_offer_banner":
        var dynamicList = [];
        List<dynamic> mainOfferSectionList =
            dhpList.where((element) => element is MainOfferSection).toList();
        List<MainOfferBanner> mainOfferBanners = [];
        mainOfferSectionList.forEach((element) {
          mainOfferBanners.addAll(element.widgets);
        });
        dynamicList.addAll(mainOfferBanners);
        _horizontalDealList = dynamicList;
        break;
      default:
        _horizontalDealList = [];
        break;
    }
  }

  _onTapNewDeal(index) {
    var selectedItem = _horizontalDealList[index];
    switch (selectedItem.runtimeType) {
      case DealsSection:
        setState(() {
          _future = _getProductsOfCategory(
              categoryId: selectedItem?.ctaLink ?? 0,
              isInitialPage: true,
              catIndex: index);
        });
        break;
      default:
        setState(() {
          _future = _getProductsOfCategory(
              categoryId: int.parse(selectedItem?.link ?? "0"),
              isInitialPage: true,
              catIndex: index);
        });
        break;
    }
  }

  _getProductsOfCategory(
      {int categoryId, bool isInitialPage, int catIndex}) async {
    print("\n\n=======================>");
    print("PROD LEN: $categoryId");
    print("<=======================\n\n");
    try {
      if (isInitialPage) {
        setState(() {
          _selectedCategoryIndex = catIndex;
        });
      }

      int nextPage = isInitialPage ? 1 : _pageNumber + 1;

      var provider = Provider.of<StoreProvider>(context, listen: false);
      bool applyFilter = filterOption != null || sortOption != null;
      List<Product> productList =
          await provider.fetchProductsOfCategoryPagination(nextPage, categoryId,
              applyFilter: applyFilter,
              selectedFilter: filterOption,
              selectedSort: sortOption);

      print("\n\n=======================>");
      print("PROD LEN: ${productList.length}");
      print("<=======================\n\n");
      if (productList.length <= 0) {
        setState(() {
          if (isInitialPage) {
            _products.clear();
          }
          hasMoreProducts = false;
        });
      } else {
        setState(() {
          if (isInitialPage) {
            _products.clear();
            hasMoreProducts = true;
            _pageNumber = 1;
          }
          _products.addAll(productList);
        });
      }
    } on SocketException catch (_) {
      showError(context, strings.PLEASE_CHECK_YOUR_NETWORK_CONNECTION);
      throw Future.error("Something went wrong !");
    } catch (e) {
      if (e.message.toString().isNotEmpty) {
        showError(context, e.message.toString());
        throw Future.error(e?.message);
      } else {
        showError(context, strings.SOMETHING_WENT_WRONG);
        throw Future.error("Something went wrong !");
      }
    }
  }

  getProductsByPagination() async {
    try {
      _showLoading();
      if (_horizontalDealList[_selectedCategoryIndex] is DealsSection) {
        await _getProductsOfCategory(
            categoryId: _horizontalDealList[_selectedCategoryIndex].ctaLink,
            isInitialPage: false);
      } else {
        await _getProductsOfCategory(
            categoryId:
                int.parse(_horizontalDealList[_selectedCategoryIndex].link),
            isInitialPage: false);
      }

      _stopLoading();
      setState(() {
        _pageNumber += 1;
      });
    } catch (e) {
      _stopLoading();
      showError(context, e?.mesage);
    }
  }

  void setSortAndFilter() async {
    try {
      var value = await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => SortFilterScreen(
                selectedFilterOption: filterOption,
                selectedSortOption: sortOption,
              )));
      if (value is SortFilterArguments) {
        sortOption = value.selectedSortOption;
        filterOption = value.selectedFilterOption;
        _products.clear();
        if (_horizontalDealList[_selectedCategoryIndex] is DealsSection) {
          _future = _getProductsOfCategory(
              categoryId: _horizontalDealList[_selectedCategoryIndex].ctaLink,
              isInitialPage: true,
              catIndex: _selectedCategoryIndex);
        } else {
          _future = _getProductsOfCategory(
              categoryId:
                  int.parse(_horizontalDealList[_selectedCategoryIndex].link),
              isInitialPage: true,
              catIndex: _selectedCategoryIndex);
        }
      }
    } catch (e) {}
  }

  bool hasReachedEndOfPage(ScrollNotification scrollInfo) {
    double scrollOffset = 200.0;
    double maxScrollExtent = scrollInfo.metrics.maxScrollExtent;
    double maxScrollMinusOffset = maxScrollExtent - scrollOffset;
    double currentPixels = scrollInfo.metrics.pixels;

    if (maxScrollMinusOffset.isNegative ||
        maxScrollMinusOffset > maxScrollExtent) {
      return true;
    }

    if (currentPixels >= maxScrollMinusOffset) {
      return true;
    }

    return false;
  }

  @override
  void initState() {
    firebaseAnalytics.screenView(
        screenName: "Merchandise Category Listing Screen");
    super.initState();
    _scrollController = ItemScrollController();
    _getHorizontalCategoryList();
    _scrollToSelectedIndex();
    _future = _getProductsOfCategory(
        categoryId: widget.categoryID, isInitialPage: true);
  }

  @override
  Widget build(BuildContext context) {
    //Screen Util Init
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);

    //Provider data
    var provider = Provider.of<StoreProvider>(context);

    return SafeArea(
      child: Scaffold(
          key: _scaffoldKey,
          floatingActionButton: FloatingActionButton(
            onPressed: setSortAndFilter,
            child: const Icon(
              Icons.filter_list_outlined,
              color: values.NESTO_GREEN,
            ),
            backgroundColor: Colors.white,
          ),
          backgroundColor: Colors.white,
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
                    strings.APP_NAME,
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
              title: widget?.title ?? "",
              context: context,
              rightIcon: Icons.search,
              onPressRightIcon: () =>
                  Navigator.of(context).pushNamed(SearchScreen.routeName),
              isCart: false),
          body: ConnectivityWidget(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    SizedBox(
                      height: ScreenUtil().setWidth(40),
                      child: ScrollablePositionedList.builder(
                        padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtil()
                                .setWidth(values.SPACING_MARGIN_STANDARD)),
                        itemScrollController: _scrollController,
                        physics: BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: _horizontalDealList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                              onTap: () {
                                _onTapNewDeal(index);
                              },
                              child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: ScreenUtil().setWidth(8)),
                                  margin: EdgeInsets.only(
                                      right: ScreenUtil().setWidth(
                                          values.SPACING_MARGIN_LARGE)),
                                  constraints: BoxConstraints(
                                    minWidth:
                                        MediaQuery.of(context).size.width / 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border(
                                      bottom: BorderSide(
                                          width: ScreenUtil().setWidth(4.0),
                                          color: index == _selectedCategoryIndex
                                              ? values.NESTO_GREEN
                                              : Colors.transparent),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _horizontalDealList[index].title ?? "",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: index == _selectedCategoryIndex
                                              ? values.NESTO_GREEN
                                              : Colors.black87,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  )));
                        },
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: FutureBuilder(
                          future: _future,
                          builder: (_, snapshot) {
                            Widget _child;
                            switch (snapshot.connectionState) {
                              case ConnectionState.waiting:
                                _child = Center(
                                  child: CircularProgressIndicator(
                                    valueColor:
                                        new AlwaysStoppedAnimation<Color>(
                                            values.NESTO_GREEN),
                                    strokeWidth: ScreenUtil().setWidth(3),
                                  ),
                                );
                                break;
                              case ConnectionState.done:
                                if (snapshot.hasError) {
                                  _child = NoProductsFoundWidget();
                                } else {
                                  if (_products.isEmpty) {
                                    _child = NoProductsFoundWidget();
                                  } else {
                                    _child = Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: [
                                        NotificationListener<
                                            ScrollNotification>(
                                          onNotification: (scrollInfo) {
                                            if (!_isLoading &&
                                                hasMoreProducts &&
                                                hasReachedEndOfPage(
                                                    scrollInfo)) {
                                              getProductsByPagination();
                                            }
                                            return false;
                                          },
                                          child: WaterfallFlow.builder(
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
                                          ),
                                        ),
                                        Visibility(
                                            visible: _isLoading,
                                            child: PaginationLoader()),
                                      ],
                                    );
                                  }
                                }
                                break;
                              default:
                                _child = NoProductsFoundWidget();
                                break;
                            }

                            return AnimatedSwitcher(
                              switchInCurve: Curves.fastOutSlowIn,
                              duration: Duration(milliseconds: 500),
                              child: _child,
                            );
                          },
                        ),
                      ),
                    ),
                  ]),
            ),
          )),
    );
  }
}
