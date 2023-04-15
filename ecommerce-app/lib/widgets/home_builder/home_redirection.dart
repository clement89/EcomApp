import 'package:Nesto/providers/home_builder_provider.dart';
import 'package:Nesto/screens/category_items_page.dart';
import 'package:Nesto/screens/category_page.dart';
import 'package:Nesto/screens/product_details.dart';
import 'package:Nesto/utils/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void homeRedirection({
  String redirectType,
  String itemCode,
  BuildContext context,
}) {
  print('redirectType - $redirectType');

  if (redirectType == 'TEMPLATE_PAGE') {
    Provider.of<MultiHomePageProvider>(context, listen: false).selectedPageId =
        itemCode;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return CategoryPage();
        },
      ),
    );
  } else if (redirectType == 'CATEGORY') {
    //firebase analytics logging.
    // firebaseAnalytics.logCategoryItemClicked(
    //   categoryID: itemCode,
    //   categoryName: '', //Add categoryName here
    // );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return CategoryItemsPage(
            categoryID: int.parse(itemCode),
          );
        },
      ),
    );
  } else if (redirectType == 'PRODUCT') {
    //firebase analytics logging.
    // firebaseAnalytics.logCategoryItemClicked(
    //   categoryID: itemCode,
    //   categoryName: '', //Add categoryName here
    // );

    print('productId - ${sapWebsiteId.toString() + '-' + itemCode}');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return ProductDetail(
            sku: sapWebsiteId.toString() + '-' + itemCode,
          );
        },
      ),
    );
  }
}
