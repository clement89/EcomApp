import 'package:Nesto/models/main_category.dart';
import 'package:Nesto/models/merchandise_category.dart';
import 'package:Nesto/models/subcategory.dart';
import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/screens/base_screen.dart';
import 'package:Nesto/screens/search_screen.dart';
import 'package:Nesto/screens/tab_body.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/strings.dart' as strings;
import 'package:Nesto/utils/style.dart';
import 'package:Nesto/utils/util.dart';
import 'package:Nesto/widgets/bottom_bar.dart';
import 'package:Nesto/widgets/connectivity_widget.dart';
import 'package:Nesto/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListItem {
  String name;
  int catgegoryId;
  ListItem({this.name, this.catgegoryId});
}

class CategoryItemsPage extends StatefulWidget {
  static const String routeName = "/product_listing_screen";
  final int categoryID;
  final String categoryTitle;
  CategoryItemsPage({this.categoryID, this.categoryTitle});

  @override
  _CategoryItemsPageState createState() => _CategoryItemsPageState();
}

class _CategoryItemsPageState extends State<CategoryItemsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  //new implementation
  var _horizontalList = [];
  String _title = "";

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    logNesto('liniting ... ');
    firebaseAnalytics.screenView(screenName: "Product Listing Screen");
    super.initState();
    _getHorizontalCategoryList();
  }

  _getHorizontalCategoryList() {
    var provider = Provider.of<StoreProvider>(context, listen: false);
    var category = provider.getHorizontalCategoryList(widget.categoryID);

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

      List<MerchandiseCategory> merchandiseCats =
          category.merchandiseCategories;

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

    _horizontalList = horizontalList;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    var size = MediaQuery.of(context).size;

    logNesto('data-- -  ${widget.categoryID}');
    logNesto('data-- -  ${widget.categoryTitle}');

    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: BottomBar(
        onTapAction: (int index) {
          Navigator.of(context).pushNamedAndRemoveUntil(
              BaseScreen.routeName, (Route<dynamic> route) => false,
              arguments: {"index": index});
        },
        currentIndex: 1,
      ),
      appBar: GradientAppBar(
        title: _title ?? "",
        rightActions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(SearchScreen.routeName);
            },
            icon: Icon(
              Icons.search,
              color: Colors.black,
            ),
          )
        ],
      ),
      body: ConnectivityWidget(
        child: DefaultTabController(
          length: _horizontalList.length,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 55,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TabBar(
                        indicatorColor: Colors.green,
                        isScrollable: true,
                        tabs:
                            List<Tab>.generate(_horizontalList.length, (index) {
                          ListItem category = _horizontalList[index];

                          return Tab(
                            child: Text(
                              category.name,
                              style: textStyleHeading,
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height * 0.71,
                  child: TabBarView(
                    children:
                        List<Widget>.generate(_horizontalList.length, (index) {
                      ListItem category = _horizontalList[index];

                      return TabBody(
                        index: index,
                        category: category,
                      ); //_buildBody(index);
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
