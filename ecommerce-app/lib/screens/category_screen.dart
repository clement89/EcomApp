import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/widgets/product_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../models/product.dart';
import '../providers/store_provider.dart';
import '../values.dart' as values;

class CategoryScreen extends StatefulWidget {
  static String routeName = "/category_screen";

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
    @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "Category Screen");
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    //TODO:SORT CATEGORY WISE
    var provider = Provider.of<StoreProvider>(context);
    List<Product> _products = provider.filteredProductsByCategory;
    var _selectedBrands = provider.selectedBrands;

    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);

    return SafeArea(
        child: Scaffold(
      body: Container(
        padding: EdgeInsets.only(
            left: ScreenUtil().setWidth(values.SPACING_MARGIN_X_LARGE)),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: ScreenUtil().setHeight(values.SPACING_MARGIN_LARGE),
            ),
            Text(
              provider.selectedCategory.name,
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 26,
                  fontWeight: FontWeight.normal),
            ),
            SizedBox(
              height: ScreenUtil().setHeight(values.SPACING_MARGIN_X_LARGE),
            ),
            Expanded(
              child: WaterfallFlow.builder(
                scrollDirection: Axis.vertical,
                itemCount: _products.length,
                padding: EdgeInsets.zero,
                gridDelegate:
                    SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: ScreenUtil().setHeight(30),
                  crossAxisSpacing: ScreenUtil().setWidth(30),
                ),
                itemBuilder: (ctx, index) {
                  return ProductWidget(
                    product: _products[index],
                    type2: false,
                  );
                },
              ),
            )
          ],
        ),
      ),
    ));
  }
}
