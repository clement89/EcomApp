import 'package:Nesto/extensions/number_extension.dart';
import 'package:Nesto/models/cartItem.dart';
import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/screens/login_screen.dart';
import 'package:Nesto/screens/product_details.dart';
import 'package:Nesto/services/local_storage.dart';
import 'package:Nesto/strings.dart' as strings;
import 'package:Nesto/utils/style.dart';
import 'package:Nesto/utils/util.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/widgets/product_widget_spinner.dart';
import 'package:Nesto/widgets/show_wishlist_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:provider/provider.dart';

import 'optimized_cache_image_widget.dart';

class CustomListTile extends StatefulWidget {
  const CustomListTile({
    Key key,
    @required this.cartItem,
  }) : super(key: key);

  final CartItem cartItem;

  @override
  _CustomListTileState createState() => _CustomListTileState();
}

class _CustomListTileState extends State<CustomListTile> {
  bool hideOutOfStockText;
  TextEditingController controller;

  Future<void> onPressAddNotes(
      {BuildContext context, String sku, String name}) async {
    LocalStorage localStorage = LocalStorage();
    var note;
    try {
      note = await localStorage.getNoteForSku(sku: widget.cartItem.product.sku);
    } catch (e) {
      note = "";
    }

    if (note.isNotEmpty) {
      controller.text = note;
    }

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Note'),
            content: TextField(
              maxLength: 250,
              textInputAction: TextInputAction.done,
              controller: controller,
              onSubmitted: (value) {
                localStorage.addNewItemToCart(
                    sku: sku, name: name, note: controller.text);
                Navigator.of(context).pop();
              },
              decoration: InputDecoration(
                hintText: "Please add note here",
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: values.NESTO_GREEN),
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: values.NESTO_GREEN,
                ),
                child: Text('Save', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  localStorage.addNewItemToCart(
                      sku: sku, name: name, note: controller.text);
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  navigateToProductDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return ProductDetail(
            sku: widget.cartItem.product.sku ?? "",
          );
        },
      ),
    );
  }

  @override
  void initState() {
    hideOutOfStockText = true;
    controller = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Screen Util Init
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);
    var size = MediaQuery.of(context).size;

    var provider = Provider.of<StoreProvider>(context);
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Container(
          width: double.infinity,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border(
              bottom:
                  BorderSide(width: 1.0, color: Colors.black.withOpacity(0.09)),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                  flex: 1,
                  child: GestureDetector(
                    onTap: navigateToProductDetails,
                    child: Container(
                      color: Colors.transparent,
                      child: Row(
                        children: [
                          //image
                          Container(
                            height: 60,
                            width: size.width * 0.15,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4.0),
                              child: FittedBox(
                                fit: BoxFit.fitWidth,
                                // child: Image.asset(cartItem.product.imageURL),
                                child: ImageWidget(
                                    fadeInDuration: Duration(milliseconds: 1),
                                    maxWidthDiskCache: 900,
                                    maxHeightDiskCache: 900,
                                    imageUrl: widget.cartItem.product.imageURL),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: size.width * 0.5,
                                child: Text(
                                  widget.cartItem.product.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 15.47,
                                      height: 1.19,
                                      color: Color(0XFF111A2C)),
                                ),
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Text(
                                    strings.AED +
                                        ' ' +
                                        provider
                                            .getProductTotal(widget.cartItem)
                                            .twoDecimal(),
                                    style: textStyleHeading,
                                  ),
                                  SizedBox(width: 20),
                                  _favoriteButton(provider),
                                  SizedBox(width: 10),
                                  // GestureDetector(
                                  //   onTap: () {
                                  //     onPressAddNotes(
                                  //         context: context,
                                  //         sku: widget.cartItem.product.sku,
                                  //         name: widget.cartItem.product.name);
                                  //   },
                                  //   child: Padding(
                                  //     padding: EdgeInsets.all(10),
                                  //     child: Icon(
                                  //       Icons.info_outline,
                                  //       color: Colors.black38,
                                  //       size: 18,
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )),
              Container(
                width: ScreenUtil().setWidth(105),
                height: ScreenUtil().setHeight(80),
                color: Colors.transparent,
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        (widget.cartItem.product.inStock &&
                                widget.cartItem.productInStockMagento &&
                                (((widget.cartItem.product.isBackOrder ??
                                        false)) ||
                                    (widget.cartItem.quantityMagento > 0)))
                            ? Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: ScreenUtil().setWidth(4)),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Container(
                                    width: ScreenUtil().setWidth(85),
                                    height: ScreenUtil().setHeight(40),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8.0),
                                      border: Border.all(
                                        width: 1.0,
                                        color: Colors.black12,
                                      ),
                                    ),
                                    child: provider.isProductInUpdatingProduct(
                                            widget.cartItem.product)
                                        ? Center(
                                            child: ProductWidgetSpinner(
                                                values.NESTO_GREEN))
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Expanded(
                                                flex: 4,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    provider.decreaseQuantity(
                                                        product: widget
                                                            .cartItem.product);
                                                  },
                                                  child: Container(
                                                    color: Colors.transparent,
                                                    child: Center(
                                                        child: Icon(
                                                      Icons.remove,
                                                      color: values.NESTO_GREEN,
                                                      size: 18,
                                                    )),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                  flex: 3,
                                                  child: Container(
                                                    color: Colors.transparent,
                                                    child: Center(
                                                      child: FittedBox(
                                                        fit: BoxFit.scaleDown,
                                                        child: Text(
                                                          widget.cartItem
                                                                      .quantity >
                                                                  0
                                                              ? widget.cartItem
                                                                  .quantity
                                                                  .toString()
                                                              : "1",
                                                          style: TextStyle(
                                                              color: values
                                                                  .NESTO_GREEN,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700),
                                                        ),
                                                      ),
                                                    ),
                                                  )),
                                              Expanded(
                                                flex: 4,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    provider.increaseQuantity(
                                                        widget
                                                            .cartItem.product);
                                                  },
                                                  child: Container(
                                                    color: Colors.transparent,
                                                    child: Center(
                                                        child: Icon(
                                                      Icons.add,
                                                      color: values.NESTO_GREEN,
                                                      size: 18,
                                                    )),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              )
                            : GestureDetector(
                                onTap: () {
                                  provider.removeFromCart(
                                    cartItem: widget.cartItem,
                                    isFromCartScreen: false,
                                    alertIsAlreadyShown: false,
                                  );
                                },
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        bottom: ScreenUtil().setWidth(4)),
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                )),
                        (widget.cartItem.quantityMagento != null)
                            ? ((widget.cartItem.quantityMagento <
                                        widget.cartItem.quantity) ||
                                    (widget.cartItem.quantityMagento == 0) ||
                                    (widget.cartItem.productInStockMagento ==
                                        false) ||
                                    (widget.cartItem.product.inStock ==
                                        false) ||
                                    (widget.cartItem.quantity >
                                        widget.cartItem.maximumQuantity) ||
                                    (widget.cartItem.quantity <
                                        widget.cartItem.minimumQuantity))
                                ? getErrorTextForStepper(widget.cartItem) != ""
                                    ? FittedBox(
                                        fit: BoxFit.contain,
                                        child: Text(
                                          getErrorTextForStepper(
                                              widget.cartItem),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Color(0xFFC71712),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w300),
                                        ))
                                    : Container()
                                : Container()
                            : Container(),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        //#SPECIAL NOTE
      ],
    );
  }

  Widget _favoriteButton(StoreProvider provider) {
    return GestureDetector(
      onTap: () {
        if (provider.isProductInWishlist(widget.cartItem.product)) {
          showWishListModal(context, widget.cartItem.product);
        } else {
          setState(() {
            if (isAuthTokenValid())
              //Add product ot the liked
              provider.addToWishList(widget.cartItem.product);
            else
              Navigator.of(context).pushNamed(LoginScreen.routeName);
          });
        }
      },
      child: provider.isProductInWishlist(widget.cartItem.product)
          ? Icon(
              Icons.favorite,
              size: ScreenUtil().setWidth(20),
              color: Colors.redAccent,
            )
          : Icon(
              Icons.favorite_border,
              size: ScreenUtil().setWidth(20),
              color: Colors.redAccent,
            ),
    );
  }
}
