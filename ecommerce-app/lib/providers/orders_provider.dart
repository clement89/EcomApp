import 'dart:convert' as convert;
import 'dart:convert';
import 'dart:developer' as Dev;
import 'dart:math';

import 'package:Nesto/dio/utils/urls.dart';
import 'package:Nesto/extensions/number_extension.dart';
import 'package:Nesto/models/edit_items_model.dart';
import 'package:Nesto/models/order_completed_list_model.dart';
import 'package:Nesto/models/order_details.dart';
import 'package:Nesto/models/orderlistmodel.dart';
import 'package:Nesto/models/retuen_orders_model.dart';
import 'package:Nesto/models/shipping_estimation.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/services/notification_service.dart';
import 'package:Nesto/strings.dart' as strings;
import 'package:Nesto/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';

class OrderProvider extends ChangeNotifier {
  //new approach edit order
  OrderDetails _currentOrder;

  bool successcancel = false;
  bool errorcancel = false;
  String errorcancelmessage = '';
  bool isreturnenabled = false;

//Estimation
  var minSubTotal = '0';
  var shippingCharges = '0';
  var couponMinAmount = '0';
  var couponType = '';
  var editOrderMinSubTotal = '0';
  var shippingChargeLimit = '0';
  bool couponApplied = false;

  String paymentInfo = '';
  String from = "--";
  String to = "--";
  String delivery_day = "";

  var buildNumber;
  var versionNumber;

  //Values for different order screens
  List<OrderListModel> orderlisttest = [];
  List<CompletedOrderListModel> orderlistofcompletedtest = [];
  List<EditItemsModel> unediteditemstest = [];
  OrderDetailsModel detailstest;
  List<ReturnOrderModel> returnItemsFetch = [];

  set currentOrder(value) {
    Dev.log("current_order_set");
    _currentOrder = value;
    detailsTest = value;
    notifyListeners();
  }

  //this setter needs to be deleted.
  set detailsTest(OrderDetails orderDetails) {
    double calculateinamm =
        getInaamPoints(double.tryParse(orderDetails.baseSubtotal));

    var paymentInformation = orderDetails.payment.method;
    if (paymentInformation == 'cashondelivery')
      paymentInfo = strings.CASH_CARD_ON_DELIVERY;
    else
      paymentInfo = strings.CARD_PAYMENT;

    String deliveryformattedtwo = "";
    String deliveryformatted = "";
    from = "";
    to = "";
    String fromFormatted = '';
    String toFormatted = '';

    if (orderDetails.shippingAddress.deliveryHoursFrom != null) {
      from = (orderDetails.shippingAddress.deliveryHoursFrom +
          ':' +
          orderDetails.shippingAddress.deliveryMinutesFrom);

      to = (orderDetails.shippingAddress.deliveryHoursTo +
          ':' +
          orderDetails.shippingAddress.deliveryMinutesTo);
      delivery_day = (orderDetails.shippingAddress.deliveryDay);
      var parsedDeliveryDate = DateTime.parse(delivery_day);
      final DateFormat deliveryformatter = DateFormat('EEEE dd MMMM');
      final DateFormat deliveryformattertwo = DateFormat('dd EEE');
      deliveryformatted = deliveryformatter.format(parsedDeliveryDate);
      deliveryformattedtwo = deliveryformattertwo.format(parsedDeliveryDate);

      final DateFormat formatter = DateFormat('hh:mm a');
      DateTime deliveryFrom = new DateFormat("H:mm").parse(from);
      fromFormatted = formatter.format(deliveryFrom);
      DateTime deliveryTo = new DateFormat("H:mm").parse(to);
      toFormatted = formatter.format(deliveryTo);
    }

    var parsedDate = DateTime.parse(orderDetails.createdAt.toString());
    final DateFormat formatter = DateFormat('EEEE dd-MMM-yyyy');
    final String formatted = formatter.format(parsedDate);

    detailstest = OrderDetailsModel(
        status: orderDetails.status,
        createdTime: formatted,
        datetime:
            deliveryformattedtwo + ' ' + fromFormatted + '-' + toFormatted,
        orderid: orderDetails.entityId,
        noitem: orderDetails.items.length.toString(),
        price: orderDetails.baseSubtotalInclTax,
        inaam: calculateinamm.twoDecimal(),
        building: orderDetails.shippingAddress.street +
            ',' +
            orderDetails.shippingAddress.city +
            ',' +
            orderDetails.shippingAddress.region,
        name: orderDetails.shippingAddress.firstname,
        //+orderDetails[0].orders[ivalue].customerLastname,
        phone: orderDetails.shippingAddress.telephone,
        date: deliveryformatted,
        time: fromFormatted == '' ? '' : fromFormatted + ' - ' + toFormatted,
        shippingfee: orderDetails.baseShippingAmount,
        discount: orderDetails.couponCode,
        discountDisplay: orderDetails.discount_amount,
        total: orderDetails.baseGrandTotal,
        card: paymentInfo,
        note: orderDetails.customerNote,
        increment_id: orderDetails.increment_id,
        //shippingid: orderdetails.shippingAddressId,
        grandTotal: orderDetails.grandTotal,
        email: orderDetails.shippingAddress.email,
        customer_id: orderDetails.customerId,
        baseSubtotal: orderDetails.baseSubtotal,
        storeid: orderDetails.storeId,
        invoiceUrl: orderDetails.invoiceUrl ?? '',
        lat: orderDetails.latitute,
        long: orderDetails.longitude,
        storeCode: orderDetails.storeCode,
        websiteId: orderDetails.websiteId);
  }

