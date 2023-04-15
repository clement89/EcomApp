import 'package:Nesto/models/product.dart';
import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/screens/login_screen.dart';
import 'package:Nesto/screens/product_details.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/strings.dart' as strings;
import 'package:Nesto/utils/util.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/widgets/product_widget_spinner.dart';
import 'package:Nesto/widgets/show_wishlist_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'optimized_cache_image_widget.dart';

class PopularProduct extends StatefulWidget {
  //Constructor
  final Product product;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String dealName;

  PopularProduct({
    @required this.product,
    this.scaffoldKey,
    this.dealName,
  });

  @override
  _PopularProductState createState() => _PopularProductState();
}

class _PopularProductState extends State<PopularProduct> {
  final String _env = FlavorConfig.instance.variables["env"];
  bool addingProductToCart = false;
  bool showProductSpinner = false;

  @override
  void initState() {
    // firebaseAnalytics.logViewPromotion(
    //     promotionID: widget?.product?.sku ?? "",
    //     promotionName: widget?.product?.imageURL ?? "",
    //     creativeName: widget?.dealName ?? "",
    //     creativeSlot: "",
    //     locationID: (widget?.product?.taxExcludedPrice ?? "").toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Screen Util Init
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);

    //Provider
    final provider = Provider.of<StoreProvider>(context);

    //Auth provider

    if (!provider.isProductInCart(widget.product) && addingProductToCart) {
      setState(() {
        addingProductToCart = false;
      });
    }

