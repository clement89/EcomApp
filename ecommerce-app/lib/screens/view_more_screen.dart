import 'package:Nesto/models/product.dart';
import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/widgets/edge_cases/no_products_found.dart';
import 'package:Nesto/widgets/headers.dart';
import 'package:Nesto/widgets/product_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class ViewMoreScreen extends StatefulWidget {
  //Product listing screen without navigation

  static const String routeName = "/view_more_screen";

  @override
  _ViewMoreScreenState createState() => _ViewMoreScreenState();
}

class _ViewMoreScreenState extends State<ViewMoreScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  int selectedIndex = 0;

  ItemScrollController _scrollController;

  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "View More Screen");
    _scrollController = ItemScrollController();
    print("====================>");
    print("VIEW MORE SCREEN");
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

    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
        return null;
      },
      child: SafeArea(
        child: Scaffold(
            key: _scaffoldKey,
            appBar: headerRow(
                title: provider.selectedCategoryForViewMore.name,
                context: context,
                isCart: true),
            body: Container(
              width: double.infinity,
              height: double.infinity,
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
                            valueColor: new AlwaysStoppedAnimation<Color>(
                                values.NESTO_GREEN)),
                      ),
              ),
            )),
      ),
    );
  }
}