  OrderDetails get currentOrder {
    return _currentOrder;
  }

  get editItems {
    return _currentOrder.items;
  }

  double get discountCoupon {
    try {
      double _discountAmount =
          double.parse(currentOrder?.discount_amount ?? "0.00");
      return _discountAmount;
    } catch (e) {
      return 0;
    }
  }

  double get taxDifference {
    var items = currentOrder?.items ?? [];
    if (items.isNotEmpty) {
      double taxDiff = 0;
      items.forEach((item) {
        taxDiff = taxDiff +
            (double.parse(item?.taxAmount ?? '0') -
                    double.parse(item?.finalTax ?? '0'))
                .abs();
      });
      print("taxDiff: ${double.parse(taxDiff.twoDecimal())}");
      return double.parse(taxDiff.twoDecimal());
    } else
      return 0;
  }

  void modifysuccesscreenvalues() {
    successcancel = false;
    errorcancel = false;
    errorcancelmessage = '';
  }

  double roundDouble(double value, int places) {
    double mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }

  //Get orderdetails
  Future<bool> myorderdetails(String orderid) async {
    detailstest = null;
    //returntomorrowTimeSlots.clear();
    //log(">>>>ORDER DETAILS");

    isreturnenabled = false;
    final customDetailsUrl =
        Uri.parse(MAGENTO_BASE_URL + "/V1" + "/customapi/orders/$orderid");
    logNesto('MY ORDER DETAILS URL' + customDetailsUrl.toString());
    final response = await http.get(
      customDetailsUrl,
      headers: <String, String>{"Authorization": 'Bearer ' + getAuthToken()},
    );
    logNesto('>>>>RESPONSE CODE:' + response.statusCode.toString());
    logNesto('>>>>RESPONSE:' + response.toString());
    if (response.statusCode == 200) {
      final orderDetails = orderDetailsFromJson(response.body);
      currentOrder = orderDetails;
      double calculateinamm =
          getInaamPoints(double.tryParse(orderDetails.baseSubtotal));

      var paymentInformation = orderDetails.payment.method;
      if (paymentInformation == 'cashondelivery')
        paymentInfo = strings.CASH_CARD_ON_DELIVERY;
      else
        paymentInfo = strings.CARD_PAYMENT;

      String deliveryformattedtwo = "";
      String deliveryformatted = "";
      from = "";
      to = "";
      String fromFormatted = '';
      String toFormatted = '';

      if (orderDetails.shippingAddress.deliveryHoursFrom != null) {
        from = (orderDetails.shippingAddress.deliveryHoursFrom +
            ':' +
            orderDetails.shippingAddress.deliveryMinutesFrom);

        to = (orderDetails.shippingAddress.deliveryHoursTo +
            ':' +
            orderDetails.shippingAddress.deliveryMinutesTo);
        delivery_day = (orderDetails.shippingAddress.deliveryDay);
        var parsedDeliveryDate = DateTime.parse(delivery_day);
        final DateFormat deliveryformatter = DateFormat('EEEE dd MMMM');
        final DateFormat deliveryformattertwo = DateFormat('dd EEE');
        deliveryformatted = deliveryformatter.format(parsedDeliveryDate);
        deliveryformattedtwo = deliveryformattertwo.format(parsedDeliveryDate);

        final DateFormat formatter = DateFormat('hh:mm a');
        DateTime deliveryFrom = new DateFormat("H:mm").parse(from);
        fromFormatted = formatter.format(deliveryFrom);
        DateTime deliveryTo = new DateFormat("H:mm").parse(to);
        toFormatted = formatter.format(deliveryTo);
      }

      var parsedDate = DateTime.parse(orderDetails.createdAt.toString());
      final DateFormat formatter = DateFormat('EEEE dd-MMM-yyyy');
      final String formatted = formatter.format(parsedDate);

      detailstest = OrderDetailsModel(
          status: orderDetails.status,
          createdTime: formatted,
          datetime:
              deliveryformattedtwo + ' ' + fromFormatted + '-' + toFormatted,
          orderid: orderDetails.entityId,
          noitem: orderDetails.items.length.toString(),
          price: orderDetails.baseSubtotalInclTax,
          inaam: calculateinamm.twoDecimal(),
          building: orderDetails.shippingAddress.street +
              ',' +
              orderDetails.shippingAddress.city +
              ',' +
              orderDetails.shippingAddress.region,
          name: orderDetails.shippingAddress.firstname,
          //+orderDetails[0].orders[ivalue].customerLastname,
          phone: orderDetails.shippingAddress.telephone,
          date: deliveryformatted,
          time: fromFormatted == '' ? '' : fromFormatted + ' - ' + toFormatted,
          shippingfee: orderDetails.baseShippingAmount,
          discount: orderDetails.couponCode,
          discountDisplay: orderDetails.discount_amount,
          total: orderDetails.baseGrandTotal,
          card: paymentInfo,
          note: orderDetails.customerNote,
          increment_id: orderDetails.increment_id,
          //shippingid: orderdetails.shippingAddressId,
          grandTotal: orderDetails.grandTotal,
          email: orderDetails.shippingAddress.email,
          customer_id: orderDetails.customerId,
          baseSubtotal: orderDetails.baseSubtotal,
          storeid: orderDetails.storeId,
          invoiceUrl: orderDetails.invoiceUrl ?? '',
          lat: orderDetails.latitute,
          long: orderDetails.longitude,
          storeCode: orderDetails.storeCode,
          websiteId: orderDetails.websiteId);

      var now = DateTime.now();

      var difference = now.difference(parsedDate).inDays;
      if (difference > 7 && detailstest.status == 'delivered') {
        isreturnenabled = true;
      }
      //logNesto("date difference" + difference.toString());
      //Fetch items here

      unediteditemstest.clear();
      if (orderDetails.items.length != 0) {
        //logNesto(">>>>Items Length " + orderDetails.items.length.toString());
        for (int i = 0; i < orderDetails.items.length; i++) {
          double qty = double.tryParse(orderDetails.items[i].qtyOrdered);
          var qtintoprice = roundDouble(
              qty.toInt() * double.tryParse(orderDetails.items[i].basePrice),
              2);
          //ogNesto("Subtotel >>>>  " + qtintoprice.toString());
          var discountamt = roundDouble(
              qtintoprice *
                  (double.tryParse(orderDetails.items[i].discountPercent)
                          .toInt() /
                      100),
              2);

          double itemTax = roundDouble(
              (qtintoprice) *
                  (double.tryParse(orderDetails.items[i].taxPercent) / 100),
              2);
          qtintoprice = qtintoprice - discountamt;
          double discountedItemTax = roundDouble(
              (qtintoprice) *
                  (double.tryParse(orderDetails.items[i].taxPercent) / 100),
              2);

          //subtotel is not iclusive of tax
          unediteditemstest.add(
            EditItemsModel(
                itemid: orderDetails.items[i].itemId,
                count: qty.toInt(),
                baseprice: orderDetails.items[i].basePrice,
                itemname: orderDetails.items[i].name,
                price: orderDetails.items[i].basePriceInclTax,
                taxPercentage: orderDetails.items[i].taxPercent,
                subTotel: roundDouble(
                        qty.toInt() *
                            double.tryParse(orderDetails.items[i].basePrice),
                        2)
                    .toString(),
                taxCalculatedPrice: roundDouble(
                        ((qty.toInt() *
                                double.tryParse(
                                    orderDetails.items[i].basePrice)) +
                            discountedItemTax -
                            discountamt),
                        2)
                    .toString(),
                taxCalculatedWithOutDiscount: roundDouble(
                        ((qty.toInt() *
                                double.tryParse(
                                    orderDetails.items[i].basePrice)) +
                            itemTax),
                        2)
                    .toString(),
                img: PRODUCT_IMAGE_BASE_URL + orderDetails.items[i].itemImage,
                tax: discountedItemTax.toString(),
                shipping: detailstest.shippingfee,
                coupon: detailstest.shippingfee,
                sku: orderDetails.items[i].sku,
                product_type: orderDetails.items[i].productType,
                product_id: orderDetails.items[i].productId,
                shelf_sort_number: orderDetails.items[i].shelfSortNumber,
                shelf_number: orderDetails.items[i].shelfSortNumber,
                quote_item_id: orderDetails.items[i].quoteItemId,
                discountPercentage: orderDetails.items[i].discountPercent,
                rowTotel: orderDetails.items[i].rowTotalInclTax),
          );
        }
      }
    } else {
      detailstest = null;
      throw Exception('Failed to load album');
    }
  }

