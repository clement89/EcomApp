import 'dart:async';
import 'dart:io';

import 'package:Nesto/models/product.dart';
import 'package:Nesto/models/sort_filter_section_model.dart';
import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/screens/sort_filter_screen.dart';
import 'package:Nesto/strings.dart' as strings;
import 'package:Nesto/utils/util.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/widgets/edge_cases/no_products_found.dart';
import 'package:Nesto/widgets/pagination_loader.dart';
import 'package:Nesto/widgets/product_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import 'category_items_page.dart';

class TabBody extends StatefulWidget {
  final ListItem category;
  final int index;

  TabBody({
    this.category,
    this.index,
  });

  @override
  _TabBodyState createState() => _TabBodyState();
}

class _TabBodyState extends State<TabBody> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Product> _products = [];
  Future _future;
  bool _isLoading = false;
  bool _hasMoreProducts = true;
  int _pageNumber = 1; //BUG_FIX

  Option sortOption;
  Option filterOption;

  @override
  void initState() {
    _future = _getProductsOfCategory(
      categoryId: widget.category.catgegoryId,
      isInitialPage: true,
      catIndex: widget.index,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: setSortAndFilter,
        child: const Icon(
          Icons.filter_list_outlined,
          color: values.NESTO_GREEN,
        ),
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget _buildBody() {
    return Container(
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
                      new AlwaysStoppedAnimation<Color>(values.NESTO_GREEN),
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
                        NotificationListener<ScrollNotification>(
                          onNotification: (scrollInfo) {
                            if (!_isLoading &&
                                _hasMoreProducts &&
                                hasReachedEndOfPage(scrollInfo)) {
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
                            visible: _isLoading, child: PaginationLoader()),
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
    );
  }

  _getProductsOfCategory(
      {int categoryId, bool isInitialPage, int catIndex}) async {
    try {
      var provider = Provider.of<StoreProvider>(context, listen: false);
      bool applyFilter = filterOption != null || sortOption != null;

      print(
          'Loading more -- $applyFilter, $filterOption, $sortOption , $catIndex, $categoryId');

      int nextPage = isInitialPage ? 1 : _pageNumber + 1;

      print('next page - $nextPage');

      List<Product> productList =
          await provider.fetchProductsOfCategoryPagination(
        nextPage,
        categoryId,
        applyFilter: applyFilter,
        selectedFilter: filterOption,
        selectedSort: sortOption,
      );

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

      // if (productList.length <= 0) {
      //   setState(() {
      //     if (isInitialPage) {
      //       _products.clear();
      //     }
      //     _hasMoreProducts = false;
      //   });
      // } else {
      //   setState(() {
      //     if (isInitialPage) {
      //       _products.clear();
      //       _hasMoreProducts = true;
      //     }
      //     _products.addAll(productList);
      //   });
      // }
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
          categoryId: widget.category.catgegoryId,
          isInitialPage: false,
          catIndex: widget.index);
      _stopLoading();

      setState(() {
        _pageNumber += 1;
      });
    } catch (e) {
      _stopLoading();
      showError(context, e?.mesage);
    }
  }

  _showLoading() => setState(() => _isLoading = true);
  _stopLoading() => setState(() => _isLoading = false);

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

  void setSortAndFilter() async {
    try {
      var value = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SortFilterScreen(
            selectedFilterOption: filterOption,
            selectedSortOption: sortOption,
          ),
        ),
      );
      if (value is SortFilterArguments) {
        sortOption = value.selectedSortOption;
        filterOption = value.selectedFilterOption;
        _products.clear();
        _future = _getProductsOfCategory(
            categoryId: widget.category.catgegoryId,
            isInitialPage: true,
            catIndex: widget.index);
      }
    } catch (e) {}
  }
}
