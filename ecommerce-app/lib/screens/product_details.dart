import 'dart:io';

import 'package:Nesto/models/product.dart';
import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/screens/base_screen.dart';
import 'package:Nesto/screens/image_zoom.dart';
import 'package:Nesto/screens/login_screen.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/strings.dart' as strings;
import 'package:Nesto/utils/util.dart';
import 'package:Nesto/widgets/complimentary_products.dart';
import 'package:Nesto/widgets/connectivity_widget.dart';
import 'package:Nesto/widgets/edge_cases/fetching_items.dart';
import 'package:Nesto/widgets/edge_cases/no_products_found.dart';
import 'package:Nesto/widgets/headers.dart';
import 'package:Nesto/widgets/optimized_cache_image_widget.dart';
import 'package:Nesto/widgets/product_widget.dart';
import 'package:Nesto/widgets/product_widget_spinner.dart';
import 'package:Nesto/widgets/show_wishlist_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:provider/provider.dart';
import 'package:simple_html_css/simple_html_css.dart';
import 'package:Nesto/extensions/number_extension.dart';

import '../values.dart' as values;

class ProductDetail extends StatefulWidget {
  static const routeName = "/product_details";
  final String sku;
  ProductDetail({this.sku});

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  bool isAddingToCart = false;
  Future _future;
  Product _product;
  // #COMPLIMENTARY
  List<Product> _complimentaryProducts = [];
  Future _complimentaryFuture;