  getBuild() async {
    var buildValues = await PackageInfo.fromPlatform();
    buildNumber = buildValues.buildNumber;
    versionNumber = buildValues.version;
    logNesto('versionNumber' + buildValues.version);
    logNesto("buildNumber" + buildNumber.toString());
  }

  //Listing of orders ongoing and completed
  Future myorders() async {
    //log(">>>>My Orders");
    getBuild();
    logNesto(">>>>AUTH TOKEN(Orders Provider) :" + getAuthToken());
    orderlisttest.clear();
    orderlistofcompletedtest.clear();
    var url =
        Uri.parse(MAGENTO_BASE_URL + "/$storeCode/V1/orderlist?allstore=true");
    Map<String, String> headers = {
      "content-type": "application/json",
      "Authorization": 'Bearer ' + getAuthToken()
    };
    // Dev.log("URL: $url", name: "my_orders");
    // Dev.log("HEADER: $headers", name: "my_orders");
    logNestoCustom(message: "URL: $url", logType: LogType.debug);
    logNestoCustom(message: "HEADER: $headers", logType: LogType.debug);

    final response = await http.post(
      url,
      headers: headers,
      encoding: Encoding.getByName("utf-8"),
    );

    //logNesto(response.body);
    logNesto(">>>>RESPONSE CODE" + response.statusCode.toString());
    // logNesto(posts);
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.

      final orderList = orderListFromJson(response.body);

      for (int i = 0; i < orderList[0].orders.length; i++) {
        //TODO::Filter ongoing orders here
        var parsedDate =
            DateTime.parse(orderList[0].orders[i].createdAt.toString());
        final DateFormat formatter = DateFormat('EEEE dd-MMM-yyyy');
        final String formatted = formatter.format(parsedDate);
        //orderList[0].orders[i].status = 'delivered';
        if (orderList[0].orders[i].status == 'pending') {
          orderlisttest.add(
            OrderListModel(
              strings.ACTIVE_ORDERS,
              orderList[0].orders[i].shippingAddressId,
              orderList[0].orders[i].incrementId,
              formatted,
              orderList[0].orders[i].entityId,
              orderList[0].orders[i].items.length.toString(),
              orderList[0].orders[i].baseGrandTotal,
              strings.ORDER_IS_PENDING,
              orderList[0].orders[i].createdAt,
              orderList[0].orders[i].updatedAt,
            ),
          );
        } else if (orderList[0].orders[i].status == 'payment_review') {
          orderlisttest.add(
            OrderListModel(
              strings.ACTIVE_ORDERS,
              orderList[0].orders[i].shippingAddressId,
              orderList[0].orders[i].incrementId,
              formatted,
              orderList[0].orders[i].entityId,
              orderList[0].orders[i].items.length.toString(),
              orderList[0].orders[i].baseGrandTotal,
              strings.PAYMENT_REVIEW,
              orderList[0].orders[i].createdAt,
              orderList[0].orders[i].updatedAt,
            ),
          );
        } else if (orderList[0].orders[i].status == 'processing') {
          orderlisttest.add(
            OrderListModel(
              strings.ACTIVE_ORDERS,
              orderList[0].orders[i].shippingAddressId,
              orderList[0].orders[i].incrementId,
              formatted,
              orderList[0].orders[i].entityId,
              orderList[0].orders[i].items.length.toString(),
              orderList[0].orders[i].baseGrandTotal,
              strings.ORDER_IS_PROCESSING,
              orderList[0].orders[i].createdAt,
              orderList[0].orders[i].updatedAt,
            ),
          );
        } else if (orderList[0].orders[i].status == 'picking_initiated') {
          orderlisttest.add(
            OrderListModel(
              strings.ACTIVE_ORDERS,
              orderList[0].orders[i].shippingAddressId,
              orderList[0].orders[i].incrementId,
              formatted,
              orderList[0].orders[i].entityId,
              orderList[0].orders[i].items.length.toString(),
              orderList[0].orders[i].baseGrandTotal,
              strings.ORDER_GETTING_PICKED,
              orderList[0].orders[i].createdAt,
              orderList[0].orders[i].updatedAt,
            ),
          );
        } else if (orderList[0].orders[i].status == 'payment_failed') {
          orderlisttest.add(
            OrderListModel(
              strings.RETRY_PAYMENT,
              orderList[0].orders[i].shippingAddressId,
              orderList[0].orders[i].incrementId,
              formatted,
              orderList[0].orders[i].entityId,
              orderList[0].orders[i].items.length.toString(),
              orderList[0].orders[i].baseGrandTotal,
              strings.PAYMENT_FAILED,
              orderList[0].orders[i].createdAt,
              orderList[0].orders[i].updatedAt,
            ),
          );
        } else if (orderList[0].orders[i].status == 'holded') {
          orderlisttest.add(
            OrderListModel(
              strings.SELECT_SUBSTITUTE,
              orderList[0].orders[i].shippingAddressId,
              orderList[0].orders[i].incrementId,
              formatted,
              orderList[0].orders[i].entityId,
              orderList[0].orders[i].items.length.toString(),
              orderList[0].orders[i].baseGrandTotal,
              strings.ORDER_WAITING_FOR_SUBSTITUTES,
              orderList[0].orders[i].createdAt,
              orderList[0].orders[i].updatedAt,
            ),
          );
        } else if (orderList[0].orders[i].status == 'packing_initiated' ||
            orderList[0].orders[i].status == 'picking_completed') {
          orderlisttest.add(
            OrderListModel(
              strings.ACTIVE_ORDERS,
              orderList[0].orders[i].shippingAddressId,
              orderList[0].orders[i].incrementId,
              formatted,
              orderList[0].orders[i].entityId,
              orderList[0].orders[i].items.length.toString(),
              orderList[0].orders[i].baseGrandTotal,
              strings.ORDER_IS_GETTING_PACKED,
              orderList[0].orders[i].createdAt,
              orderList[0].orders[i].updatedAt,
            ),
          );
        } else if (orderList[0]
                .orders[i]
                .status
                .contains('ready_for_delivery') ||
            orderList[0].orders[i].status == 'packing_completed') {
          orderlisttest.add(
            OrderListModel(
              strings.ACTIVE_ORDERS,
              orderList[0].orders[i].shippingAddressId,
              orderList[0].orders[i].incrementId,
              formatted,
              orderList[0].orders[i].entityId,
              orderList[0].orders[i].items.length.toString(),
              orderList[0].orders[i].baseGrandTotal,
              strings.ORDER_PACKED,
              orderList[0].orders[i].createdAt,
              orderList[0].orders[i].updatedAt,
            ),
          );
        } else if (orderList[0].orders[i].status.contains('out_for_delivery')) {
          orderlisttest.add(
            OrderListModel(
              strings.ACTIVE_ORDERS,
              orderList[0].orders[i].shippingAddressId,
              orderList[0].orders[i].incrementId,
              formatted,
              orderList[0].orders[i].entityId,
              orderList[0].orders[i].items.length.toString(),
              orderList[0].orders[i].baseGrandTotal,
              strings.ON_THE_WAY,
              orderList[0].orders[i].createdAt,
              orderList[0].orders[i].updatedAt,
            ),
          );
        } else if (orderList[0]
            .orders[i]
            .status
            .contains('vehicle_breakdown')) {
          orderlisttest.add(
            OrderListModel(
              strings.ACTIVE_ORDERS,
              orderList[0].orders[i].shippingAddressId,
              orderList[0].orders[i].incrementId,
              formatted,
              orderList[0].orders[i].entityId,
              orderList[0].orders[i].items.length.toString(),
              orderList[0].orders[i].baseGrandTotal,
              strings.VEHICLE_BREAKDOWN,
              orderList[0].orders[i].createdAt,
              orderList[0].orders[i].updatedAt,
            ),
          );
        } else if (orderList[0].orders[i].status == 'cancelled' ||
            orderList[0].orders[i].status == 'canceled') {
          orderlistofcompletedtest.add(
            CompletedOrderListModel(
              status: orderList[0].orders[i].status,
              datetime: formatted,
              orderid: orderList[0].orders[i].entityId,
              noitem: orderList[0].orders[i].items.length.toString(),
              price: orderList[0].orders[i].baseGrandTotal,
              title: strings.ORDER_CANCELLED,
              shoppingid: orderList[0].orders[i].shippingAddressId,
              increment_id: orderList[0].orders[i].incrementId,
              createdAt: orderList[0].orders[i].createdAt,
              updatedAt: orderList[0].orders[i].updatedAt,
            ),
          );
        } else if (orderList[0].orders[i].status == 'delivered') {
          orderlistofcompletedtest.add(
            CompletedOrderListModel(
              status: orderList[0].orders[i].status,
              datetime: formatted,
              orderid: orderList[0].orders[i].entityId,
              noitem: orderList[0].orders[i].items.length.toString(),
              price: orderList[0].orders[i].baseGrandTotal,
              title: strings.ORDER_DELIVERED,
              shoppingid: orderList[0].orders[i].shippingAddressId,
              increment_id: orderList[0].orders[i].incrementId,
              createdAt: orderList[0].orders[i].createdAt,
              updatedAt: orderList[0].orders[i].updatedAt,
            ),
          );
        } else if (orderList[0].orders[i].status == 'return_initiated') {
          orderlistofcompletedtest.add(
            CompletedOrderListModel(
              status: orderList[0].orders[i].status,
              datetime: formatted,
              orderid: orderList[0].orders[i].entityId,
              noitem: orderList[0].orders[i].items.length.toString(),
              price: orderList[0].orders[i].baseGrandTotal,
              title: strings.RETURN_INITIATED,
              shoppingid: orderList[0].orders[i].shippingAddressId,
              increment_id: orderList[0].orders[i].incrementId,
              createdAt: orderList[0].orders[i].createdAt,
              updatedAt: orderList[0].orders[i].updatedAt,
            ),
          );
        } else if (orderList[0].orders[i].status == 'returned') {
          orderlistofcompletedtest.add(
            CompletedOrderListModel(
              status: orderList[0].orders[i].status,
              datetime: formatted,
              orderid: orderList[0].orders[i].entityId,
              noitem: orderList[0].orders[i].items.length.toString(),
              price: orderList[0].orders[i].baseGrandTotal,
              title: strings.ORDER_RETURNED,
              shoppingid: orderList[0].orders[i].shippingAddressId,
              increment_id: orderList[0].orders[i].incrementId,
              createdAt: orderList[0].orders[i].createdAt,
              updatedAt: orderList[0].orders[i].updatedAt,
            ),
          );
        } else if (orderList[0].orders[i].status == 'return_collected') {
          orderlistofcompletedtest.add(
            CompletedOrderListModel(
              status: orderList[0].orders[i].status,
              datetime: formatted,
              orderid: orderList[0].orders[i].entityId,
              noitem: orderList[0].orders[i].items.length.toString(),
              price: orderList[0].orders[i].baseGrandTotal,
              title: strings.RETURN_COLLECTED,
              shoppingid: orderList[0].orders[i].shippingAddressId,
              increment_id: orderList[0].orders[i].incrementId,
              createdAt: orderList[0].orders[i].createdAt,
              updatedAt: orderList[0].orders[i].updatedAt,
            ),
          );
        } else if (orderList[0].orders[i].status == 'closed') {
          logNesto(orderList[0].orders[i].status);
          orderlistofcompletedtest.add(
            CompletedOrderListModel(
              status: orderList[0].orders[i].status,
              datetime: formatted,
              orderid: orderList[0].orders[i].entityId,
              noitem: orderList[0].orders[i].items.length.toString(),
              price: orderList[0].orders[i].baseGrandTotal,
              title: strings.CLOSED,
              shoppingid: orderList[0].orders[i].shippingAddressId,
              increment_id: orderList[0].orders[i].incrementId,
              createdAt: orderList[0].orders[i].createdAt,
              updatedAt: orderList[0].orders[i].updatedAt,
            ),
          );
        } else if (orderList[0].orders[i].status == 'return_cancelled') {
          logNesto(orderList[0].orders[i].status);
          orderlistofcompletedtest.add(
            CompletedOrderListModel(
              status: orderList[0].orders[i].status,
              datetime: formatted,
              orderid: orderList[0].orders[i].entityId,
              noitem: orderList[0].orders[i].items.length.toString(),
              price: orderList[0].orders[i].baseGrandTotal,
              title: strings.RETURN_CANCELLED,
              shoppingid: orderList[0].orders[i].shippingAddressId,
              increment_id: orderList[0].orders[i].incrementId,
              createdAt: orderList[0].orders[i].createdAt,
              updatedAt: orderList[0].orders[i].updatedAt,
            ),
          );
        }
      }
      final ongoinglistids = orderlisttest.map((e) => e.orderid).toSet();
      orderlisttest.retainWhere((x) => ongoinglistids.remove(x.orderid));
      final completedlistids =
          orderlistofcompletedtest.map((e) => e.orderid).toSet();
      orderlistofcompletedtest
          .retainWhere((x) => completedlistids.remove(x.orderid));
      return orderListFromJson(response.body);
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      //Dev.log("response: ${response?.body}", name: "my_orders");
      logNestoCustom(
          message: "response: ${response?.body}", logType: LogType.debug);
      throw Exception('Failed to load album');
    }
  }

  Future shippingEstimation(String orderid) async {
    minSubTotal = '0';
    shippingCharges = '0';
    couponMinAmount = '0';
    var url = Uri.parse(MAGENTO_BASE_URL +
        "/V1/shippingDetails?websiteId=" +
        detailstest.websiteId +
        "&orderId=" +
        detailstest.increment_id);
    Map<String, String> headers = {
      "content-type": "application/json",
      "Authorization": 'Bearer ' + getAuthToken()
    };
    logNesto("shippingEstimation URL: $url");
    logNesto("shippingEstimation HEADER: " + headers.toString());

    final response = await http.get(url, headers: headers);
    logNesto("shippingEstimation BODY: " + response.body);

    logNesto(">>>>shippingEstimation RESPONSE CODE" +
        response.statusCode.toString());
    if (response.statusCode == 200) {
      var estimationResponse = convert.jsonDecode(response.body);
      final shippingEstimation = shippingEstimationFromJson(estimationResponse);
      logNesto(">>>>hey");
      minSubTotal = shippingEstimation.minSubTotal;
      shippingCharges = shippingEstimation.shippingCharges;
      couponMinAmount = shippingEstimation.couponMinAmount;
      couponType = shippingEstimation.couponType;
      couponApplied = shippingEstimation.couponApplied;
      editOrderMinSubTotal = shippingEstimation.editOrderMinSubTotal;
      shippingChargeLimit = shippingEstimation?.shippingChargeLimit ?? '0';
      //editorders(orderid, minSubTotal, shippingCharges, couponMinAmount);
      notifyListeners();
    } else {
      logNesto(">>>>Estimation API failed");
    }

    // If the server did return a 201 CREATED respons
  }

  //Cancel

  Future CancelOrder(String orderid, String cancelreason, String customerid,
      String incrementalid) async {
    if (cancelreason == '' || cancelreason == null) {
      notificationServices.showInformationNotification(
          'Please enter the reason for cancelling');
      errorcancel = true;
      // errorcancelmessage = 'Please enter the reason for cancelling';
      notifyListeners();
    } else {
      var queryParams = await getQueryParams() ?? "";

      final cancelurl = Uri.parse(LAMBDA_ORDER_URL + "/cancel" + queryParams);

      logNesto("URL:" + cancelurl.toString());

      final header = {
        "content-type": "application/json",
        "access-token": getLambdaToken()
      };

      logNesto("HEADER:" + header.toString());

      final body = jsonEncode({
        "sales_order_id": orderid,
        "order_kind": "cancel",
        "cancel_reason": cancelreason,
        "customer_id": customerid,
        "incremental_id": incrementalid,
        "cancellation_type": "full"
      });

      logNesto("BODY:" + body);

      return http.post(cancelurl, headers: header, body: body).then((response) {
        logNesto('cancel response code ' + response.statusCode.toString());
        logNesto("RESPONSE:" + response.body.toString());

        var decodedResponse = json.decode(response.body);

        if (response.statusCode == 200) {
          logNesto(response.body);
          successcancel = true;
          notifyListeners();

          //firebase analytics logging.
          firebaseAnalytics.cancelOrder(
            orderID: orderid,
            incrementalID: incrementalid,
          );
        } else {
          errorcancel = true;
          notificationServices
              .showInformationNotification(decodedResponse["message"]);
          logNesto('cancel message:' + errorcancelmessage);
          notifyListeners();
        }
      });
    }
  }

  Future updateDeliveryRating(
      String orderId, int customerId, int deliveryRating) async {
    if (!isAuthTokenValid()) {
      fetchAuthToken();
    }
    final body = jsonEncode({
      "sales_order_id": orderId,
      "customer_id": customerId,
      "delivery_rating": deliveryRating,
    });
    final header = {"content-type": "application/json"};
    final url = Uri.parse(LAMBDA_BASE_URL + "/delivery/rating");
    logNesto(url);
    try {
      http.Response response = await http.post(Uri.parse(url.toString()),
          headers: header, body: body);
      if (response.statusCode != 200) {
        final decodedResponse = json.decode(response.body);
        throw decodedResponse["message"];
      }
    } catch (error) {
      logNesto(error);
    }
  }
}
