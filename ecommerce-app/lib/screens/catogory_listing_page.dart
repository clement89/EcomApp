import 'package:Nesto/models/main_category.dart';
import 'package:Nesto/models/subcategory.dart';
import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/screens/category_items_page.dart';
import 'package:Nesto/screens/product_listing_screen.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/strings.dart' as strings;
import 'package:Nesto/widgets/optimized_cache_image_widget.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class CategoryListing extends StatefulWidget {
  static String routeName = "/category_listing_page";

  @override
  _CategoryListingState createState() => _CategoryListingState();
}

class _CategoryListingState extends State<CategoryListing> {
  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "Category Listing Page");
    super.initState();

    //firebase analytics logging.
    firebaseAnalytics.logCategoryScreenLoaded();
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<StoreProvider>(context, listen: false);

    return Scaffold(
      body: Container(
        color: Theme.of(context).backgroundColor,
        height: double.infinity,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                scrollDirection: Axis.vertical,
                physics: BouncingScrollPhysics(),
                addAutomaticKeepAlives: true,
                shrinkWrap: false,
                itemCount: provider.mainCategories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Column(
                      children: [
                        SizedBox(
                          height: ScreenUtil().setWidth(0),
                        ),
                      ],
                    );
                  } else
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(16),
                      ),
                      child: MainCategoryWidget(
                          provider.mainCategories[index - 1]),
                    );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MainCategoryWidget extends StatefulWidget {
  final MainCategory category;

  MainCategoryWidget(this.category);

  @override
  _MainCategoryWidgetState createState() => _MainCategoryWidgetState();
}

class _MainCategoryWidgetState extends State<MainCategoryWidget>
    with AutomaticKeepAliveClientMixin {
  bool isOpen = false;
  ExpandableController _expandableController = new ExpandableController();

  @override
  void initState() {
    _expandableController.addListener(() {
      setState(() {
        isOpen = !isOpen;
      });

      //firebase analytics logging
      if (_expandableController.expanded) {
        firebaseAnalytics.logCategoryExpanded(
          categoryName: widget?.category?.name,
          categoryID: widget?.category?.id.toString(),
        );
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _expandableController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var provider = Provider.of<StoreProvider>(context, listen: false);
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);

    return ExpandableNotifier(
      controller: _expandableController,
      child: Container(
        margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(16)),
        color: Color(0xFFF5F5F8),
        child: Column(
          children: <Widget>[
            ScrollOnExpand(
              scrollOnExpand: true,
              scrollOnCollapse: false,
              child: ExpandablePanel(
                theme: const ExpandableThemeData(
                  headerAlignment: ExpandablePanelHeaderAlignment.center,
                  hasIcon: false,
                  tapBodyToCollapse: true,
                ),
                header: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(8)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: ScreenUtil().setWidth(186),
                                      padding: EdgeInsets.only(
                                          left: 10.0,
                                          bottom: ScreenUtil().setWidth(4)),
                                      child: Text(
                                        strings.OFFERS_AVAILABLE,
                                        style: TextStyle(
                                            color: Color(0xFF249140),
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    Container(
                                      constraints: BoxConstraints(
                                        maxWidth: ScreenUtil().setWidth(186),
                                      ),
                                      padding: EdgeInsets.only(
                                          left: 10.0,
                                          bottom: ScreenUtil().setHeight(16)),
                                      child: Text(
                                        widget.category.name,
                                        style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: ImageIcon(
                                    isOpen
                                        ? AssetImage(
                                            "assets/images/chevron-up.webp")
                                        : AssetImage(
                                            "assets/images/chevron-down.webp"),
                                    size: ScreenUtil().setWidth(10),
                                  ),
                                  onPressed: () {
                                    _expandableController.toggle();
                                  },
                                )
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 10.0),
                              child: Text(
                                widget.category.description,
                                style: TextStyle(
                                    color: Color(0xff909294), fontSize: 10.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: ScreenUtil().setWidth(147),
                        width: ScreenUtil().setWidth(120),
                        child: ImageWidget(
                          height: ScreenUtil().setWidth(220),
                          width: ScreenUtil().setWidth(220),
                          imageUrl: widget.category.imageUrl != null
                              ? widget.category.imageUrl
                              : "",
                        ),
                      ),
                    ],
                  ),
                ),
                expanded: Center(
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: ScreenUtil().setWidth(70),
                      maxHeight: ScreenUtil().setWidth(290),
                      maxWidth: ScreenUtil().setWidth(320),
                    ),
                    height: widget.category.subCategories.length + 1 > 8
                        ? ScreenUtil().setWidth(248)
                        : widget.category.subCategories.length + 1 > 4
                            ? ScreenUtil().setWidth(168)
                            : ScreenUtil().setWidth(88),
                    width: ScreenUtil().setWidth(320),
                    margin: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(24)),
                    child: GridView.builder(
                      addAutomaticKeepAlives: true,
                      shrinkWrap: false,
                      itemCount: widget.category.subCategories.length > 12
                          ? 12
                          : widget.category.subCategories.length + 1,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: ScreenUtil().setWidth(2),
                          mainAxisSpacing: ScreenUtil().setWidth(2)),
                      itemBuilder: (BuildContext context, int index) {
                        List<SubCategory> _subCategories =
                            widget.category.subCategories;
                        int listLength =
                            widget.category.subCategories.length > 12
                                ? 11
                                : widget.category.subCategories.length;
                        if (index == listLength) {
                          return GestureDetector(
                            onTap: () {
                              //firebase analytics logging.
                              firebaseAnalytics.logCategoryItemClicked(
                                categoryID:
                                    widget.category?.id?.toString() ?? 'none',
                                categoryName: widget.category?.name ?? 'none',
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    // return ProductListingScreen(
                                    //     categoryID: widget.category?.id);

                                    return CategoryItemsPage(
                                        categoryID: widget.category?.id);
                                  },
                                ),
                              );
                            },
                            child: Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Text(
                                  strings.VIEW_ALL,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF249140),
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                )),
                          );
                        }
                        //TODO MAKE THIS A WIDGET
                        return GestureDetector(
                          onTap: () {
                            //firebase analytics logging.
                            firebaseAnalytics.logCategoryItemClicked(
                              categoryID:
                                  _subCategories[index]?.id?.toString() ??
                                      'none',
                              categoryName:
                                  _subCategories[index]?.name ?? 'none',
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return CategoryItemsPage(
                                      categoryID: _subCategories[index]?.id);

                                  // return ProductListingScreen(
                                  //     categoryID: _subCategories[index]?.id);
                                },
                              ),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8)),
                            child: ImageWidget(
                              imageUrl: _subCategories[index].imageUrl != null
                                  ? _subCategories[index].imageUrl
                                  : "",
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