  _fetchProductWithSku(String sku) async {
    try {
      var provider = Provider.of<StoreProvider>(context, listen: false);
      var response = await provider.fetchProductWithSku(sku);
      if (response is Product) {
        setState(() {
          _product = response;
          //include complimentary future here
          //#COMPLIMENTARY
          _complimentaryFuture = getComplimentaryProducts();
        });
      } else {
        throw Exception(strings.SOMETHING_WENT_WRONG_WITH_EXCLAMATION);
      }
    } catch (e) {
      print("\n=====================>");
      print("ERR: $e");
      print("<=====================\n");
      if (e?.message != null) {
        String errMesssage = e is SocketException
            ? strings.NO_INTERNET_CONNECTION
            : e?.message ?? strings.SOMETHING_WENT_WRONG_WITH_EXCLAMATION;
        Future.delayed(
            Duration(milliseconds: 250), () => showError(context, errMesssage));
      }
      return Future.error(
          e?.message ?? strings.SOMETHING_WENT_WRONG_WITH_EXCLAMATION);
    }
  }

//#COMPLIMENTARY
  getComplimentaryProducts() async {
    var provider = Provider.of<StoreProvider>(context, listen: false);
    var response = await provider.getComplimentaryProducts(itemId: _product.id);
    print("response is not empty: ${response.runtimeType}");
    if (response.isNotEmpty) {
      print("response is not empty: ${response.runtimeType}");

      setState(() {
        _complimentaryProducts = response;
      });
    } else {
      _complimentaryProducts = [];
    }
  }

  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "Product Details Screen");
    super.initState();
    _future = _fetchProductWithSku(widget.sku);
  }

  void _onTapLike() {
    var provider = Provider.of<StoreProvider>(context, listen: false);

    if (provider.isProductInWishlist(_product)) {
      showWishListModal(context, _product);
    } else {
      setState(() {
        if (isAuthTokenValid())
          //Add product ot the liked
          provider.addToWishList(_product);
        else
          Navigator.of(context).pushNamed(LoginScreen.routeName);
      });
    }
  }

  void _onImageTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return ImageZoom(
            imageUrls: [_product?.imageURL ?? ""],
          );
        },
      ),
    );
  }

  bool get _isProductFromCurrentStore {
    var productWesiteId =
        _product.sku.split("-").isNotEmpty ? _product.sku.split("-")[0] : "";

    print("============================>");
    print("product_website_id: $productWesiteId");
    print("<============================");

    print("\n\n============================>");
    print("website_id: $sapWebsiteId");
    print("<============================\n\n");

    if (productWesiteId.isNotEmpty) {
      if (int.parse(productWesiteId) == sapWebsiteId) {
        return true;
      }
      return false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<StoreProvider>(context);
    //Screen Util Init
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);
    //print( _product.isBackOrder??false);
    //print("values check" + _product?.inStock.toString());
    return SafeArea(
      child: ConnectivityWidget(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: headerRow(title: '', context: context, isCart: true),
          body: FutureBuilder(
            future: _future,
            builder: (_, snapshot) {
              Widget _child;
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  _child = Center(child: FetchingItemsWidget());
                  break;
                case ConnectionState.done:
                  if (snapshot.hasError) {
                    _child = Center(child: NoProductsFoundWidget());
                  } else
                    _child = Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.only(
                                bottom: ScreenUtil().setWidth(8)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    height: ScreenUtil().setWidth(253.5),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(17.66)),
                                    child: SizedBox(
                                        height: ScreenUtil().setWidth(253),
                                        width: ScreenUtil().setWidth(398),
                                        child: Stack(
                                          children: [
                                            Center(
                                              child: GestureDetector(
                                                onTap: _onImageTap,
                                                child: ImageWidget(
                                                    height: ScreenUtil()
                                                        .setWidth(900),
                                                    width: ScreenUtil()
                                                        .setWidth(900),
                                                    imageUrl:
                                                        _product?.imageURL ??
                                                            ""),
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.topRight,
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    right: ScreenUtil()
                                                        .setWidth(16)),
                                                child: IconButton(
                                                  alignment: Alignment.center,
                                                  splashRadius: 0.1,
                                                  padding: EdgeInsets.zero,
                                                  onPressed: _onTapLike,
                                                  icon: provider
                                                          .isProductInWishlist(
                                                              _product)
                                                      ? Icon(
                                                          Icons.favorite,
                                                          size: ScreenUtil()
                                                              .setWidth(20),
                                                          color: values
                                                              .NESTO_GREEN,
                                                        )
                                                      : Icon(
                                                          Icons.favorite_border,
                                                          size: ScreenUtil()
                                                              .setWidth(20),
                                                          color: Colors.black,
                                                        ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ))),
                                SizedBox(
                                  height: ScreenUtil().setWidth(8),
                                ),
                                //title Text
                                Padding(
                                  padding: titlePadding,
                                  child: Text(
                                    _product?.name ?? '--',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black87,
                                        fontSize: 23.5),
                                  ),
                                ),
                                Padding(
                                  padding: specialPricePadding,
                                  child: Visibility(
                                    visible:
                                        _product?.isSpecialPriceAvailable ??
                                            false,
                                    child: Text(
                                      strings.AED +
                                              ' ${_product?.crossPrice != 0 ? _product.crossPrice?.twoDecimal() : _product?.taxIncludedPrice?.twoDecimal()}' ??
                                          '--',
                                      style: subTextStyle,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: specialPricePadding,
                                  child: Text(
                                    strings.AED +
                                            ' ${(_product?.priceWithTax?.twoDecimal())}' ??
                                        '--',
                                    style: titleTextStyle,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: ScreenUtil().setWidth(26.0),
                                  ),
                                  child: Row(
                                    children: [
                                      Visibility(
                                        visible:
                                            _product?.isSpecialPriceAvailable ??
                                                false,
                                        child: Container(
                                          padding: discountPadding,
                                          height: ScreenUtil().setWidth(28.0),
                                          width: ScreenUtil().setWidth(80.0),
                                          decoration: discountDecoration,
                                          child: FittedBox(
                                            fit: BoxFit.fitWidth,
                                            child: Text(
                                              '  ${_product?.discount?.round() ?? 0}' +
                                                  strings.OFF,
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                          visible: _product
                                                  ?.isSpecialPriceAvailable ??
                                              false,
                                          child: SizedBox(
                                            width: ScreenUtil().setWidth(
                                                values.SPACING_MARGIN_SMALL),
                                          )),
                                      Container(
                                        padding: inaamPadding,
                                        height: ScreenUtil().setWidth(28.0),
                                        width: ScreenUtil().setWidth(180.0),
                                        decoration: inaamDecoration,
                                        child: FittedBox(
                                            fit: BoxFit.fitWidth,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons
                                                      .account_balance_wallet_outlined,
                                                  size: 16.0,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(
                                                  width: 4.0,
                                                ),
                                                Text(
                                                  '  ${getInaamPoints(_product?.priceWithoutTax ?? 0).twoDecimal()}' +
                                                      strings.INAAM_POINTS +
                                                      '  ',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                )
                                              ],
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(),
                                Padding(
                                    // padding: const EdgeInsets.fromLTRB(26.0, 0.0, 0.0, 9.0),
                                    padding: descriptionPadding,
                                    child: RichText(
                                        text: HTML.toTextSpan(context,
                                            _product.description ?? "--",
                                            defaultTextStyle:
                                                descriptionTextStyle))),
                                Visibility(
                                  visible: provider.bestSellers.isNotEmpty,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: ScreenUtil().setWidth(18.0),
                                        vertical: ScreenUtil().setHeight(20.0)),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          strings.BEST_SELLERS,
                                          style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: provider.bestSellers.isNotEmpty,
                                  child: Container(
                                    height: ScreenUtil().setWidth(275),
                                    width: double.infinity,
                                    // color: Colors.pink,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: provider.bestSellers.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        var product =
                                            provider.bestSellers[index];
                                        return _product.sku != product.sku
                                            ? Padding(
                                                padding: EdgeInsets.only(
                                                    left: ScreenUtil()
                                                        .setWidth(10.0)),
                                                child: ProductWidget(
                                                  product: product,
                                                  type2: false,
                                                ),
                                              )
                                            : Container();
                                      },
                                    ),
                                  ),
                                ),
                                //#COMPLIMENTARY
                                ComplimentaryProducts(
                                  future: _complimentaryFuture,
                                  products: _complimentaryProducts,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                            height: ScreenUtil().setHeight(101),
                            width: double.infinity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if ((!_product.inStock ||
                                        !_product.productInStockMagento) ||
                                    (!_product.isBackOrder &&
                                        _product.quantityMagento == 0))
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: ScreenUtil().setWidth(26.5),
                                      right: ScreenUtil().setWidth(26.5),
                                    ),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: Material(
                                        color: Color(0xFFC71712),
                                        clipBehavior: Clip.antiAlias,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.84)),
                                        child: Visibility(
                                          visible: _isProductFromCurrentStore,
                                          child: MaterialButton(
                                            height:
                                                ScreenUtil().setHeight(61.86),
                                            child: Center(
                                              child: (provider
                                                      .isProductInUpdatingProduct(
                                                          _product))
                                                  ? Center(
                                                      child:
                                                          ProductWidgetSpinner(
                                                              Colors.white))
                                                  : Text(
                                                      strings.Out_of_stock,
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 17.67,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                else if (!provider.isProductInCart(_product))
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: ScreenUtil().setWidth(26.5),
                                      right: ScreenUtil().setWidth(26.5),
                                    ),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: Material(
                                        color: Color(0XFF00983D),
                                        clipBehavior: Clip.antiAlias,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.84)),
                                        child: Visibility(
                                          visible: _isProductFromCurrentStore,
                                          child: MaterialButton(
                                            height:
                                                ScreenUtil().setHeight(61.86),
                                            onPressed: () {
                                              if (isAuthTokenValid()) {
                                                if (!provider
                                                    .isProductInUpdatingProduct(
                                                        _product)) {
                                                  setState(() {
                                                    isAddingToCart = true;
                                                  });
                                                  provider.addToCart(_product);
                                                }
                                              } else {
                                                Navigator.of(context).pushNamed(
                                                    LoginScreen.routeName);
                                              }
                                            },
                                            child: Center(
                                              child: (provider
                                                      .isProductInUpdatingProduct(
                                                          _product))
                                                  ? Center(
                                                      child:
                                                          ProductWidgetSpinner(
                                                              Colors.white))
                                                  : Text(
                                                      strings.Add_to_cart,
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 17.67,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    //color: Colors.yellow,
                                    width: double.infinity,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          height: ScreenUtil().setHeight(68.25),
                                          width: ScreenUtil().setWidth(146.26),
                                          decoration: BoxDecoration(
                                            color: Color(0XFFF5F5F8),
                                            borderRadius:
                                                BorderRadius.circular(8.83),
                                          ),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  IconButton(
                                                    padding: EdgeInsets.zero,
                                                    alignment: Alignment.center,
                                                    icon: (provider
                                                                .getCartQuantity(
                                                                    _product) ==
                                                            1)
                                                        ? Icon(Icons
                                                            .delete_outline)
                                                        : Icon(Icons.remove),
                                                    onPressed: () {
                                                      if (provider
                                                          .isProductInUpdatingProduct(
                                                              _product)) {
                                                        provider
                                                            .decreaseQuantity(
                                                                isFromCartScreen:
                                                                    false,
                                                                product:
                                                                    _product);
                                                      }
                                                    },
                                                  ),
                                                  (!provider
                                                          .isProductInUpdatingProduct(
                                                              _product))
                                                      ? Text(provider
                                                          .getCartQuantity(
                                                              _product)
                                                          .toString())
                                                      : ProductWidgetSpinner(
                                                          Colors.black87),
                                                  IconButton(
                                                    padding: EdgeInsets.zero,
                                                    alignment: Alignment.center,
                                                    icon: Icon(Icons.add),
                                                    onPressed: () {
                                                      if (!provider
                                                          .isProductInUpdatingProduct(
                                                              _product)) {
                                                        provider
                                                            .increaseQuantity(
                                                                _product);
                                                      }
                                                    },
                                                  )
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        if (!provider
                                                            .isProductInUpdatingProduct(
                                                                _product)) {
                                                          provider
                                                              .decreaseQuantity(
                                                                  isFromCartScreen:
                                                                      false,
                                                                  product:
                                                                      _product);
                                                        }
                                                      },
                                                      child: Container(
                                                        height: ScreenUtil()
                                                            .setHeight(68.25),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .transparent,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          8.83),
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          8.83)),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        if (!provider
                                                            .isProductInUpdatingProduct(
                                                                _product)) {
                                                          provider
                                                              .increaseQuantity(
                                                                  _product);
                                                        }
                                                      },
                                                      child: Container(
                                                        height: ScreenUtil()
                                                            .setHeight(68.25),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .transparent,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          8.83),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          8.83)),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => Navigator.of(context)
                                              .pushNamedAndRemoveUntil(
                                                  BaseScreen.routeName,
                                                  (Route<dynamic> route) =>
                                                      false,
                                                  arguments: {"index": 3}),
                                          child: Container(
                                            height: ScreenUtil().setHeight(68),
                                            width: ScreenUtil().setWidth(209),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20.0),
                                            decoration: BoxDecoration(
                                                color: Color(0XFF00983D),
                                                borderRadius:
                                                    BorderRadius.circular(8.0)),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  strings.IN_CART,
                                                  style: TextStyle(
                                                    fontSize: 17.66,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    (!provider
                                                            .isProductInUpdatingProduct(
                                                                _product))
                                                        ? Text(
                                                            provider
                                                                .getProductTotal(provider
                                                                    .cart
                                                                    .firstWhere((element) =>
                                                                        _product
                                                                            .sku ==
                                                                        element
                                                                            .product
                                                                            .sku))
                                                                .twoDecimal(),
                                                            style:
                                                                whiteTextStyle,
                                                          )
                                                        : ProductWidgetSpinner(
                                                            Colors.white),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                              ],
                            ))
                      ],
                    );
                  break;
                default:
                  _child = Center(
                    child: NoProductsFoundWidget(),
                  );
                  break;
              }
              return AnimatedSwitcher(
                switchInCurve: Curves.fastOutSlowIn,
                duration: Duration(milliseconds: 500),
                child: _child,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget iconTextRow({IconData icon, String text}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(5.0)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18.0,
            color: Color(0XFF00983D),
          ),
          SizedBox(
            width: ScreenUtil().setWidth(18.0),
          ),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                  fontSize: 15.45,
                  fontWeight: FontWeight.w400,
                  color: Color(0XFF111A2C)),
            ),
          )
        ],
      ),
    );
  }
}

