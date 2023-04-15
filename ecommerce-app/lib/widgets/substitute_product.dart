import 'dart:developer';
import 'package:Nesto/extensions/number_extension.dart';
import 'package:Nesto/strings.dart' as strings;
import 'package:Nesto/models/product.dart';
import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/providers/substitution_provider.dart';
import 'package:Nesto/screens/login_screen.dart';
import 'package:Nesto/utils/util.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/widgets/product_widget_spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:provider/provider.dart';

import 'optimized_cache_image_widget.dart';

class SubstituteProduct extends StatefulWidget {
  final Product item;
  final Function startSync;
  final Function stopSync;

  const SubstituteProduct({
    Key key,
    this.item,
    @required this.startSync,
    @required this.stopSync,
  }) : super(key: key);

  @override
  _SubstituteProductState createState() => _SubstituteProductState();
}

class _SubstituteProductState extends State<SubstituteProduct> {
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<SubstitutionProvider>(context);
    var storeProvider = Provider.of<StoreProvider>(context);

    void onTapLike() {
      if (storeProvider.isProductInWishlist(widget.item)) {
        showLikeModalSheet(context, storeProvider).then((value) {});
      } else {
        setState(() {
          if (isAuthTokenValid())
            //Add product ot the liked
            storeProvider.addToWishList(widget.item);
          else
            Navigator.of(context).pushNamed(LoginScreen.routeName);
        });
      }
    }

    return Container(
      width: ScreenUtil().setWidth(152),
      height: ScreenUtil().setWidth(200),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.bolt,
                  size: ScreenUtil().setWidth(20), color: Color(0xFFFFB930)),
              GestureDetector(
                onTap: onTapLike,
                child: storeProvider.isProductInWishlist(widget.item)
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
          SizedBox(
            child: Column(
              children: [
                SizedBox(
                  height: ScreenUtil().setWidth(106),
                  width: ScreenUtil().setWidth(116),
                  child: ImageWidget(
                      fadeInDuration: Duration(milliseconds: 1),
                      maxWidthDiskCache: 900,
                      maxHeightDiskCache: 900,
                      imageUrl: widget.item.imageURL),
                ),
                Container(
                  height: ScreenUtil().setWidth(35),
                  child: Text(
                    widget.item.name,
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
                  height: ScreenUtil().setWidth(values.SPACING_MARGIN_SMALL),
                ),
                Container(
                  height: ScreenUtil().setWidth(35),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Visibility(
                        visible: widget.item.isSpecialPriceAvailable,
                        child: Text(
                          strings.AED +
                              ' ' +
                              (widget.item.crossPrice != 0
                                      ? widget.item.crossPrice
                                      : widget.item.taxIncludedPrice)
                                  .twoDecimal(),
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                              decoration: TextDecoration.lineThrough),
                        ),
                      ),
                      Visibility(
                        visible: widget.item.isSpecialPriceAvailable,
                        child: SizedBox(
                          width: ScreenUtil().setWidth(6.0),
                        ),
                      ),
                      Text(
                        strings.AED +
                            ' ' +
                            widget.item.priceWithTax.twoDecimal(),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: ScreenUtil().setHeight(values.SPACING_MARGIN_SMALL),
          ),
          //if item not in cart
          !provider.isPresentInCart(widget.item)
              ? AddToCartButton(
                  product: widget.item,
                  previousContext: context,
                  startSync: widget.startSync,
                  stopSync: widget.stopSync)
              : ProductStepper(
                  product: widget.item,
                  previousContext: context,
                  startSync: widget.startSync,
                  stopSync: widget.stopSync),
        ],
      ),
    );
  }

  Future showLikeModalSheet(BuildContext context, StoreProvider provider) {
    return showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        )),
        builder: (context) {
          return StatefulBuilder(
            builder: ((context, stateSet) {
              return new Container(
                // padding: EdgeInsets.only(
                //     left: ScreenUtil().setWidth(36),
                //     right: ScreenUtil().setWidth(36),
                //     top: ScreenUtil().setWidth(72),
                //     bottom: ScreenUtil().setWidth(32)
                // ),
                height: ScreenUtil().setWidth(380),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: ScreenUtil()
                            .setWidth(values.SPACING_MARGIN_STANDARD),
                      ),
                      Container(
                        width: ScreenUtil().setWidth(127),
                        height: ScreenUtil().setWidth(3),
                        color: Color(0xFFC4C4C4),
                      ),
                      SizedBox(
                        height: ScreenUtil().setWidth(69),
                      ),
                      Text(
                        strings.REMOVE_THIS_ITEM_FROM_FAVORITES,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 24,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: ScreenUtil()
                            .setWidth(values.SPACING_MARGIN_STANDARD),
                      ),
                      ImageWidget(
                        fadeInDuration: Duration(milliseconds: 1),
                        maxHeightDiskCache: 900,
                        maxWidthDiskCache: 900,
                        imageUrl: widget.item.imageURL,
                        width: ScreenUtil().setWidth(116),
                        height: ScreenUtil().setWidth(101),
                        errorWidget: (context, error, stackTrace) =>
                            Image.asset(
                          "assets/images/placeholder.webp",
                          width: ScreenUtil().setWidth(116),
                          height: ScreenUtil().setWidth(101),
                        ),
                      ),
                      SizedBox(
                        height: ScreenUtil()
                            .setWidth(values.SPACING_MARGIN_STANDARD),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: SizedBox(
                                  width: ScreenUtil().setWidth(140),
                                  child: Center(
                                      child: Text(
                                    strings.CANCEL,
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16),
                                  )))),
                          SizedBox(
                            width: ScreenUtil()
                                .setWidth(values.SPACING_MARGIN_SMALL),
                          ),
                          Container(
                            height: ScreenUtil().setWidth(39),
                            width: ScreenUtil().setWidth(160),
                            child: FlatButton(
                                onPressed: () {
                                  stateSet(() {
                                    provider.removeFromWishList(widget.item);
                                    Navigator.of(context).pop();
                                  });
                                },
                                color: Theme.of(context).primaryColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                child: Center(
                                    child: provider.showWishlistSpinner
                                        ? ProductWidgetSpinner(Colors.white)
                                        : Text(strings.YES_REMOVE,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16)))),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              );
            }),
          );
        });
  }
}

