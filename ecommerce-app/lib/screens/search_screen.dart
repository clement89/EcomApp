import 'package:Nesto/models/product.dart';
import 'package:Nesto/providers/auth_provider.dart';
import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/strings.dart' as strings;
import 'package:Nesto/utils/constants.dart';
import 'package:Nesto/utils/util.dart';
import 'package:Nesto/widgets/connectivity_widget.dart';
import 'package:Nesto/widgets/edge_cases/fetching_items.dart';
import 'package:Nesto/widgets/pagination_loader.dart';
import 'package:Nesto/widgets/product_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../values.dart' as values;

List trendingSearches = [
  'Colgate',
  'sugar',
  'dal',
  'salt',
  'apple',
  'fish',
  'sensodyne',
  'eggs'
];

class SearchScreen extends StatefulWidget {
  static const routeName = "/search_screen";

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _textEditingController = TextEditingController();
  bool isFreshSearch = true;
  var focusNode = FocusNode();
  String valueForSearch;

  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "Search Screen");
    var provider = Provider.of<StoreProvider>(context, listen: false);
    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (isAuthTokenValid()) {
      if (authProvider.magentoUser == null) {
        authProvider.fetchMagentoUser();
      }
    }
    provider.isPaginationLoadingForSearchForTheFirstTime = true;
    provider.searchedProductsClear = <Product>[];
    super.initState();
    //Initial search result is empty
    focusNode.requestFocus();
    isFreshSearch = true;
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: Size(414, 926), allowFontScaling: true);

    var safePadding = MediaQuery.of(context).padding.top;

    //Provider data
    var provider = Provider.of<StoreProvider>(context);
    var authProvider = Provider.of<AuthProvider>(context, listen: false);

    ScrollController _scrollController = new ScrollController();

    void setSearchText(String value) async {
      isFreshSearch = false;
      provider.searchedProductsClear = <Product>[];
      provider.noNeedToCallSearchPaginationAgain = false;
      provider.addToRecentSearches(value);
      provider.searchProductsByNameInMagentoForPagination(value,
          email: authProvider?.magentoUser?.emailAddress ?? anonymousEmail);
      valueForSearch = value;
    }

    void logSearch(String keyword) async {
      if (isAuthTokenValid()) {
        if (authProvider.magentoUser == null) {
          await authProvider.fetchMagentoUser();
        }
      }
    }

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          (_scrollController.position.maxScrollExtent -
              ScreenUtil().setHeight(448))) {
        if (!provider.isPaginationLoadingForSearchNotForTheFirstTime) {
          provider.addToRecentSearches(valueForSearch);
          provider.searchProductsByNameInMagentoForPagination(valueForSearch);
        }
      }
    });

    return Scaffold(
      key: _scaffoldKey,
      // appBar:
      //     headerRow(title: strings.SEARCH, context: context, isCart: true),
      body: ConnectivityWidget(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [
                        values.NESTO_GREEN.withOpacity(0.5),
                        values.NESTO_GREEN.withOpacity(0.3),
                      ],
                      begin: const FractionalOffset(0.0, 0.0),
                      end: const FractionalOffset(1.0, 0.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: safePadding + 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        height: 44,
                        child: TextFormField(
                          textAlignVertical: TextAlignVertical.center,
                          controller: _textEditingController,
                          onFieldSubmitted: setSearchText,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            prefixIcon: IconButton(
                              //CJC added
                              icon: Icon(Icons.arrow_back_sharp,
                                  size: 18, color: Colors.black),
                              onPressed: () {
                                Navigator.of(context).maybePop();
                                _textEditingController.text = '';
                              },
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.clear,
                                  size: 18, color: Colors.black),
                              onPressed: () {
                                setState(() {
                                  _textEditingController.text = '';
                                });
                                isFreshSearch = true;
                              },
                            ),
                            contentPadding: EdgeInsets.zero,
                            hintText: 'Search for Products',
                            hintStyle: TextStyle(
                              color: Color(0XFF494B4B).withOpacity(0.6),
                              fontWeight: FontWeight.w400,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(
                                  color: values.NESTO_GREEN, width: 0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(
                                  color: values.NESTO_GREEN, width: 0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  child: _textEditingController.text.length == 0
                      ? SingleChildScrollView(
                          child: EmptySearchScreen(
                          controller: _textEditingController,
                          setSearchText: setSearchText,
                        ))
                      : provider.searchedProducts.isNotEmpty
                          ? Column(
                              children: [
                                SizedBox(
                                  height: ScreenUtil().setHeight(16),
                                ),
                                Expanded(
                                  child: Container(
                                    color: Colors.white,
                                    child: Stack(
                                        alignment: Alignment.bottomCenter,
                                        children: [
                                          WaterfallFlow.builder(
                                            controller: _scrollController,
                                            itemCount: provider
                                                .searchedProducts.length,
                                            gridDelegate:
                                                SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 2,
                                                    crossAxisSpacing: 1.0,
                                                    mainAxisSpacing: 1.0),
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return ProductWidget(
                                                product: provider
                                                    .searchedProducts[index],
                                                scaffoldKey: _scaffoldKey,
                                                type2: true,
                                              );
                                            },
                                          ),
                                          Visibility(
                                              visible: provider
                                                  .isPaginationLoadingForSearchNotForTheFirstTime,
                                              child: PaginationLoader())
                                        ]),
                                  ),
                                ),
                              ],
                            )
                          : !provider.isLoading
                              ? SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: ScreenUtil().setHeight(61.0),
                                      ),
                                      Container(
                                        height: ScreenUtil().setHeight(134.0),
                                        width: ScreenUtil().setWidth(134.0),
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0XFF00983D)
                                                .withOpacity(0.2)),
                                        child: Center(
                                          child: Icon(
                                            Icons.search,
                                            size: 54.0,
                                            color: values.NESTO_GREEN,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                          height: ScreenUtil().setHeight(27.0)),
                                      Text(
                                        isFreshSearch
                                            ? strings.SEARCH_YOUR_ITEMS
                                            : strings.ITEM_NOT_FOUND,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black87,
                                            height: 1.19),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal:
                                                ScreenUtil().setWidth(110.0)),
                                        child: Text(
                                          isFreshSearch
                                              ? strings
                                                  .TYPE_A_KEYWORD_FOR_THE_ITEM_YOU_ARE_LOOKING_FOR
                                              : strings
                                                  .TRY_SEARCHING_THE_ITEM_WITH_A_DIFFERENT_KEYWORD,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 17,
                                              height: 1.19,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black87),
                                        ),
                                      ),
                                      Visibility(
                                        visible:
                                            provider.bestSellers.isNotEmpty,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 18, vertical: 20),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                strings.MOST_POPULAR_ITEM,
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.black),
                                              ),
                                              // SeeMore(
                                              //     onPress: () {
                                              //       provider.selectedCategoryForViewMore =
                                              //           SubCategory(
                                              //             id: 2736,
                                              //             name: "Buy now",
                                              //             merchandiseCategories: [],
                                              //           );
                                              //       Navigator.of(context)
                                              //           .pushNamed(ViewMoreScreen.routeName);
                                              //     }
                                              // ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible:
                                            provider.bestSellers.isNotEmpty,
                                        child: Container(
                                          height: ScreenUtil().setWidth(305.0),
                                          width: double.infinity,
                                          margin: EdgeInsets.only(
                                            left: ScreenUtil().setWidth(10.0),
                                            right: ScreenUtil().setWidth(10.0),
                                            bottom: ScreenUtil().setWidth(10.0),
                                          ),
                                          // color: Colors.pink,
                                          child: ListView.separated(
                                            scrollDirection: Axis.horizontal,
                                            itemCount:
                                                provider.bestSellers.length,
                                            separatorBuilder:
                                                (BuildContext context,
                                                    int index) {
                                              return SizedBox(
                                                width:
                                                    ScreenUtil().setWidth(10.0),
                                              );
                                            },
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              var product =
                                                  provider.bestSellers[index];
                                              return ProductWidget(
                                                product: product,
                                                type2: false,
                                              );
                                            },
                                          ),
                                          // child: ListView.builder(

                                          //   scrollDirection: Axis.horizontal,
                                          //   itemCount: provider.products.length,
                                          //   itemBuilder:
                                          //       (BuildContext context, int index) {
                                          //     var product = provider.products[index];
                                          //     return ProductWidget(product: product);
                                          //   },
                                          // ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(
                                  color: Colors.white,
                                  child: Center(
                                    child: FetchingItemsWidget(),
                                  )),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class EmptySearchScreen extends StatefulWidget {
  const EmptySearchScreen({Key key, this.controller, this.setSearchText})
      : super(key: key);

  final TextEditingController controller;
  final Function setSearchText;

  @override
  _EmptySearchScreenState createState() => _EmptySearchScreenState();
}