// styles
const titleTextStyle = TextStyle(
    fontSize: 21.5,
    height: 1.19,
    fontWeight: FontWeight.w700,
    color: Color(0xFF00983D));
const subTextStyle = TextStyle(
    fontSize: 13.26,
    height: 1.19,
    decoration: TextDecoration.lineThrough,
    fontWeight: FontWeight.w400,
    color: Colors.black54);
const descriptionTextStyle = TextStyle(
    color: Color(0XFF525C67),
    fontSize: 13.25,
    height: 1.49,
    fontWeight: FontWeight.w400);
const nutrientTextStyle =
    TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black);
const whiteTextStyle = TextStyle(
    fontSize: 17.66, fontWeight: FontWeight.bold, color: Colors.white);
var titlePadding = EdgeInsets.only(
    left: ScreenUtil().setWidth(26.0),
    right: ScreenUtil().setWidth(26.0),
    bottom: ScreenUtil().setHeight(9.0));
var specialPricePadding = EdgeInsets.only(
    left: ScreenUtil().setWidth(26.0), bottom: ScreenUtil().setHeight(9.0));
var discountPadding = EdgeInsets.symmetric(
    horizontal: ScreenUtil().setWidth(5.0),
    vertical: ScreenUtil().setWidth(5.0));
var discountDecoration = BoxDecoration(
    color: Color(0XFFFFB930), borderRadius: BorderRadius.circular(3.31));
var inaamPadding = EdgeInsets.symmetric(
  horizontal: ScreenUtil().setWidth(7.0),
  vertical: ScreenUtil().setWidth(7.0),
);
var inaamDecoration = BoxDecoration(
    color: Color(0XFF27AE60), borderRadius: BorderRadius.circular(8.0));
var descriptionPadding = EdgeInsets.only(
    left: ScreenUtil().setWidth(26.0),
    right: ScreenUtil().setWidth(16),
    top: ScreenUtil().setWidth(4),
    bottom: ScreenUtil().setHeight(9.0));