    void onProductTap() {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return ProductDetail(
              sku: widget.product.sku ?? "",
            );
          },
        ),
      );

      if ((widget?.dealName ?? "").isNotEmpty) {
        firebaseAnalytics.logSelectPromotion(
            promotionID: widget?.product?.sku ?? "",
            promotionName: widget?.product?.imageURL ?? "",
            creativeName: widget?.dealName ?? "",
            creativeSlot: "",
            locationID: (widget?.product?.taxExcludedPrice ?? "").toString(),
            sku: widget?.product?.sku ?? "",
            productName: widget?.product?.name ?? "",
            tileType: "buy_from_cart_section");
      } else {
        firebaseAnalytics.logViewProduct(
            sku: widget?.product?.sku,
            itemName: widget?.product?.name,
            currency: "AED",
            price: widget?.product?.priceWithTax,
            env: _env);
      }
    }

    void onTapLike() {
      if (provider.isProductInWishlist(widget.product)) {
        showWishListModal(context, widget.product);
      } else {
        setState(() {
          if (isAuthTokenValid())
            //Add product ot the liked
            provider.addToWishList(widget.product);
          else
            Navigator.of(context).pushNamed(LoginScreen.routeName);
        });
      }
    }

    var image = widget.product.imageURL ?? '';
    var productName = widget.product.name;
    var weight = provider.getWeightText(widget.product.weight.toDouble());
    var discount = (widget.product.discount).round().toString() + "%";
    var taxIncludedPrice = widget.product.taxIncludedPrice;
    // var discountedPrice = widget.product.taxIncludedSpecialPrice;
    var showStrikeThrough = widget.product.isSpecialPriceAvailable;
    var price = widget.product.priceWithTax;
    var productNotInCart = !provider.isProductInCart(widget.product);
    var strikePrice = widget.product.crossPrice != 0
        ? widget.product.crossPrice
        : widget.product.taxIncludedPrice;

    void addToCart() {
      if (isAuthTokenValid()) {
        setState(() {
          showProductSpinner = true;
          addingProductToCart = true;
          provider.addToCart(widget.product);
        });
        //CJC
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            showProductSpinner = false;
          });
        });
      } else {
        //provider.addToCart(widget.product);
        Navigator.of(context).pushNamed(LoginScreen.routeName);
      }
    }

    return typeOneProduct(
      onProductTap,
      image,
      onTapLike,
      productName,
      weight,
      discount,
      productNotInCart,
      addToCart,
      showStrikeThrough,
      price,
      taxIncludedPrice,
      strikePrice,
    );
  }

  Widget typeOneProduct(
      void onProductTap(),
      String image,
      void onTapLike(),
      String productName,
      String weight,
      String discount,
      bool productNotInCart,
      void addToCart(),
      bool showStrikeThrough,
      double price,
      double taxIncludedPrice,
      strikePrice) {
    return Container(
      width: ScreenUtil().setWidth(152),
      padding: EdgeInsets.only(left: 10, right: 10, top: 0),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Color(0XFFF5F5F8))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //Like button
          // Row(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   mainAxisAlignment: MainAxisAlignment.end,
          //   children: [
          //     GestureDetector(
          //       onTap: onTapLike,
          //       child: provider.isProductInWishlist(widget.product)
          //           ? Icon(
          //               Icons.favorite,
          //               size: ScreenUtil().setWidth(20),
          //               color: values.NESTO_GREEN,
          //             )
          //           : Icon(
          //               Icons.favorite_border,
          //               size: ScreenUtil().setWidth(20),
          //               color: Colors.black,
          //             ),
          //     ),
          //   ],
          // ),
          //Image
          GestureDetector(
            onTap: onProductTap,
            child: SizedBox(
              child: Column(
                children: [
                  SizedBox(
                    height: ScreenUtil().setWidth(80),
                    width: ScreenUtil().setWidth(90),
                    child: ImageWidget(
                      maxHeightDiskCache: 900,
                      maxWidthDiskCache: 900,
                      imageUrl: image,
                      fadeInDuration: Duration(milliseconds: 1),
                    ),
                  ),
                  Container(
                    height: ScreenUtil().setWidth(18),
                    child: Text(
                      productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    height: ScreenUtil().setHeight(25),
                    // color: Colors.amber,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Visibility(
                            visible: showStrikeThrough,
                            child: Text(
                              strings.AED +
                                  ' ' +
                                  strikePrice.toStringAsFixed(2),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color(0xFF757D85),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 10,
                                  decoration: TextDecoration.lineThrough),
                            ),
                          ),
                          Visibility(
                            visible: showStrikeThrough,
                            child: SizedBox(
                              width: 4,
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(
                                strings.AED + ' ' + price.toStringAsFixed(2),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // SizedBox(
          //   height: ScreenUtil().setHeight(values.SPACING_MARGIN_SMALL),
          // ),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: ScreenUtil().setWidth(30),
              width: ScreenUtil().setWidth(111),
              decoration: BoxDecoration(
                  color: ((!widget.product.inStock ||
                              !widget.product.productInStockMagento) ||
                          (!widget.product.isBackOrder &&
                              widget.product.quantityMagento == 0)
                      ? Color(0xFFC71712)
                      : values.NESTO_GREEN)),
              child: widget.product.inStock
                  ? widget.product.productInStockMagento
                      ? (widget.product.isBackOrder ||
                              (widget.product.quantityMagento > 0))
                          ? showProductSpinner //provider.isProductInUpdatingProduct(widget.product)
                              ? Center(
                                  child: ProductWidgetSpinner(Colors.white))
                              : productNotInCart
                                  ? FlatButton(
                                      onPressed: addToCart,
                                      child: Center(
                                        child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: addingProductToCart
                                                ? Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                    valueColor:
                                                        new AlwaysStoppedAnimation<
                                                                Color>(
                                                            Colors.white),
                                                  ))
                                                : Text(
                                                    strings.ADD_TO_CART,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12),
                                                  )),
                                      ),
                                    )
                                  : Stepper(product: widget.product)
                          : Center(
                              child: Text(
                                strings.OUT_OF_STOCK,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                            )
                      : Center(
                          child: Text(
                            strings.OUT_OF_STOCK,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        )
                  : Center(
                      child: Text(
                        strings.OUT_OF_STOCK,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class Stepper extends StatelessWidget {
  Stepper({
    this.product,
  });

  final Product product;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StoreProvider>(context, listen: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(4.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () => provider.decreaseQuantity(
                // isFromCartScreen: false,
                product: product,
              ),
              child: Container(
                color: Colors.transparent,
                child: Center(
                    child: Icon(
                  Icons.remove,
                  size: 18.0,
                  color: Colors.white,
                )),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              child: Center(
                  child: FittedBox(
                fit: BoxFit.scaleDown,
                child: (true)
                    ? Text(
                        provider.getCartQuantity(product).toString(),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      )
                    : Center(child: ProductWidgetSpinner(Colors.white)),
              )),
            ),
          ),
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () => provider.increaseQuantity(product),
              child: Container(
                color: Colors.transparent,
                child: Center(
                    child: Icon(
                  Icons.add,
                  size: 18.0,
                  color: Colors.white,
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
