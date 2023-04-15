import 'package:Nesto/models/product.dart';
import 'package:Nesto/providers/auth_provider.dart';
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
import 'package:visibility_detector/visibility_detector.dart';
import 'optimized_cache_image_widget.dart';
import 'package:Nesto/extensions/number_extension.dart';

class ProductWidget extends StatefulWidget {
  //Constructor
  final Product product;
  final GlobalKey<ScaffoldState> scaffoldKey;
  bool type2 = false;
  final String dealName;
  final String creativeSlot;

  ProductWidget(
      {@required this.product,
      @required this.scaffoldKey,
      this.type2,
      this.dealName,
      this.creativeSlot});

  @override
  _ProductWidgetState createState() => _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget> {
  bool notLogged = true;
  GlobalKey<State> key = new GlobalKey();
  final String _env = FlavorConfig.instance.variables["env"];
  bool addingProductToCart = false;
  Widget build(BuildContext context) {
    //Screen Util Init
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);

    //Provider
    final provider = Provider.of<StoreProvider>(context);

    //Auth provider
    final authProvider = Provider.of<AuthProvider>(context);

    if (!provider.isProductInCart(widget.product) && addingProductToCart) {
      setState(() {
        addingProductToCart = false;
      });
    }

    void onProductTap() {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      // provider.addToRecentSearches(widget.product.name);
      // provider.selectedProduct = widget.product;
      // Navigator.of(context).pushNamed(ProductDetail.routeName);
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

      //firebase analytics logging
      if ((widget?.dealName ?? "").isNotEmpty) {
        firebaseAnalytics.logSelectPromotion(
            promotionID: widget?.product?.sku ?? "",
            promotionName: widget?.product?.imageURL ?? "",
            creativeName: widget?.dealName ?? "",
            creativeSlot: widget?.creativeSlot ?? "",
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
          addingProductToCart = true;
          provider.addToCart(widget.product);
        });
      } else {
        //provider.addToCart(widget.product);
        Navigator.of(context).pushNamed(LoginScreen.routeName);
      }
    }

