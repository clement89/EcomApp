import 'package:Nesto/models/dynamic_home_page/buy_from_cart_section.dart';
import 'package:Nesto/models/product.dart';
import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/screens/merchandise_category_listing_screen.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/utils/util.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/widgets/product_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class BuyFromCartSectionWidget extends StatefulWidget {
  final BuyFromCartSection buyFromCartSection;

  BuyFromCartSectionWidget(this.buyFromCartSection);
  @override
  _BuyFromCartSectionWidgetState createState() =>
      _BuyFromCartSectionWidgetState();
}

class _BuyFromCartSectionWidgetState extends State<BuyFromCartSectionWidget> {
  @override
  Widget build(BuildContext context) {
    //Screen Util Init
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);

    //Provider data
    var provider = Provider.of<StoreProvider>(context);
    //TODO:BRING BACK DEALS OF THE DAY HERE
    List<Product> _products =
        provider.dynamicHomepageProducts[widget.buyFromCartSection.title];
    int _numberOfProductsToDisplay =
        (_products?.length ?? 0) < widget.buyFromCartSection.maxWidgets
            ? (_products?.length ?? 0)
            : widget.buyFromCartSection.maxWidgets;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: ScreenUtil().setHeight(values.SPACING_MARGIN_SMALL),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widget.buyFromCartSection.title != ""
                  ? Text(
                      widget.buyFromCartSection.title,
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 17,
                          fontWeight: FontWeight.w700),
                    )
                  : SizedBox(),
              SeeMore(onPress: () {
                //firebase analytics logging.
                firebaseAnalytics.logSeeMoreClicked(
                  itemListID: widget.buyFromCartSection?.link,
                  itemListName: widget.buyFromCartSection?.title,
                  contentType: "buy_from_cart_section",
                );

                // provider.selectedCategoryForViewMore = SubCategory(
                //   id: int.parse(buyFromCartSection.link),
                //   name: buyFromCartSection.title,
                //   merchandiseCategories: [],
                // );
                // Navigator.of(context).pushNamed(
                //     ViewMoreScreenWithNavigation.routeName,
                //     arguments: {"widget_type": "buy_from_cart_section"});
                int catID;
                try {
                  catID = int.tryParse(widget.buyFromCartSection?.link ?? "0");
                } catch (e) {
                  catID = null;
                }

                if (catID != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return MerchandiseCategoryListingScreen(
                          categoryID:
                              int.parse(widget.buyFromCartSection?.link ?? "0"),
                          dealType: "buy_from_cart_section",
                          title: widget.buyFromCartSection?.title ?? "",
                        );
                      },
                    ),
                  );
                }
              }),
            ],
          ),
        ),
        SizedBox(
          height: ScreenUtil().setHeight(values.SPACING_MARGIN_SMALL),
        ),
        SizedBox(
            height: ScreenUtil()
                .setWidth(_numberOfProductsToDisplay > 0 ? 275 : 50),
            child: ListView.builder(
              cacheExtent:
                  ScreenUtil().setWidth(138) * _numberOfProductsToDisplay,
              // ScreenUtil().setWidth(100),
              scrollDirection: Axis.horizontal,
              itemCount: _numberOfProductsToDisplay,
              itemBuilder: (ctx, index) {
                return Container(
                  margin: EdgeInsets.only(
                      left: index == 0 ? ScreenUtil().setWidth(20) : 0,
                      right: ScreenUtil()
                          .setWidth(values.SPACING_MARGIN_STANDARD)),
                  child: ProductWidget(
                    product: _products[index],
                    type2: false,
                    dealName: widget.buyFromCartSection?.title ?? "",
                    creativeSlot: index.toString(),
                  ),
                );
              },
            )),
        SizedBox(
          height: ScreenUtil().setHeight(values.SPACING_MARGIN_STANDARD),
        ),
      ],
    );
  }
}
