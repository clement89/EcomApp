import 'dart:ui';

import 'package:Nesto/models/cartItem.dart';
import 'package:Nesto/models/product.dart';
import 'package:Nesto/providers/auth_provider.dart';
import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/screens/checkout_screen.dart';
import 'package:Nesto/screens/login_screen.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/strings.dart' as strings;
import 'package:Nesto/utils/style.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/widgets/cart_variant_widget.dart';
import 'package:Nesto/widgets/coupon_applied_banner_widget.dart';
import 'package:Nesto/widgets/custom_list_tile.dart';
import 'package:Nesto/widgets/milestone_view.dart';
import 'package:Nesto/widgets/popular_product.dart';
import 'package:Nesto/widgets/product_widget.dart';
import 'package:Nesto/widgets/product_widget_spinner.dart';
import 'package:Nesto/widgets/total_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:Nesto/extensions/number_extension.dart';

import '../utils/util.dart';

class CartScreen extends StatefulWidget {
  static String routeName = "/cart_screen";
  CartScreen({Key key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // @override
  // void initState() {
  //   super.initState();
  //   Future.delayed(Duration.zero, () {
  //     var provider = Provider.of<StoreProvider>(context, listen: false);
  //     if(isAuthTokenValid()) provider.getMagentoCart();
  //   });
  // }

  bool _showCartSpinner = false;
  bool _checkOutButtonLoading = false;
  Set<CartItem> _cart;
  bool delayedSync = false;

  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "Cart Screen");
    super.initState();
    Future.delayed(Duration.zero, () {
      var provider = Provider.of<StoreProvider>(context, listen: false);
      if (isAuthTokenValid()) {
        if (provider.updatingProducts.isNotEmpty) {
          logNesto("Delayed Sync enabled");
          delayedSync = true;
          provider.showCartSyncLoader();
        } else {
          provider.getMagentoCart();
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Screen Util Init
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);

    //Provider data
    var provider = Provider.of<StoreProvider>(context);
    var authProvider = Provider.of<AuthProvider>(context);

    if (delayedSync) {
      Future.delayed(Duration.zero, () async {
        if (provider.updatingProducts.isEmpty) {
          logNesto("Delayed Sync completed");
          delayedSync = false;
          provider.getMagentoCart();
        }
      });
    }

    _cart = provider.cart;

    List itemsNotInCart = provider.bestSellers
        .where((element) => !provider.isProductInCart(element))
        .toList();

    if (provider.showCouponRemovedError) {
      provider.showCouponRemovedError = false;
      showError(context, strings.COUPON_CODE_REMOVED_BCS_SUBTOTAL_BELOW_LIMIT);
    }

    return Stack(
      children: [
        Scaffold(
          // appBar: rootHeaderBar(
          //     title: strings.MY_CART,
          //     showSearchBar: true,
          //     onPress: () =>
          //         Navigator.of(context).pushNamed(SearchScreen.routeName)),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            // color: Colors.blueGrey,
            child: Column(
              children: [
                ((provider.showCouponRemovalAlertAfterAppRestart ||
                            provider.couponCodeSubmitStatus ==
                                COUPON_CODE_STATUS.APPLIED_SUCCESSFULLY) &&
                        _cart.isNotEmpty)
                    ? CouponAppliedBanner()
                    : Container(),
                Expanded(
                  child: RefreshIndicator(
                    color: values.NESTO_GREEN,
                    onRefresh: () async {
                      await provider.getMagentoCart();
                    },
                    child: SingleChildScrollView(
                      //controller: _scrollController,
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Visibility(
                            visible:
                                itemsNotInCart.isNotEmpty && _cart.isNotEmpty,
                            child: MilestoneView(
                              showCartButton: false,
                            ),
                          ),
                          _lightBorder(),
                          Visibility(
                            visible: itemsNotInCart.isNotEmpty &&
                                provider.bestSellers.isNotEmpty,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 15, bottom: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          strings.MOST_POPULAR_ITEM,
                                          style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: ScreenUtil().setWidth(300),
                                    width: double.infinity,
                                    // color: Colors.pink,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: itemsNotInCart.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        var product = itemsNotInCart[index];
                                        return Padding(
                                          padding: EdgeInsets.only(
                                              left:
                                                  ScreenUtil().setWidth(10.0)),
                                          child: ProductWidget(
                                            product: product,
                                            type2: false,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          _lightBorder(),
                          //CART ITEMS
                          !isAuthTokenValid()
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 67.0, vertical: 30.0),
                                  child: emptyCartCardForLogOut(),
                                )
                              : _cart.isNotEmpty
                                  ? _buildCartList(provider)
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 67.0, vertical: 30.0),
                                      child: emptyCartCard(),
                                    ),

                          //total container
                          Visibility(
                            visible: false,
                            child: Column(
                              children: [
                                Divider(),
                                Padding(
                                  padding:
                                      // EdgeInsets.fromLTRB(20.0, 60.0, 20.0, 0.0),
                                      EdgeInsets.only(
                                    left: ScreenUtil().setWidth(20.0),
                                    right: ScreenUtil().setHeight(20.0),
                                    top: ScreenUtil().setHeight(25.0),
                                  ),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: TotalContainer(provider: provider),
                                  ),
                                ),
                              ],
                            ),
                          )

                          // CouponCode()
                        ],
                      ),
                    ),
                  ),
                ),
                _buildTotal(provider, authProvider),
              ],
            ),
          ),
        ),
        Visibility(
          visible: provider.cartSyncLoader,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black12,
            child: Center(
              child: CircularProgressIndicator(
                valueColor:
                    new AlwaysStoppedAnimation<Color>(values.NESTO_GREEN),
              ),
            ),
          ),
        )
      ],
    );
  }

  Column emptyCartCardForLogOut() {
    return Column(
      children: [
        Center(
            child: SvgPicture.asset('assets/svg/empty_cart.svg',
                height: 280, width: 280)),
        SizedBox(
          height: ScreenUtil().setWidth(24),
        ),
        Text(
          strings.FIRSTLY_LETS_SIGN_YOU_IN,
          style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              height: 1.17,
              fontWeight: FontWeight.w700),
        ),
        SizedBox(
          height: ScreenUtil().setWidth(8),
        ),
        Text(
          strings.PLEASE_SIGN_IN_TO_ADD_ITEMS,
          style: TextStyle(
            fontSize: 17,
            height: 1.19,
            color: Color(0XFF000000).withOpacity(0.57),
          ),
        ),
        Text(
          strings.INTO_THE_CART,
          style: TextStyle(
            fontSize: 17,
            height: 1.19,
            color: Color(0XFF000000).withOpacity(0.57),
          ),
        ),
        SizedBox(
          height: ScreenUtil().setWidth(8),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushNamed(LoginScreen.routeName);
          },
          child: Text(strings.SIGN_IN, style: TextStyle(fontSize: 14)),
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            backgroundColor:
                MaterialStateProperty.all<Color>(values.NESTO_GREEN),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  side: BorderSide(color: values.NESTO_GREEN)),
            ),
          ),
        ),
      ],
    );
  }

  Column emptyCartCard() {
    return Column(
      children: [
        Center(
            child: SvgPicture.asset('assets/svg/empty_cart.svg',
                height: 280, width: 280)),
        SizedBox(
          height: ScreenUtil().setWidth(24),
        ),
        Text(
          strings.CART_EMPTY,
          style: TextStyle(
              color: Colors.black,
              fontSize: 28,
              height: 1.19,
              fontWeight: FontWeight.w700),
        ),
        SizedBox(
          height: ScreenUtil().setWidth(8),
        ),
        Text(
          strings.ADD_ITEMS_TO_YOUR_CART,
          style: TextStyle(
            fontSize: 17,
            height: 1.19,
            color: Color(0XFF000000).withOpacity(0.57),
          ),
        ),
        Text(
          strings.TO_VIEW_THEM_HERE,
          style: TextStyle(
            fontSize: 17,
            height: 1.19,
            color: Color(0XFF000000).withOpacity(0.57),
          ),
        )
      ],
    );
  }

