import 'package:Nesto/models/main_category.dart';
import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/screens/category_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class CategoryBannerWidget extends StatelessWidget {
  final MainCategory category;

  CategoryBannerWidget(this.category);

  @override
  Widget build(BuildContext context) {
    //Screen Util Init
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);

    //Provider
    var provider = Provider.of<StoreProvider>(context, listen: false);

    return GestureDetector(
      onTap: () {
        provider.selectedCategory = category;
        provider.filterProductsByCategory(category);
        Navigator.of(context).pushNamed(CategoryScreen.routeName);
      },
      child: Container(
        margin: EdgeInsets.only(right: ScreenUtil().setWidth(16)),
        width: ScreenUtil().setWidth(240),
        color: Colors.blue,
        child: Center(
          child: Text(
            category.name,
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
