import 'package:Nesto/models/dynamic_home_page/category_header.dart';
import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/screens/category_items_page.dart';
import 'package:Nesto/screens/product_listing_screen.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

import '../optimized_cache_image_widget.dart';

class CategoryHeaderWidget extends StatelessWidget {
  final CategoryHeader categoryHeader;

  CategoryHeaderWidget(this.categoryHeader);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);

    return Container(
      color: Color(0xFFF5F5F8),
      height: ScreenUtil().setWidth(69),
      child: RawMaterialButton(
        padding: EdgeInsets.zero,
        elevation: 8,
        onPressed: () {
          // var provider = Provider.of<StoreProvider>(context, listen: false);
          // provider.selectedCategoryForNavigation =
          //     int.parse(categoryHeader.link);
          // Navigator.of(context).pushNamed(ProductListingScreen.routeName);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return CategoryItemsPage(
                    categoryID: int.parse(categoryHeader.link));

                // return ProductListingScreen(
                //     categoryID: int.parse(categoryHeader.link));
              },
            ),
          );
        },
        child: ImageWidget(
          fadeInDuration: Duration(milliseconds: 1),
          imageUrl: categoryHeader.imageUrl,
          doNotShowPlaceHolder: true,
          errorWidget: (context, error, stackTrace) =>
              Image.memory(kTransparentImage),
          fit: BoxFit.fill,
          width: ScreenUtil().setWidth(223),
        ),
      ),
    );
  }
}