//New Items
  Widget _lightBorder() {
    return Container(
      height: 20,
      color: Colors.grey.withOpacity(0.1),
    );
  }

  Widget _buildTotal(StoreProvider provider, AuthProvider authProvider) {
    return Visibility(
      visible: _cart.isNotEmpty,
      child: Container(
        // height: ScreenUtil().setHeight(100.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(width: 1.0, color: Colors.black12),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(
            10,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${_cart.length} ITEMS',
                    style: textStyleSmall,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      provider.showShippingAddressSpinner
                          ? ProductWidgetSpinner(values.NESTO_GREEN)
                          : Text(
                              strings.AED +
                                  ' ' +
                                  provider.grandTotal.toStringAsFixed(2),
                              style: textStyleHeading,
                            ),
                      SizedBox(width: 5),
                      Text(
                        strings.VAT_INCLUSIVE,
                        style: textStyleVerySmall,
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(
                height: 50,
                child: Material(
                  color: Color(0XFF00983D),
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.84)),
                  child: MaterialButton(
                    height: ScreenUtil().setHeight(61.86),
                    onPressed: () async {
                      if (!_checkOutButtonLoading) {
                        setState(() {
                          _checkOutButtonLoading = true;
                        });
                        if (!isAuthTokenValid()) {
                          setState(() {
                            _checkOutButtonLoading = false;
                          });
                          Navigator.of(context)
                              .pushNamed(LoginScreen.routeName);
                          return;
                        }
                        bool stockAvailble = true;
                        for (var element in _cart) {
                          if (getErrorTextForStepper(element) != "") {
                            stockAvailble = false;
                            break;
                          }
                        }
                        if (stockAvailble) {
                          //firbase analytics logging.
                          firebaseAnalytics.logBeginCheckout(
                            total: provider?.grandTotal,
                            currency: "AED",
                          );

                          provider.hideCartSyncLoader();
                          provider.hideSpinnerInCart();
                          if (authProvider.magentoUser == null) {
                            await authProvider.fetchMagentoUser();
                            if (authProvider.magentoUser != null) {
                              await Navigator.of(context)
                                  .pushNamed(CheckoutScreen.routeName);
                            }
                            setState(() {
                              _checkOutButtonLoading = false;
                            });
                          } else if (authProvider.magentoUser != null) {
                            Navigator.of(context)
                                .pushNamed(CheckoutScreen.routeName);
                            setState(() {
                              _checkOutButtonLoading = false;
                            });
                          }
                        } else {
                          setState(() {
                            _checkOutButtonLoading = false;
                          });
                          showError(context,
                              'Some products have insufficient stock. Please update your cart');
                          provider.getMagentoCart();
                        }
                      }
                    },
                    child: Center(
                      child: _checkOutButtonLoading
                          ? ProductWidgetSpinner(Colors.white)
                          : FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Text(
                                'Proceed to Checkout',
                                style: TextStyle(
                                    color: Colors.white,
                                    // fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartList(StoreProvider provider) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Text('Items', style: textStyleHeading),
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          itemCount: _cart.length,
          itemBuilder: (BuildContext context, int index) {
            var cartItem = _cart.elementAt(index);
            return Container(
              margin: (cartItem.hasVariants && cartItem.variants.length > 0)
                  ? EdgeInsets.only(bottom: ScreenUtil().setHeight(20))
                  : EdgeInsets.only(bottom: ScreenUtil().setHeight(0)),
              decoration: BoxDecoration(
                color: (cartItem.hasVariants && cartItem.variants.length > 0)
                    ? Color(0X7AF5F5F8)
                    : null,
                borderRadius: BorderRadius.circular(8.84),
              ),
              child: Column(
                children: [
                  Dismissible(
                    direction: DismissDirection.endToStart,
                    dismissThresholds: {DismissDirection.endToStart: 0.1},
                    behavior: HitTestBehavior.translucent,
                    onDismissed: (direction) {
                      provider.removeFromCart(
                        cartItem: cartItem,
                        isFromDismiss: true,
                        isFromCartScreen: false,
                        alertIsAlreadyShown: false,
                      );
                    },
                    background: Container(
                      height: ScreenUtil().setHeight(88.37),
                      decoration: BoxDecoration(
                        color: Colors.red,
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete_outline_outlined,
                              color: Colors.white,
                              size: 27,
                            ),
                            Text(
                              'Delete this \nItem',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      ),
                    ),
                    key: UniqueKey(),
                    child: CustomListTile(cartItem: cartItem),
                  ),
                  (cartItem.hasVariants && cartItem.variants.length > 0)
                      ? Container(
                          alignment: Alignment.topLeft,
                          width: double.infinity,
                          padding: EdgeInsets.only(
                              bottom: ScreenUtil().setWidth(20)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: ScreenUtil().setWidth(10),
                                    top: ScreenUtil().setWidth(10),
                                    bottom: ScreenUtil().setHeight(10)),
                                child: Text(
                                  strings.YOU_MAY_LIKE,
                                  style: TextStyle(
                                      fontSize: 15.47,
                                      height: 1.19,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0XFF111A2C)),
                                ),
                              ),
                              Container(
                                height: ScreenUtil().setHeight(88.37),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.zero,
                                  physics: BouncingScrollPhysics(),
                                  itemCount: cartItem.variants.length,
                                  itemBuilder: (context, index) {
                                    return CartVariantWidget(
                                      product: cartItem.variants[index],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        )
                      : SizedBox(),
                ],
              ),
            );
          },
        )
      ],
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