class _EmptySearchScreenState extends State<EmptySearchScreen> {
  void onPressTile(String text) {
    widget.setSearchText(text);
    setState(() {
      widget.controller.text = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    //Provider data
    var provider = Provider.of<StoreProvider>(context);

    return Column(
      children: [
        SizedBox(
          height: ScreenUtil().setHeight(20.0),
        ),
        Visibility(
          visible: provider.recentSearches.isNotEmpty,
          child: Container(
            color: Colors.white,
            height: ScreenUtil().setHeight(610),
            padding:
                EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20.0)),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: ScreenUtil().setWidth(16.0)),
                  child: Text(
                    strings.RECENT_SEARCHES,
                    style: titleTextStyle,
                  ),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(10.0),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: provider.recentSearches.length,
                    itemBuilder: (BuildContext context, int index) {
                      var item = provider.recentSearches[index];
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              SystemChannels.textInput
                                  .invokeMethod('TextInput.hide');
                              onPressTile(item);
                            },
                            child: ListTile(
                              leading: Icon(Icons.query_builder),
                              title: Text(item),
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  logNesto("HEELLLO:" + item);
                                  provider.removeFromRecentSearches(item);
                                },
                              ),
                            ),
                          ),
                          Divider(),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        Visibility(
          visible: false,
          child: Container(
            margin: EdgeInsets.only(top: ScreenUtil().setHeight(10.0)),
            width: double.infinity,
            padding:
                EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(36.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.TRENDING_SEARCHES,
                  style: titleTextStyle,
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(16.0),
                ),
                generateTrendingTiles(),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget generateTrendingTiles() {
    var wrapList = List.generate(trendingSearches.length, (index) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 7.0, horizontal: 7.0),
        margin: EdgeInsets.fromLTRB(0.0, 10.0, 18.0, 0.0),
        decoration: BoxDecoration(
            color: Color(0XFF00983D).withOpacity(0.2),
            borderRadius: BorderRadius.circular(4.0)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                trendingSearches[index],
                style: TextStyle(
                  color: Color(0XFF00983D),
                  fontSize: 12,
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          ],
        ),
      );
    });
    return Wrap(
      children: wrapList,
    );
  }
}

//styles

const titleTextStyle = TextStyle(
    fontSize: 14,
    color: Colors.black,
    fontWeight: FontWeight.bold,
    height: 1.42);
