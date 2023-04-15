import 'package:Nesto/extensions/number_extension.dart';
import 'package:Nesto/models/order_details.dart';
import 'package:Nesto/providers/orders_provider.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/widgets/coupon_applied_banner_widget.dart';
import 'package:Nesto/widgets/edge_cases/no_products_found.dart';
import 'package:Nesto/widgets/headers.dart';
import 'package:Nesto/widgets/optimized_cache_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:provider/provider.dart';
import 'package:Nesto/strings.dart' as strings;

class ProductListDisplay extends StatefulWidget {
  static const routeName = "/product_list_orders";

  @override
  _ProductListDisplayState createState() => _ProductListDisplayState();
}

class _ProductListDisplayState extends State<ProductListDisplay> {
  bool get isCouponApplied {
    var provider = Provider.of<OrderProvider>(context, listen: false);
    if (double.parse(provider?.currentOrder?.discount_amount ?? '0').abs() >
        0) {
      return true;
    } else
      return false;
  }

  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "Product List Orders Screen");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<OrderProvider>(context);

    return SafeArea(
      child: Scaffold(
        appBar: headerBar(title: strings.ITEM_LIST, context: context),
        backgroundColor: Colors.white,
        body: Container(
          height: double.infinity,
          width: double.infinity,
          child: Column(
            children: [
              Visibility(
                  visible: isCouponApplied,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: ScreenUtil().setWidth(18)),
                    child: CouponAppliedBanner(),
                  )),
              Flexible(
                  flex: 1,
                  child: provider.currentOrder.items.isNotEmpty
                      ? ListView.separated(
                          padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setWidth(18),
                            vertical: ScreenUtil().setWidth(18),
                          ),
                          itemBuilder: (_, index) {
                            Item product = provider.currentOrder.items[index];

                            return Product(product: product);
                          },
                          separatorBuilder: (_, index) => SizedBox(
                                height: ScreenUtil().setWidth(15),
                              ),
                          itemCount: provider.currentOrder.items.length)
                      : Center(
                          child: NoProductsFoundWidget(),
                        )),
              BottomContainer()
            ],
          ),
        ),
      ),
    );
  }
}

class ProductImage extends StatelessWidget {
  const ProductImage({
    Key key,
    @required this.imageURL,
  }) : super(key: key);

  final String imageURL;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ScreenUtil().setWidth(70),
      width: ScreenUtil().setWidth(70),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.0),
        child: FittedBox(
          fit: BoxFit.fitWidth,
          child: ImageWidget(
              fadeInDuration: Duration(milliseconds: 1),
              maxHeightDiskCache: 900,
              maxWidthDiskCache: 900,
              imageUrl: imageURL),
        ),
      ),
    );
  }
}

class BottomContainer extends StatelessWidget {
  const BottomContainer({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setWidth(100),
      width: double.infinity,
      decoration: bottomContainerDecoration,
      child: Center(
        child: SizedBox(
            width: ScreenUtil().setWidth(150),
            height: ScreenUtil().setWidth(50),
            child: MaterialButton(
              padding: EdgeInsets.zero,
              color: values.NESTO_GREEN,
              child: Center(
                child: Text(
                  strings.BACK,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
              onPressed: () => Navigator.of(context).maybePop(),
            )),
      ),
    );
  }
}

class Product extends StatelessWidget {
  const Product({
    Key key,
    @required this.product,
  }) : super(key: key);

  final Item product;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setWidth(100),
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(15)),
      decoration: BoxDecoration(
        color: Color(0XFFF5F5F8),
        borderRadius: BorderRadius.circular(8.84),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: ScreenUtil().setWidth(40),
            width: ScreenUtil().setWidth(40),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(8.84)),
            child: Center(
                child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                double.parse(product.qtyOrdered).toInt().toString(),
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black),
              ),
            )),
          ),
          SizedBox(
            width: ScreenUtil().setWidth(15),
          ),
          ProductImage(
            imageURL: product.itemImage,
          ),
          SizedBox(
            width: ScreenUtil().setWidth(15),
          ),
          Flexible(
            flex: 1,
            child: SizedBox(
              width: double.infinity,
              child: Text(
                product?.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 15.47, height: 1.19, color: Color(0XFF111A2C)),
              ),
            ),
          ),
          SizedBox(
            width: ScreenUtil().setWidth(10),
          ),
          Container(
            color: Colors.transparent,
            width: ScreenUtil().setWidth(70),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                strings.AED +
                    ' ' +
                    double.parse(product?.rowTotalInclTax).twoDecimal(),
                style: TextStyle(
                    color: Color(0XFF00983D),
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//styles
BoxDecoration bottomContainerDecoration = BoxDecoration(
    color: Colors.white,
    boxShadow: [
      BoxShadow(
          color: Color(0XFF000000).withOpacity(0.05),
          blurRadius: 10.0,
          offset: Offset(0.0, 0.75))
    ],
    borderRadius: BorderRadius.only(
        topLeft: Radius.circular(18.0), topRight: Radius.circular(18.0)));