    if (!widget.type2 ?? false) {
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
          strikePrice);
    } else {
      return type2Product(
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
          strikePrice);
    }
  }

  Widget type2Product(
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
      double strikePrice) {
    var provider = Provider.of<StoreProvider>(context);

    return VisibilityDetector(
      key: key,
      onVisibilityChanged: (VisibilityInfo info) {
        if (info.visibleFraction == 1 &&
            notLogged &&
            widget.creativeSlot != null) {
          notLogged = false;
          //firebase analytics logging.
          firebaseAnalytics.logViewPromotion(
              promotionID: widget?.product?.sku ?? "",
              promotionName: widget?.product?.imageURL ?? "",
              creativeName: widget?.dealName ?? "",
              creativeSlot: widget?.creativeSlot ?? "",
              locationID: (widget?.product?.taxExcludedPrice ?? "").toString());
        }
      },
      child: Container(
        color: Colors.white,
        height: ScreenUtil().setWidth(324),
        width: ScreenUtil().setWidth(206),
        padding: EdgeInsets.only(top: ScreenUtil().setWidth(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: onProductTap,
              child: SizedBox(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(18.0)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Icon(
                          //   Icons.bolt,
                          //   color: Colors.yellow,
                          // ),
                          GestureDetector(
                            onTap: onTapLike,
                            child: provider.isProductInWishlist(widget.product)
                                ? Icon(
                                    Icons.favorite,
                                    size: ScreenUtil().setWidth(20),
                                    color: values.NESTO_GREEN,
                                  )
                                : Icon(
                                    Icons.favorite_border,
                                    size: ScreenUtil().setWidth(20),
                                    color: Colors.black,
                                  ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      // color: Colors.yellow,
                      height: ScreenUtil().setWidth(152),
                      width: ScreenUtil().setWidth(172),
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: ImageWidget(
                          maxHeightDiskCache: 900,
                          maxWidthDiskCache: 900,
                          fadeInDuration: Duration(milliseconds: 1),
                          imageUrl: image,
                        ),
                      ),
                    ),

                    //text container
                    Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(17.0)),
                      height: ScreenUtil().setWidth(35),
                      // color: Colors.amber,
                      child: Text(
                        productName,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 13,
                            height: 1.19,
                            fontWeight: FontWeight.w600,
                            color: Colors.black),
                      ),
                    ),
                    Visibility(
                      visible: false,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          ScreenUtil().setWidth(18.0),
                          ScreenUtil().setHeight(7.0),
                          0.0,
                          0.0,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 5.0),
                              height: ScreenUtil().setHeight(26.0),
                              width: ScreenUtil().setWidth(45.0),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  weight,
                                  style: TextStyle(
                                      fontSize: 13.22,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Color(0XFF00983D)),
                                  borderRadius: BorderRadius.circular(3.31)),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 7.23),
                              padding: EdgeInsets.symmetric(
                                  vertical: ScreenUtil().setHeight(5.0),
                                  horizontal: ScreenUtil().setWidth(5.0)),
                              height: ScreenUtil().setHeight(26.0),
                              width: ScreenUtil().setWidth(45.0),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  discount,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13.22,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                              decoration: BoxDecoration(
                                  color: Color(0XFFFFB930),
                                  borderRadius: BorderRadius.circular(3.31)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(17.0)),
                      margin: EdgeInsets.symmetric(
                          vertical: ScreenUtil().setWidth(5.0)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Visibility(
                            visible: showStrikeThrough,
                            child: Flexible(
                              child: FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Text(
                                  strings.AED +
                                      ' ' +
                                      (strikePrice.twoDecimal()),
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                      decoration: TextDecoration.lineThrough),
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: showStrikeThrough,
                            child: SizedBox(
                              width: ScreenUtil().setWidth(6.0),
                            ),
                          ),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Text(
                                strings.AED + ' ' + price.twoDecimal(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: ScreenUtil().setWidth(10.0),
                  bottom: ScreenUtil().setWidth(6.0)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  height: ScreenUtil().setWidth(40),
                  width: ScreenUtil().setWidth(150),
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
                              ? provider.isProductInUpdatingProduct(
                                      widget.product)
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
            ),
            // Padding(
            //   padding: EdgeInsets.only(
            //       top: ScreenUtil().setWidth(10.0),
            //       bottom: ScreenUtil().setWidth(6.0)),
            //   child: ClipRRect(
            //     borderRadius: BorderRadius.circular(4),
            //     child: Container(
            //       height: ScreenUtil().setWidth(40),
            //       width: ScreenUtil().setWidth(150),
            //       decoration: BoxDecoration(
            //         color: widget.product.isBackOrder
            //             ? values.NESTO_GREEN
            //             : widget.product.inStock
            //                 ? values.NESTO_GREEN
            //                 : Color(0xFFC71712),
            //       ),
            //       child: widget.product.isBackOrder
            //           ? provider.isProductInUpdatingProduct(widget.product)
            //               ? Center(child: ProductWidgetSpinner(Colors.white))
            //               : productNotInCart
            //                   ? FlatButton(
            //                       onPressed: addToCart,
            //                       child: Center(
            //                         child: FittedBox(
            //                             fit: BoxFit.scaleDown,
            //                             child: addingProductToCart
            //                                 ? Center(
            //                                     child: CircularProgressIndicator(
            //                                     valueColor:
            //                                         new AlwaysStoppedAnimation<
            //                                             Color>(Colors.white),
            //                                   ))
            //                                 : Text(
            //                                     strings.ADD_TO_CART,
            //                                     style: TextStyle(
            //                                         color: Colors.white,
            //                                         fontWeight: FontWeight.bold,
            //                                         fontSize: 12),
            //                                   )),
            //                       ),
            //                     )
            //                   : Stepper(product: widget.product)
            //           : widget.product.inStock
            //               ? provider.isProductInUpdatingProduct(widget.product)
            //                   ? Center(child: ProductWidgetSpinner(Colors.white))
            //                   : productNotInCart
            //                       ? FlatButton(
            //                           onPressed: addToCart,
            //                           child: Center(
            //                             child: FittedBox(
            //                                 fit: BoxFit.scaleDown,
            //                                 child: addingProductToCart
            //                                     ? Center(
            //                                         child:
            //                                             CircularProgressIndicator(
            //                                         valueColor:
            //                                             new AlwaysStoppedAnimation<
            //                                                 Color>(Colors.white),
            //                                       ))
            //                                     : Text(
            //                                         strings.ADD_TO_CART,
            //                                         style: TextStyle(
            //                                             color: Colors.white,
            //                                             fontWeight:
            //                                                 FontWeight.bold,
            //                                             fontSize: 12),
            //                                       )),
            //                           ),
            //                         )
            //                       : Stepper(product: widget.product)
            //               : Center(
            //                   child: Text(
            //                     strings.OUT_OF_STOCK,
            //                     style: TextStyle(
            //                         color: Colors.white,
            //                         fontWeight: FontWeight.bold,
            //                         fontSize: 12),
            //                   ),
            //                 ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
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
      double strikePrice) {
    var provider = Provider.of<StoreProvider>(context);

    return VisibilityDetector(
      key: key,
      onVisibilityChanged: (VisibilityInfo info) {
        if (info.visibleFraction == 1 &&
            notLogged &&
            widget.creativeSlot != null) {
          notLogged = false;
          //firebase analytics logging.
          firebaseAnalytics.logViewPromotion(
              promotionID: widget?.product?.sku ?? "",
              promotionName: widget?.product?.imageURL ?? "",
              creativeName: widget?.dealName ?? "",
              creativeSlot: widget?.creativeSlot ?? "",
              locationID: (widget?.product?.taxExcludedPrice ?? "").toString());
        }
      },
      child: Container(
        width: ScreenUtil().setWidth(152),
        height: ScreenUtil().setWidth(277),
        padding: EdgeInsets.only(
            left: ScreenUtil().setWidth(values.SPACING_MARGIN_STANDARD),
            right: ScreenUtil().setWidth(values.SPACING_MARGIN_STANDARD),
            top: ScreenUtil().setWidth(values.SPACING_MARGIN_STANDARD)),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Color(0XFFF5F5F8))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Icon(Icons.bolt,
                //     size: ScreenUtil().setWidth(20), color: Color(0xFFFFB930)),
                GestureDetector(
                  onTap: onTapLike,
                  child: provider.isProductInWishlist(widget.product)
                      ? Icon(
                          Icons.favorite,
                          size: ScreenUtil().setWidth(20),
                          color: values.NESTO_GREEN,
                        )
                      : Icon(
                          Icons.favorite_border,
                          size: ScreenUtil().setWidth(20),
                          color: Colors.black,
                        ),
                ),
              ],
            ),
            GestureDetector(
              onTap: onProductTap,
              child: SizedBox(
                child: Column(
                  children: [
                    SizedBox(
                      height: ScreenUtil().setWidth(106),
                      width: ScreenUtil().setWidth(116),
                      child: ImageWidget(
                        maxHeightDiskCache: 900,
                        maxWidthDiskCache: 900,
                        imageUrl: image,
                        fadeInDuration: Duration(milliseconds: 1),
                      ),
                    ),
                    Container(
                      height: ScreenUtil().setWidth(35),
                      child: Text(
                        productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    SizedBox(
                      height:
                          ScreenUtil().setWidth(values.SPACING_MARGIN_SMALL),
                    ),
                    Visibility(
                      visible: false,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: ScreenUtil().setWidth(42),
                            height: ScreenUtil().setWidth(24),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                    color: Theme.of(context).primaryColor)),
                            child: Center(
                              child: Text(weight,
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87)),
                            ),
                          ),
                          SizedBox(
                            width: ScreenUtil()
                                .setWidth(values.SPACING_MARGIN_SMALL),
                          ),
                          Container(
                            width: ScreenUtil().setWidth(42),
                            height: ScreenUtil().setWidth(24),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Color(0xFFFFB930)),
                            child: Center(
                              child: Text(
                                discount,
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: ScreenUtil().setWidth(5.0),
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
                                strings.AED + ' ' + strikePrice.twoDecimal(),
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
                                width: ScreenUtil()
                                    .setWidth(values.SPACING_MARGIN_TEXT),
                              ),
                            ),
                            Text(
                              strings.AED + ' ' + price.twoDecimal(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: ScreenUtil().setHeight(values.SPACING_MARGIN_SMALL),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                height: ScreenUtil().setWidth(33),
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
                            ? provider
                                    .isProductInUpdatingProduct(widget.product)
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
            //  ClipRRect(
            //   borderRadius: BorderRadius.circular(4),
            //   child: Container(
            //     height: ScreenUtil().setWidth(33),
            //     width: ScreenUtil().setWidth(111),
            //     decoration: BoxDecoration(
            //       color: widget.product.inStock
            //           ? values.NESTO_GREEN
            //           : Color(0xFFC71712),
            //     ),
            //     child: widget.product.inStock
            //         ? provider.isProductInUpdatingProduct(widget.product)
            //             ? Center(child: ProductWidgetSpinner(Colors.white))
            //             : productNotInCart
            //                 ? TextButton(
            //                     onPressed: addToCart,
            //                     child: Center(
            //                       child: FittedBox(
            //                           fit: BoxFit.scaleDown,
            //                           child: addingProductToCart
            //                               ? Center(
            //                                   child: CircularProgressIndicator(
            //                                   valueColor:
            //                                       new AlwaysStoppedAnimation<
            //                                           Color>(Colors.white),
            //                                 ))
            //                               : Text(
            //                                   strings.ADD_TO_CART,
            //                                   style: TextStyle(
            //                                       color: Colors.white,
            //                                       fontWeight: FontWeight.bold,
            //                                       fontSize: 12),
            //                                 )),
            //                     ),
            //                   )
            //                 : Stepper(product: widget.product)
            //         : Center(
            //             child: Text(
            //               strings.OUT_OF_STOCK,
            //               style: TextStyle(
            //                   color: Colors.white,
            //                   fontWeight: FontWeight.bold,
            //                   fontSize: 12),
            //             ),
            //           ),
            //   ),
            // ),
            SizedBox(
              height: ScreenUtil().setHeight(14.0),
            )
          ],
        ),
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
                  isFromCartScreen: false, product: product),
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
