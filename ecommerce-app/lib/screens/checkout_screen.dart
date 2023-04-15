import 'dart:async';

import 'package:Nesto/models/address.dart';
import 'package:Nesto/models/cartItem.dart';
import 'package:Nesto/models/time_slot.dart';
import 'package:Nesto/providers/auth_provider.dart';
import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/screens/add_address.dart';
import 'package:Nesto/screens/cart_screen.dart';
import 'package:Nesto/screens/order_success_screen.dart';
import 'package:Nesto/screens/payment_gateway_webpage.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/widgets/connectivity_widget.dart';
import 'package:Nesto/services/notification_service.dart';
import 'package:Nesto/widgets/coupon_applied_banner_widget.dart';
import 'package:Nesto/widgets/coupon_code.dart';
import 'package:Nesto/widgets/custom_switch.dart';
import 'package:Nesto/widgets/dismiss_keyboard_widget.dart';
import 'package:Nesto/widgets/headers.dart';
import 'package:Nesto/widgets/product_widget_spinner.dart';
import 'package:Nesto/widgets/total_container.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Nesto/strings.dart' as strings;
import '../utils/util.dart';
import 'package:Nesto/extensions/number_extension.dart';

enum PaymentType { cash_on_delivery, card_payment, none }

const String SLOT_TYPE_EXPRESS = "express";
const String SLOT_TYPE_SCHEDULED = "scheduled";

class CheckoutScreen extends StatefulWidget {
  static String routeName = "/checkout_screen";
  CheckoutScreen({Key key}) : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  //Keys and controllers
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _switchValue = true;
  String coupon = "";
  int _selectedTimeSlot = -1;
  int _selectedDate = 0;
  int _selectedAddress = 0;
  PaymentType _modeOfPayment = PaymentType.none;
  final _deliveryNoteController = TextEditingController();
  bool _today = true;
  bool _isLoading = false;

  void _onSwitchChanged(bool newValue) {
    setState(() {
      _switchValue = newValue;
    });
  }

  String getDateText(DateTime date) {
    return date.isToday()
        ? strings.TODAY
        : date.isTommorow()
            ? strings.TOMMOROW
            : DateFormat("MMMM d").format(date);
  }

  Future<bool> _willPopCallback() async {
    if (_isLoading) {
      return Future.value(false);
    } else {
      var provider = Provider.of<StoreProvider>(context, listen: false);
      if (((provider.couponCode != "") &&
          (provider.couponCodeSubmitStatus ==
              COUPON_CODE_STATUS.APPLIED_SUCCESSFULLY))) {
        notificationServices.showCustomDialog(
            title: "Are you sure?",
            description:
                "If you go back, the coupon will get removed. Do you still want to continue?",
            negativeText: 'No',
            positiveText: 'Yes',
            onNopressed: () => false,
            action: () async {
              _isLoading = true;
              await provider.removeCouponCode();
              _isLoading = false;
              Navigator.of(context).maybePop();
            },
            barrierDismissible: false);
        return Future.value(false);
      } else {
        Future.delayed(Duration.zero, () {
          provider.modifyLaunchNGenius(false);
          provider.modifyOrderError(false);
          provider.modifyOrderSuccess(false);
          EasyLoading.dismiss();
        });
        return Future.value(true);
      }
    }
  }

  void setSelectedDateAndTimeslot(
      {@required int index,
      @required int deliveryIndex,
      @required bool today}) {
    _selectedTimeSlot = index;
    _selectedDate = deliveryIndex;
    _today = today;

    var provider = Provider.of<StoreProvider>(context, listen: false);

    //Process the delivery date string
    DateTime selectedDateInDateTime =
        DateTime.now().add(Duration(days: _selectedDate));
    String selectedDateInString = selectedDateInDateTime.year.toString() +
        "-" +
        selectedDateInDateTime.month.toString() +
        "-" +
        selectedDateInDateTime.day.toString();

    provider.selectedTimeSlotIdForDelivery = (today
            ? provider.todayTimeSlots
            : provider.tomorrowTimeSlots)[_selectedTimeSlot]
        .id;
    provider.selectedDateForDelivery = selectedDateInDateTime;
    provider.selectedDateInStringForDelivery = selectedDateInString;
    provider.selectedFromTimeForDelivery = (today
            ? provider.todayTimeSlots
            : provider.tomorrowTimeSlots)[_selectedTimeSlot]
        .fromTime;
    provider.selectedToTimeForDelivery = (today
            ? provider.todayTimeSlots
            : provider.tomorrowTimeSlots)[_selectedTimeSlot]
        .toTime;
  }