class AddToCartButton extends StatefulWidget {
  const AddToCartButton({
    Key key,
    @required this.product,
    @required this.previousContext,
    @required this.startSync,
    @required this.stopSync,
  }) : super(key: key);

  final Product product;
  final BuildContext previousContext;
  final Function startSync;
  final Function stopSync;

  @override
  _AddToCartButtonState createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<AddToCartButton> {
  bool showLoading = false;

  startLoading() => setState(() => showLoading = true);

  stopLoading() => setState(() => showLoading = false);

  addToCart() async {
    bool isInStock = widget?.product?.inStock ?? false;

    var provider = Provider.of<SubstitutionProvider>(context, listen: false);

    if (!isInStock) {
      return;
    }
    if (showLoading) {
      return;
    }
    try {
      widget.startSync();
      startLoading();
      await provider.addToCart(widget.product);
      stopLoading();
      widget.stopSync();
      showSuccess(widget.previousContext, strings.ORDER_UPDATED + '!');
    } catch (e) {
      log(e.toString(), name: "sub_add_to_cart_ERR");

      stopLoading();
      widget.stopSync();
      if (e?.message != null) {
        showError(widget.previousContext, e?.message);
        return;
      } else {
        showError(context, strings.SOMETHING_WENT_WRONG_WITH_EXCLAMATION);
      }
    }
    widget.stopSync();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: addToCart,
      child: Container(
        height: ScreenUtil().setWidth(33),
        width: ScreenUtil().setWidth(111),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color:
              widget.product.inStock ? values.NESTO_GREEN : Color(0xFFC71712),
        ),
        child: Center(
          child: showLoading
              ? Loader()
              : Text(
                  widget.product.inStock
                      ? strings.Add_to_cart
                      : strings.Out_of_stock,
                  style: whiteTextStyle,
                ),
        ),
      ),
    );
  }
}

