import 'dart:async';
import 'dart:io';

import 'package:Nesto/models/main_category.dart';
import 'package:Nesto/models/merchandise_category.dart';
import 'package:Nesto/models/product.dart';
import 'package:Nesto/models/sort_filter_section_model.dart';
import 'package:Nesto/models/subcategory.dart';
import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/screens/base_screen.dart';
import 'package:Nesto/screens/search_screen.dart';
import 'package:Nesto/screens/sort_filter_screen.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/strings.dart' as strings;
import 'package:Nesto/utils/util.dart';
import 'package:Nesto/values.dart' as values;
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

class ListItem {
  String name;
  int catgegoryId;
  ListItem({this.name, this.catgegoryId});
}

class ProductListingScreen extends StatefulWidget {
  static const String routeName = "/product_listing_screen";
  final int categoryID;
  final String categoryTitle;
  ProductListingScreen({this.categoryID, this.categoryTitle});

  @override
  _ProductListingScreenState createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  ItemScrollController _scrollController = ItemScrollController();

  //new implementation
  var _horizontalList = [];
  List<Product> _products = [];
  int _selectedCategoryIndex = 0;
  String _title = "";
  Future _future;
  bool _isLoading = false;
  int _pageNumber = 1;
  bool _hasMoreProducts = true;
  Option sortOption;
  Option filterOption;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "Product Listing Screen");
    super.initState();
    _getHorizontalCategoryList();
    _scrollToSelectedIndex();
    _future = _getProductsOfCategory(
      categoryId: widget.categoryID,
      isInitialPage: true,
    );
  }

  _showLoading() => setState(() => _isLoading = true);
  _stopLoading() => setState(() => _isLoading = false);

  _getHorizontalCategoryList() {
    var provider = Provider.of<StoreProvider>(context, listen: false);
    var category = provider.getHorizontalCategoryList(widget.categoryID);

    print("\n\n=======================>");
    print("CAT: $category");
    print("<=======================\n\n");

    var horizontalList = [];
    if (category is MainCategory) {
      var subCats = category.subCategories;
      print("SUBCAT LENGTH: ${subCats.length}");
      _title = category.name ?? "";
      horizontalList = subCats
          .map((subCat) => ListItem(
                name: subCat.name,
                catgegoryId: subCat.id,
              ))
          .toList();
      horizontalList.insert(
          0, ListItem(name: strings.ALL, catgegoryId: widget.categoryID));
    } else if (category is SubCategory) {
      _title = category.name ?? "";

      print("SUB CAT INCOMING!");
      List<MerchandiseCategory> merchandiseCats =
          category.merchandiseCategories;
      print("MERCH LENGTH: ${merchandiseCats.length}");

      horizontalList = merchandiseCats
          .map((merchandiseCat) => ListItem(
                name: merchandiseCat.name,
                catgegoryId: merchandiseCat.id,
              ))
          .toList();
      horizontalList.insert(
          0, ListItem(name: strings.ALL, catgegoryId: widget.categoryID));
    } else if (category is List) {
      _title = category[1].name ?? "";
      horizontalList = category[1]
          .merchandiseCategories
          .map((merchandiseCat) => ListItem(
                name: merchandiseCat.name,
                catgegoryId: merchandiseCat.id,
              ))
          .toList();
      horizontalList.insert(
          0, ListItem(name: strings.ALL, catgegoryId: category[1].id));
    } else {
      print("DEFAULT INCOMING!");
      _title = widget.categoryTitle ?? "";
      horizontalList = [];
    }

    print("\n\n=======================>");
    print("LIST: $horizontalList");
    print("<=======================\n\n");
    _horizontalList = horizontalList;
  }

  _scrollToSelectedIndex() {
    int index = _horizontalList.indexWhere((element) {
      if (element is ListItem) {
        return element.catgegoryId == widget.categoryID;
      } else
        return false;
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

  _onTapNewCat(int index) {
    ListItem category = _horizontalList[index];

    setState(() {
      _future = _getProductsOfCategory(
          categoryId: category.catgegoryId,
          isInitialPage: true,
          catIndex: index);
    });
  }

  _getProductsOfCategory(
      {int categoryId, bool isInitialPage, int catIndex}) async {
    print("\n\n=======================>");
    print("CAT ID: $categoryId");
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

      print('next page - $nextPage');

      print("\n\n=======================>");
      print("PROD LEN: ${productList.length}");
      print("<=======================\n\n");

      if (productList.length <= 0) {
        setState(() {
          if (isInitialPage) {
            _products.clear();
          }
          _hasMoreProducts = false;
        });
      } else {
        setState(() {
          if (isInitialPage) {
            _products.clear();
            _hasMoreProducts = true;
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
        showError(context, strings.SOMETHING_WENT_WRONG_WITH_EXCLAMATION);
        throw Future.error(strings.SOMETHING_WENT_WRONG_WITH_EXCLAMATION);
      }
    }
  }

  getProductsByPagination() async {
    try {
      _showLoading();
      await _getProductsOfCategory(
          categoryId: _horizontalList[_selectedCategoryIndex].catgegoryId,
          isInitialPage: false);
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
        _future = _getProductsOfCategory(
            categoryId: _horizontalList[_selectedCategoryIndex].catgegoryId,
            isInitialPage: true,
            catIndex: _selectedCategoryIndex);
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
  Widget build(BuildContext context) {
    //Screen Util Init
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);

    // Provider data
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
              title: _title ?? "",
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
                        physics: BouncingScrollPhysics(),
                        itemScrollController: _scrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: _horizontalList.length,
                        itemBuilder: (BuildContext context, int index) {
                          ListItem category = _horizontalList[index];

                          return GestureDetector(
                              onTap: () {
                                _onTapNewCat(index);
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
                                          color: _selectedCategoryIndex == index
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
                                      category.name ?? "",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: _selectedCategoryIndex == index
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
                                  valueColor: new AlwaysStoppedAnimation<Color>(
                                      values.NESTO_GREEN),
                                  strokeWidth: ScreenUtil().setWidth(3),
                                ));
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
                                                _hasMoreProducts &&
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
                    )
                  ]),
            ),
          )),
    );
  }
}