  void _navigateToAddress(BuildContext context, bool disableDrag) async {
    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    var storeProvider = Provider.of<StoreProvider>(context, listen: false);
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddAddress()),
    );
    if (result == true) {
      showAddressModal(context, authProvider, storeProvider, disableDrag);
    }
  }

  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "Checkout Screen");
    // setSelectedDateAndTimeslot(index: 0, deliveryIndex: 1);
    Future.delayed(Duration.zero, () {
      var authProvider = Provider.of<AuthProvider>(context, listen: false);
      var storeProvider = Provider.of<StoreProvider>(context, listen: false);
      storeProvider.fetchTimeSlots();
      storeProvider.getMagentoCart();
      if (storeProvider.shippingAddress == null)
        showAddressModal(context, authProvider, storeProvider, true);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Screen Util Init
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);

    var provider = Provider.of<StoreProvider>(context);
    var authProvider = Provider.of<AuthProvider>(context);

    List<TimeSlot> todayTimeSlots = provider.todayTimeSlots;
    List<TimeSlot> tomorrowTimeSlots = provider.tomorrowTimeSlots;

    var _cart = provider.cart;

    //Proceed for order success
    if (provider.orderSuccess) {
      Future.delayed(Duration.zero, () {
        EasyLoading.dismiss();
        Navigator.of(context).pushNamedAndRemoveUntil(
            OrderSuccessfullScreen.routeName, (Route<dynamic> route) => false);
      });
    }

    void errorHandler() async {
      if (provider.flushCart) {
        provider.flushCart = false;
        provider.orderError = false;
        showError(context, provider.errorMessage);
        await provider.resetCart(true);
        EasyLoading.dismiss();
        Navigator.of(context).pop();
      } else {
        EasyLoading.dismiss();
        provider.orderError = false;
        showError(context, provider.errorMessage);
      }
    }

    if (provider.orderError) {
      errorHandler();
    }

    return SafeArea(
        child: WillPopScope(
      onWillPop: _willPopCallback,
      child: DismissKeyboard(
        child: Scaffold(
          key: _scaffoldKey,
          appBar: headerBar(title: strings.CHECK_OUT, context: context),
          body: ConnectivityWidget(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                children: [
                  (provider.showCouponRemovalAlertAfterAppRestart ||
                          provider.couponCodeSubmitStatus ==
                              COUPON_CODE_STATUS.APPLIED_SUCCESSFULLY)
                      ? CouponAppliedBanner()
                      : Container(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                          vertical: ScreenUtil().setHeight(30.0)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _cart.isNotEmpty
                              ? generateCheckoutList(
                                  _cart,
                                )
                              : SizedBox(
                                  height: 0,
                                ),
                          subTitle(strings.DELIVERY_ADDRESS, 30.0),
                          infoContainer(
                              text: provider.shippingAddress == null
                                  ? strings.PLEASE_CHOOSE_A_SHIPPING_ADDRESS
                                  : authProvider.getFormattedAddress(
                                      provider.shippingAddress),
                              icon: Icons.location_pin,
                              onPress: () => showAddressModal(context,
                                          authProvider, provider, false)
                                      .then((value) {
                                    //firebase analytics logging.
                                    firebaseAnalytics.logShippingInfo(
                                        location:
                                            provider?.shippingAddress?.city);
                                  })),
                          subTitle(strings.DELIVERY_TIME, 40.0),
                          infoContainer(
                              text: _selectedTimeSlot == -1
                                  ? strings.SELECT_A_DELIVERY_TIME
                                  : getDateText(DateTime.now()
                                          .add(Duration(days: _selectedDate))) +
                                      " " +
                                      (_today
                                                  ? todayTimeSlots
                                                  : tomorrowTimeSlots)[
                                              _selectedTimeSlot]
                                          .fromTime +
                                      "-" +
                                      (_today
                                                  ? todayTimeSlots
                                                  : tomorrowTimeSlots)[
                                              _selectedTimeSlot]
                                          .toTime,
                              icon: Icons.calendar_today_rounded,
                              onPress: () => showTimeModalBottomSheet(context)),
                          Padding(
                            padding: EdgeInsets.only(
                              left: ScreenUtil().setWidth(20.0),
                              right: ScreenUtil().setWidth(20.0),
                              top: ScreenUtil().setHeight(25.0),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  strings.ALLOW_SUBSTITUTION,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    notificationServices.showCustomDialog(
                                        title: strings.ALLOW_SUBSTITUTION,
                                        description: strings
                                            .ALLOW_SUBSTITUTION_DESCRIPTION,
                                        negativeText: '',
                                        positiveText: strings.OK,
                                        positiveTextColor: values.NESTO_GREEN);
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: ScreenUtil().setWidth(17.0)),
                                    child: Icon(Icons.info),
                                  ),
                                ),
                                Spacer(),
                                CustomSwitch(
                                  value: _switchValue,
                                  onChanged: _onSwitchChanged,
                                ),
                              ],
                            ),
                          ),
//TODO: ENABLE COUPON_CODE
                          subTitle('Apply Coupon', 40.0),
                          SizedBox(
                            height: ScreenUtil().setHeight(16.0),
                          ),
                          CouponCode(),
                          subTitle(strings.INSTRUCTION_FOR_THE_ORDER, 30.0),
                          Container(
                            height: ScreenUtil().setHeight(150.0),
                            margin: EdgeInsets.only(
                              left: ScreenUtil().setWidth(20.0),
                              right: ScreenUtil().setWidth(20.0),
                              top: ScreenUtil().setHeight(20.0),
                              bottom: ScreenUtil().setHeight(30.0),
                            ),
                            decoration: borderDecoration.copyWith(
                                border: Border.all(
                                    width: 1.4, color: Colors.grey[700])),
                            child: TextField(
                              maxLines: 5,
                              controller: _deliveryNoteController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(22),
                                hintText:
                                    strings.ADD_A_NOTE_REGARDING_THIS_ORDER,
                                hintStyle: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.only(right: 20.0),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       subTitle('Payment method', 0.0),
                          //       Text(
                          //         'Add New Card',
                          //         style: TextStyle(
                          //             color: Color(0XFF00983D),
                          //             fontSize: 13,
                          //             fontWeight: FontWeight.w700),
                          //       )
                          //     ],
                          //   ),
                          // ),

                          Padding(
                            padding: const EdgeInsets.only(right: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                subTitle(strings.SELECT_PAYMENT_METHOD, 0.0),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _modeOfPayment = PaymentType.card_payment;
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(
                                left: ScreenUtil().setWidth(20.0),
                                right: ScreenUtil().setWidth(20.0),
                                top: ScreenUtil().setHeight(20.0),
                              ),
                              height: ScreenUtil().setHeight(80.0),
                              decoration: borderDecoration.copyWith(
                                  border: Border.all(
                                      color: _modeOfPayment ==
                                              PaymentType.card_payment
                                          ? Color(0XFFFF6C44)
                                          : Color(0XFFF5F5F8))),
                              child: Center(
                                child: ListTile(
                                  leading: Icon(Icons.credit_card),
                                  title: Text(strings.CARD_PAYMENT),
                                  trailing: Radio(
                                    activeColor: Color(0XFFFF6C44),
                                    value: PaymentType.card_payment,
                                    groupValue: _modeOfPayment,
                                    onChanged: (value) {
                                      setState(() {
                                        _modeOfPayment = value;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _modeOfPayment = PaymentType.cash_on_delivery;
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(
                                left: ScreenUtil().setWidth(20.0),
                                right: ScreenUtil().setWidth(20.0),
                                top: ScreenUtil().setHeight(12.29),
                              ),
                              height: ScreenUtil().setHeight(80.0),
                              decoration: borderDecoration.copyWith(
                                  border: Border.all(
                                      color: _modeOfPayment ==
                                              PaymentType.cash_on_delivery
                                          ? Color(0XFFFF6C44)
                                          : Color(0XFFF5F5F8))),
                              child: Center(
                                child: ListTile(
                                  leading: Icon(Icons.money),
                                  title: Text(strings.CASH_CARD_ON_DELIVERY),
                                  trailing: Radio(
                                    activeColor: Color(0XFFFF6C44),
                                    value: PaymentType.cash_on_delivery,
                                    groupValue: _modeOfPayment,
                                    onChanged: (value) {
                                      setState(() {
                                        _modeOfPayment = value;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: ScreenUtil().setWidth(20.0),
                              right: ScreenUtil().setWidth(20.0),
                              top: ScreenUtil().setWidth(60.0),
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: TotalContainer(provider: provider),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  //green button here
                  Container(
                    height: ScreenUtil().setHeight(185),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Color(0XFF000000).withOpacity(0.05),
                              blurRadius: 10.0,
                              offset: Offset(0.0, 0.75))
                        ],
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(18.0),
                            topRight: Radius.circular(18.0))),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setWidth(26.0),
                            vertical: ScreenUtil().setHeight(26.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    strings.GRAND_TOTAL,
                                    style: TextStyle(
                                      fontSize: 17.67,
                                      height: 1.19,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    strings.VAT_INCLUSIVE,
                                    style: TextStyle(
                                        fontSize: 12,
                                        height: 1.19,
                                        color: Color(0XFF898B9A),
                                        fontWeight: FontWeight.w500),
                                  )
                                ],
                              ),
                              provider.showShippingAddressSpinner
                                  ? CircularProgressIndicator(
                                      valueColor:
                                          new AlwaysStoppedAnimation<Color>(
                                              values.NESTO_GREEN))
                                  : Text(
                                      strings.AED +
                                          ' ' +
                                          provider.grandTotal.twoDecimal(),
                                      style: TextStyle(
                                          fontSize: 22.09,
                                          fontWeight: FontWeight.w800),
                                    )
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil().setWidth(26.5)),
                          child: SizedBox(
                            width: double.infinity,
                            child: Material(
                              color: Color(0XFF00983D),
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.84)),
                              child: MaterialButton(
                                height: ScreenUtil().setHeight(61.86),
                                onPressed: () async {
                                  if (provider.couponCodeSubmitStatus !=
                                      COUPON_CODE_STATUS.APPLIED_ERROR) {
                                    if (!_isLoading) {
                                      if (provider.shippingAddress != null) {
                                        if (_selectedTimeSlot == -1) {
                                          showTimeModalBottomSheet(context);
                                          return;
                                        }
                                        if (_modeOfPayment ==
                                            PaymentType.none) {
                                          showError(
                                              context,
                                              strings
                                                  .PLEASE_SELECT_PAYMENT_METHOD);
                                          return;
                                        }
                                        EasyLoading.show(
                                          //status: 'Processing...',
                                          maskType: EasyLoadingMaskType.black,
                                        );
                                        if (_modeOfPayment ==
                                            PaymentType.cash_on_delivery) {
                                          setState(() {
                                            _isLoading = true;
                                          });
                                          try {
                                            await provider.placeOrder(
                                              'cashondelivery',
                                              provider.shippingAddress.latitude
                                                  .toString(),
                                              provider.shippingAddress.longitude
                                                  .toString(),
                                              _switchValue,
                                              _deliveryNoteController.text,
                                            );
                                          } catch (e) {}
                                          setState(() {
                                            _isLoading = false;
                                          });
                                        } else if (_modeOfPayment ==
                                            PaymentType.card_payment) {
                                          try {
                                            await provider.paymentGateway(
                                                _switchValue,
                                                _deliveryNoteController.text,
                                                isFromCheckOut: true);

                                            if (provider.launchNGenius) {
                                              print("LAUNCH NGENIUS");
                                              Future.delayed(Duration.zero, () {
                                                EasyLoading.dismiss();
                                                Navigator.of(context)
                                                    .pushReplacementNamed(
                                                        PaymentGatewayWebpage
                                                            .routeName);
                                              });
                                            }
                                          } catch (e) {}
                                        }
                                      } else {
                                        showAddressModal(context, authProvider,
                                            provider, false);
                                      }
                                    }
                                  } else {
                                    showError(context,
                                        strings.PLEASE_REMOVE_INVALID_COUPON);
                                  }
                                },
                                child: Center(
                                  child: _isLoading
                                      ? ProductWidgetSpinner(Colors.white)
                                      : Text(
                                          strings.PLACE_YOUR_ORDER,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 17.67,
                                              fontWeight: FontWeight.bold),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }

  Widget subTitle(String text, double top) {
    return Padding(
      padding: EdgeInsets.only(
        left: ScreenUtil().setWidth(20.0),
        top: ScreenUtil().setHeight(top),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget infoContainer({IconData icon, String text, Function onPress}) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        margin: EdgeInsets.only(
            left: ScreenUtil().setWidth(20.0),
            top: ScreenUtil().setHeight(12.0),
            right: ScreenUtil().setWidth(28.5)),
        // height: ScreenUtil().setHeight(73.84),
        padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setWidth(20.0),
            vertical: ScreenUtil().setHeight(20.0)),
        decoration: borderDecoration,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 31.0,
            ),
            SizedBox(
              width: ScreenUtil().setWidth(20.0),
            ),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15.6,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget generateCheckoutList(Set _cart) {
    List<Widget> _cartItems = List.generate(
        _cart.length,
        (index) => CheckoutListTile(
              cartItem: _cart.elementAt(index),
            ));
    return Column(
      children: _cartItems,
    );
  }

  Future showAddressModal(BuildContext thisContext, AuthProvider authProvider,
      StoreProvider storeProvider, bool disableDrag) {
    return showModalBottomSheet(
        context: context,
        isDismissible: (disableDrag ?? false) == true ? false : true,
        enableDrag: (disableDrag ?? false) == true ? false : true,
        // backgroundColor: Colors.white,
        builder: (context) {
          return StatefulBuilder(builder: ((context, stateSet) {
            return WillPopScope(
              onWillPop: () {
                var provider =
                    Provider.of<StoreProvider>(context, listen: false);
                if (_isLoading) {
                  return Future.value(false);
                } else {
                  Navigator.pop(context);
                  if ((disableDrag ?? false) == true) {
                    Navigator.pop(context);
                    return Future.value(true);
                  }
                  return Future.value(true);
                }
              },
              child: Container(
                height: ScreenUtil().setHeight(534),
                color: Color(0xFF737373),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(10.0),
                          topRight: const Radius.circular(10.0))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          margin: EdgeInsets.only(
                              top: ScreenUtil().setHeight(18.0),
                              bottom: ScreenUtil().setHeight(24.0)),
                          height: ScreenUtil().setHeight(4),
                          width: ScreenUtil().setWidth(127),
                          decoration: BoxDecoration(
                            color: Color(0XFFC4C4C4),
                            borderRadius: BorderRadius.circular(8.84),
                          ),
                        ),
                      ),
                      (authProvider.magentoUser?.addresses ?? []).isEmpty
                          ? Center(
                              child: Padding(
                              padding: EdgeInsets.only(
                                  bottom: ScreenUtil().setWidth(24)),
                              child: LocationEmpty(),
                            ))
                          : SizedBox(),
                      GestureDetector(
                        onTap: () async {
                          await Future.delayed(Duration(seconds: 0), () {
                            Navigator.of(context).pop();
                          });
                          await Future.delayed(Duration(seconds: 0), () {
                            _navigateToAddress(context, disableDrag);
                          });
                        },
                        child: Container(
                          height: ScreenUtil().setWidth(104.0),
                          margin: EdgeInsets.symmetric(
                              horizontal: ScreenUtil().setWidth(22.0)),
                          child: SvgPicture.asset(
                            'assets/svg/add_new_address_sabarish.svg',
                            fit: BoxFit.fill,
                          ),
                        ),
                        // child: Container(
                        //   margin: EdgeInsets.symmetric(
                        //       horizontal: ScreenUtil().setWidth(22.0)),
                        //   height: ScreenUtil().setHeight(104),
                        //   width: double.infinity,
                        //   decoration: BoxDecoration(
                        //       borderRadius: BorderRadius.circular(8.84),
                        //       border: Border.all(color: Color(0XFFF2F2F2))),
                        //   child: Center(
                        //     child: Container(
                        //       height: ScreenUtil().setHeight(44.19),
                        //       width: ScreenUtil().setWidth(44.19),
                        //       decoration: BoxDecoration(
                        //           border: Border.all(color: Color(0XFFB2B2B2)),
                        //           borderRadius: BorderRadius.circular(8.84)),
                        //       child: Center(
                        //         child: Icon(
                        //           Icons.add,
                        //           color: Color(0XFFB2B2B2),
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: ScreenUtil().setHeight(36),
                            left: ScreenUtil().setWidth(24),
                            right: ScreenUtil().setWidth(24),
                          ),
                          child: ListView.builder(
                              itemCount:
                                  (authProvider.magentoUser?.addresses ?? [])
                                      .length,
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () async {
                                    EasyLoading.show(
                                      //status: 'Processing...',
                                      maskType: EasyLoadingMaskType.black,
                                    );
                                    _selectedAddress = index;
                                    Address selectedAddress = authProvider
                                        .magentoUser
                                        .addresses[_selectedAddress];
                                    if (selectedAddress.latitude == -1.0 ||
                                        selectedAddress.longitude == -1.0) {
                                      SharedPreferences
                                          encryptedSharedPreferences =
                                          await SharedPreferences.getInstance();
                                      selectedAddress.latitude =
                                          encryptedSharedPreferences
                                                  .getDouble('userlat') ??
                                              1.0;
                                      selectedAddress.longitude =
                                          encryptedSharedPreferences
                                                  .getDouble('userlng') ??
                                              1.0;
                                    }
                                    int result = await authProvider
                                        .checkIfAddressIsInCurrentStoreId(
                                            userLat: selectedAddress.latitude,
                                            userLn: selectedAddress.longitude);
                                    EasyLoading.dismiss();
                                    //-1: POINT NOT IN POLYGON
                                    //1: POINT IN POLYGON AND WITHIN CURRENT STORE ID
                                    //0: POINT IN POLYGON BUT DIFFERENT STORE ID
                                    if (result == 1) {
                                      storeProvider.shippingAddress =
                                          selectedAddress;
                                      logNesto("SET SELECTED ADDRESS:" +
                                          storeProvider.shippingAddress.street);
                                      Navigator.of(context).pop();
                                      setState(() {});
                                    } else {
                                      if (result == 0) {
                                        if (authProvider
                                                .storeIdInPolygonCheck !=
                                            0) {
                                          showError(
                                              context,
                                              strings.YOU_ARE_SHOPPING_FROM +
                                                  websiteName +
                                                  strings
                                                      .STORE_SELECTED_ADDRESS_IS_FOR +
                                                  authProvider
                                                      .websiteNameInPolygonCheck +
                                                  '.');
                                          Future.delayed(Duration(seconds: 3),
                                              () {
                                            showError(
                                                context,
                                                strings
                                                    .PLEASE_CHANGE_YOUR_LOCATION_FROM_HOMEPAGE);
                                          });
                                        } else {
                                          showError(
                                              context,
                                              strings
                                                  .THE_SELECTED_ADDRESS_IS_NOT_WITHIN_THE_BOUND);
                                        }
                                      } else
                                        showError(
                                            context,
                                            strings
                                                .DELIVERY_NOT_AVAILABLE_IN_THIS_LOCATION);
                                    }
                                    setState(() {});
                                  },
                                  child: AddressTile(
                                    address: authProvider
                                        .magentoUser.addresses[index],
                                  ),
                                );
                              }),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          }));
        });
  }

  Future showTimeModalBottomSheet(BuildContext ctx) {
    return showModalBottomSheet(
        context: ctx,
        backgroundColor: Colors.white,
        builder: (context) {
          return StatefulBuilder(builder: ((ct1, stateSet) {
            var provider = Provider.of<StoreProvider>(ct1);
            var todayTimeSlots = provider.todayTimeSlots;
            var tomorrowTimeSlots = provider.tomorrowTimeSlots;

            return Container(
              color: Color(0xFF737373),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(10.0),
                        topRight: const Radius.circular(10.0))),
                padding: EdgeInsets.only(
                  left: ScreenUtil().setWidth(17.0),
                  right: ScreenUtil().setWidth(17.0),
                ),
                height: ScreenUtil().setHeight(534),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        margin: EdgeInsets.only(
                            top: ScreenUtil().setHeight(18.0),
                            bottom: ScreenUtil().setHeight(45.0)),
                        height: ScreenUtil().setHeight(4),
                        width: ScreenUtil().setWidth(127),
                        decoration: BoxDecoration(
                          color: Color(0XFFC4C4C4),
                          borderRadius: BorderRadius.circular(8.84),
                        ),
                      ),
                    ),
                    Expanded(
                      child: (todayTimeSlots.isNotEmpty ||
                              tomorrowTimeSlots.isNotEmpty)
                          ? ListView.builder(
                              itemCount: (todayTimeSlots.isNotEmpty ||
                                          tomorrowTimeSlots.isNotEmpty) &&
                                      provider.timeSlotDetails["endDate"]
                                              .compareTo(DateTime.now()) >
                                          0
                                  ? 2
                                  : 1,
                              itemBuilder:
                                  (BuildContext context, int deliveryIndex) {
                                var date = DateTime.now()
                                    .add(Duration(days: deliveryIndex));
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Visibility(
                                      visible: deliveryIndex == 0
                                          ? isAnyTimeSlotAvailableForToday(
                                              todayTimeSlots)
                                          : tomorrowTimeSlots.isNotEmpty,
                                      child: Text(
                                        getDateText(date).toString(),
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible: deliveryIndex == 0
                                          ? isAnyTimeSlotAvailableForToday(
                                              todayTimeSlots)
                                          : tomorrowTimeSlots.isNotEmpty,
                                      child: SizedBox(
                                        height: ScreenUtil().setHeight(13.0),
                                      ),
                                    ),
                                    Wrap(
                                      children: List.generate(
                                          (deliveryIndex == 0
                                                  ? todayTimeSlots
                                                  : tomorrowTimeSlots)
                                              .length,
                                          (index) => GestureDetector(
                                                onTap: () {
                                                  stateSet(() {
                                                    setSelectedDateAndTimeslot(
                                                        index: index,
                                                        deliveryIndex:
                                                            deliveryIndex,
                                                        today:
                                                            deliveryIndex == 0);
                                                    setState(() {});
                                                    Navigator.of(context).pop();
                                                  });
                                                },
                                                child: isTimeSlotValid(
                                                        deliveryIndex:
                                                            deliveryIndex,
                                                        cutOffTimeInString: (deliveryIndex == 0
                                                                    ? todayTimeSlots
                                                                    : tomorrowTimeSlots)[
                                                                index]
                                                            .cutOffTime,
                                                        startTimeString:
                                                            (deliveryIndex == 0 ? todayTimeSlots : tomorrowTimeSlots)[index]
                                                                    ?.startTime ??
                                                                '00:00',
                                                        slotType: (deliveryIndex == 0 ? todayTimeSlots : tomorrowTimeSlots)[index]
                                                                ?.slotType ??
                                                            SLOT_TYPE_SCHEDULED)
                                                    ? _selectedTimeSlot == index &&
                                                            _selectedDate ==
                                                                deliveryIndex
                                                        ? TimeSlotTile(
                                                            (deliveryIndex == 0
                                                                ? todayTimeSlots
                                                                : tomorrowTimeSlots)[index],
                                                            true)
                                                        : TimeSlotTile((deliveryIndex == 0 ? todayTimeSlots : tomorrowTimeSlots)[index], false)
                                                    : SizedBox(),
                                              )),
                                    ),
                                    SizedBox(
                                      height: ScreenUtil().setHeight(20.0),
                                    ),
                                  ],
                                );
                              },
                            )
                          : provider.hasTimeSlotFetchFinished
                              ? Center(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        child: SvgPicture.asset(
                                          'assets/svg/no_timeslots.svg',
                                          height: ScreenUtil().setHeight(224.0),
                                          width: ScreenUtil().setWidth(227.0),
                                        ),
                                      ),
                                      SizedBox(
                                        height: ScreenUtil().setWidth(15),
                                      ),
                                      Text(
                                        strings.NO_TIME_SLOTS_AVAILABLE,
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(
                                        height: ScreenUtil().setWidth(15),
                                      ),
                                      Text(
                                        strings
                                            .ALL_AVAILABLE_SLOT_ARE_BOOKED_NOW,
                                        style: TextStyle(
                                          fontSize: 17,
                                          color: Colors.black.withOpacity(0.57),
                                          fontWeight: FontWeight.w400,
                                          height: 1.5,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              : Center(
                                  child: CircularProgressIndicator(
                                      valueColor:
                                          new AlwaysStoppedAnimation<Color>(
                                              values.NESTO_GREEN))),
                    ),
                  ],
                ),
              ),
            );
          }));
        });
  }
}

bool isTimeSlotValid(
    {int deliveryIndex,
    String cutOffTimeInString,
    String slotType,
    String startTimeString}) {
  //All time slots are valid except for today
  if (deliveryIndex != 0) {
    if (slotType == SLOT_TYPE_EXPRESS) {
      return false;
    } else {
      return true;
    }
  } else {
    DateTime currentTime = DateTime.now();

    int cutOffTimeHour =
        int.parse(cutOffTimeInString[0] + cutOffTimeInString[1]);
    int cutOffTimeMinute =
        int.parse(cutOffTimeInString[3] + cutOffTimeInString[4]);

    DateTime cutOffTime = DateTime.now();
    cutOffTime = new DateTime(cutOffTime.year, cutOffTime.month, cutOffTime.day,
        cutOffTimeHour, cutOffTimeMinute, 0, 0, 0);

    logNesto("CURRENT TIME:" + currentTime.toString());
    logNesto("CUT OFF TIME:" + cutOffTime.toString());
    logNesto("START TIME:" + startTimeString);
    logNesto("SLOT TYPE:" + slotType);

    if (currentTime.isAfter(cutOffTime))
      return false;
    else {
      if (slotType == SLOT_TYPE_EXPRESS) {
        int startTimeHour = int.parse(startTimeString[0] + startTimeString[1]);
        int startTimeMinute =
            int.parse(startTimeString[3] + startTimeString[4]);
        DateTime startTime = DateTime.now();
        startTime = new DateTime(startTime.year, startTime.month, startTime.day,
            startTimeHour, startTimeMinute, 0, 0, 0);
        if (currentTime.isBefore(startTime))
          return false;
        else
          return true;
      } else
        return true;
    }
  }
}

bool isAnyTimeSlotAvailableForToday(List<TimeSlot> timeslots) {
  bool isTimeSlotAvailableForToday = false;

  DateTime now = DateTime.now();

  timeslots.forEach((element) {
    logNesto(element);
    //Check if current time is before cut off of every others
    int cutOffTimeHour =
        int.parse(element.cutOffTime[0] + element.cutOffTime[1]);
    int cutOffTimeMinute =
        int.parse(element.cutOffTime[3] + element.cutOffTime[4]);
    DateTime timeSlotDate = DateTime(now.year, now.month, now.day,
        cutOffTimeHour, cutOffTimeMinute, 0, 0, 0);

    if (now.isBefore(timeSlotDate)) isTimeSlotAvailableForToday = true;
  });

  return isTimeSlotAvailableForToday;
}

class LocationEmpty extends StatelessWidget {
  const LocationEmpty({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
            height: ScreenUtil().setWidth(110.0),
            width: ScreenUtil().setWidth(87.0),
            child: Image.asset('assets/images/no_addresses.png',
                fit: BoxFit.fill)),
        SizedBox(
          height: ScreenUtil().setWidth(15),
        ),
        Text(
          strings.NO_ADDRESS_FOUND,
          style: TextStyle(
            fontFamily: 'assets/fonts/sf_pro_display.ttf',
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        SizedBox(
          height: ScreenUtil().setWidth(12),
        ),
        Container(
          width: ScreenUtil().setWidth(250),
          child: Center(
            child: Text(
              strings.PLEASE_ADD_A_SHIPPING,
              style: TextStyle(
                  fontFamily: 'assets/fonts/sf_pro_display.ttf',
                  color: Colors.grey,
                  fontSize: 17,
                  fontWeight: FontWeight.w400),
            ),
          ),
        ),
        SizedBox(
          height: ScreenUtil().setWidth(3),
        ),
        Container(
          width: ScreenUtil().setWidth(250),
          child: Center(
            child: Text(
              strings.ADDRESS_FOR_YOUR_ORDER,
              style: TextStyle(
                  fontFamily: 'assets/fonts/sf_pro_display.ttf',
                  color: Colors.grey,
                  fontSize: 17,
                  fontWeight: FontWeight.w400),
            ),
          ),
        ),
      ],
    );
  }
}

class CheckoutListTile extends StatelessWidget {
  CheckoutListTile({this.cartItem});

  final CartItem cartItem;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: ScreenUtil().setWidth(20.0),
          right: ScreenUtil().setWidth(32.77),
          bottom: ScreenUtil().setHeight(10.0)),
      child: Container(
        height: ScreenUtil().setHeight(55.23),
        decoration: BoxDecoration(
          color: Color(0XFFF5F5F8),
          borderRadius: BorderRadius.circular(8.84),
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: ScreenUtil().setWidth(24.0)),
              child: Container(
                width: ScreenUtil().setWidth(46.0),
                height: ScreenUtil().setHeight(33.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.84),
                ),
                child: Center(
                  child: Text(
                    cartItem.quantity.toString() ?? '--',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: ScreenUtil().setWidth(10.0)),
              height: double.infinity,
              width: ScreenUtil().setWidth(150.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      cartItem.product.name ?? '--',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 15.47, fontWeight: FontWeight.w300),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: ScreenUtil().setWidth(16)),
                child: Container(
                  child: Text(
                    strings.AED +
                            ' ' +
                            Provider.of<StoreProvider>(context, listen: false)
                                .getProductTotal(cartItem)
                                .twoDecimal() ??
                        '--',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        color: Color(0XFF00983D),
                        fontSize: 15.47,
                        fontWeight: FontWeight.w700),
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

class TimeSlotTile extends StatelessWidget {
  final TimeSlot timeSlot;
  final bool isSelected;
  final bool isExpress;

  TimeSlotTile(this.timeSlot, this.isSelected)
      : isExpress = timeSlot?.slotType == SLOT_TYPE_EXPRESS;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(49),
      width: ScreenUtil().setWidth(176),
      margin: EdgeInsets.only(
          right: ScreenUtil().setWidth(6), bottom: ScreenUtil().setWidth(6)),
      decoration: BoxDecoration(
        color: isSelected
            ? Color(0XFFF5E7C3)
            : isExpress
                ? Color(0XFFD0F7C3)
                : Color(0XFFF5F5F8),
        // (selectedTimeSlot != index) ? Color(0XFFD0F7C3) : Colors.amber[100],
        borderRadius: BorderRadius.circular(2.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            isExpress ? Icons.bolt : Icons.query_builder,
            color: Colors.black,
          ),
          Container(
            width: ScreenUtil().setWidth(139),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                timeSlot.fromTime + "-" + timeSlot.toTime,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class AddressTile extends StatelessWidget {
  const AddressTile({Key key, this.address}) : super(key: key);

  final Address address;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(20.0)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
          color: Colors.white, border: Border.all(color: Color(0XFFF2F2F2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            address.name,
            style: TextStyle(
                fontSize: 15,
                color: Colors.black87,
                fontWeight: FontWeight.w700),
          ),
          SizedBox(
            width: ScreenUtil().setWidth(313),
            child: Text(
              address.street,
            ),
          )
        ],
      ),
    );
  }
}

extension DateHelper on DateTime {
  bool isToday() {
    final now = DateTime.now();
    return now.day == this.day &&
        now.month == this.month &&
        now.year == this.year;
  }

  bool isTommorow() {
    final tommorow = DateTime.now().add(Duration(days: 1));
    return tommorow.day == this.day &&
        tommorow.month == this.month &&
        tommorow.year == this.year;
  }
}

// styles
var borderDecoration = BoxDecoration(
  borderRadius: BorderRadius.circular(8.95),
);