class ProductStepper extends StatefulWidget {
  const ProductStepper({
    Key key,
    @required this.product,
    @required this.previousContext,
    @required this.startSync,
    @required this.stopSync,
  }) : super(key: key);

  final Product product;
  final BuildContext previousContext;
  final Function startSync;
  final Function stopSync;

  @override
  _ProductStepperState createState() => _ProductStepperState();
}

class _ProductStepperState extends State<ProductStepper> {
  bool showLoading = false;

  startLoading() => setState(() => showLoading = true);

  stopLoading() => setState(() => showLoading = false);

  increaseQuantity() async {
    var provider = Provider.of<SubstitutionProvider>(context, listen: false);

    if (showLoading) {
      return;
    }
    try {
      widget.startSync();
      startLoading();
      await provider.increaseQuantity(widget.product);
      stopLoading();
      widget.stopSync();
      showSuccess(widget.previousContext, strings.ORDER_UPDATED + '!');
    } catch (e) {
      log(e.toString(), name: "increase_err");
      stopLoading();
      widget.stopSync();
      if (e?.message != null) {
        showError(widget.previousContext, e?.message);
        return;
      } else {
        showError(widget.previousContext,
            strings.SOMETHING_WENT_WRONG_WITH_EXCLAMATION);
        return;
      }
    }
    widget.stopSync();
  }

  decreaseQuantity() async {
    var provider = Provider.of<SubstitutionProvider>(context, listen: false);

    if (showLoading) {
      return;
    }
    try {
      widget.startSync();
      startLoading();
      await provider.decreaseQuantity(widget.product);
      stopLoading();
      widget.stopSync();
      showSuccess(widget.previousContext, strings.ORDER_UPDATED + '!');
    } catch (e) {
      log(e.toString(), name: "decrease_err");
      stopLoading();
      widget.stopSync();
      if (e?.message != null) {
        showError(widget.previousContext, e?.message);
        return;
      } else {
        showError(widget.previousContext,
            strings.SOMETHING_WENT_WRONG_WITH_EXCLAMATION);
        return;
      }
    }
    widget.stopSync();
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<SubstitutionProvider>(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        color: values.NESTO_GREEN,
        height: ScreenUtil().setWidth(33),
        width: ScreenUtil().setWidth(111),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Flexible(
              flex: 1,
              child: GestureDetector(
                onTap: decreaseQuantity,
                child: Container(
                  color: Colors.transparent,
                  child: Center(
                    child: Icon(
                      Icons.remove,
                      size: 22.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Container(
                color: Colors.transparent,
                child: Center(
                  child: showLoading
                      ? SizedBox(
                          height: ScreenUtil().setWidth(13),
                          width: ScreenUtil().setWidth(13),
                          child: CircularProgressIndicator(
                            valueColor:
                                new AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: ScreenUtil().setWidth(2),
                          ),
                        )
                      : FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            provider
                                .currentQuantity(widget.product)
                                .toInt()
                                .toString(),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: GestureDetector(
                onTap: increaseQuantity,
                child: Container(
                  color: Colors.transparent,
                  child: Center(
                    child: Icon(
                      Icons.add,
                      size: 22.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Loader extends StatelessWidget {
  const Loader({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ScreenUtil().setWidth(13),
      width: ScreenUtil().setWidth(13),
      child: CircularProgressIndicator(
        valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
        strokeWidth: ScreenUtil().setWidth(2),
      ),
    );
  }
}

//styles
var whiteTextStyle =
    TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700);
