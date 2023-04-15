import 'dart:convert';
import 'dart:developer';

import 'package:Nesto/providers/substitution_provider.dart';
import 'package:Nesto/screens/category_items_page.dart';
import 'package:Nesto/screens/order_listing_screen.dart';
import 'package:Nesto/screens/product_details.dart';
import 'package:Nesto/screens/product_listing_screen.dart';
import 'package:Nesto/service_locator.dart';
import 'package:Nesto/services/navigation_service.dart';
import 'package:Nesto/utils/util.dart';
import 'package:Nesto/widgets/show_previous_order_modal.dart';
import 'package:Nesto/widgets/substitution_start_modal.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

final FirebaseCloudMessaging firebaseCloudMessaging =
    locator.get<FirebaseCloudMessaging>();

class FirebaseCloudMessaging {
  final NavigationService _navigation = locator.get<NavigationService>();
  final _firebaseMessaging = FirebaseMessaging.instance;

  String _fcmToken = "";

  get fcmToken {
    return _fcmToken;
  }

  set fcmToken(value) {
    _fcmToken = value;
  }

  getToken() async {
    fcmToken = await _firebaseMessaging.getToken();
  }

  requestPermissions() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  initializeService() async {
    await requestPermissions();
    await getToken();
    handlePushNotifications();
  }

  Future handlePushNotifications() async {
    print("calling handlePushNotitfications");

    String lastMessageId = "";
    String lastBackgroundId = "";
    String lastinitialMessageId = "";

    RemoteMessage initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage?.data != null) {
      print("calling initial message");

      var action = initialMessage?.data['action'];
      var value = initialMessage?.data["value"];
      var sku = initialMessage?.data["product_sku"];
      var catName = initialMessage?.data["category/offer_name"];
      var catId = initialMessage?.data["category_id"];
      String initMessageId = initialMessage?.messageId;

      if (initMessageId == lastinitialMessageId) {
        return;
      }

      lastinitialMessageId = initMessageId;

      logNestoCustom(message: 'value: $value', logType: LogType.debug);
      logNestoCustom(message: "ACTION: $action", logType: LogType.debug);

      switch (action) {
        case 'substitution':
          performSubstitution(value);
          break;
        case 'order':
          pushToOrders(value);
          break;
        case 'order_update':
          pushToOrders(value);
          break;
        case 'launch_product':
          launchProduct(sku);
          break;
        case 'launch_category':
          launchCategory(catId, catName);
          break;
        case 'app_update':
          updateApp();
          break;
        default:
          navigateToWeb(value);
          break;
      }
    }
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("messageId foreground: ${message.messageId}");
      String messageId = message.messageId;
      if (lastMessageId != messageId) {
        lastMessageId = messageId;
        handleForegroundNotifications(message);
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      String messageId = message.messageId;
      if (lastBackgroundId != messageId) {
        lastBackgroundId = messageId;
        handleBackgroundNotification(message);
      }
    });
  }

  Future handleForegroundNotifications(RemoteMessage message) async {
    print("\n====================>");
    print("got a message in foreground");
    print("<====================\n");

    var data = message.data;
    var action = data["action"];
    var value = data["value"];

    logNestoCustom(message: "ACTION: $action", logType: LogType.debug);

    switch (action) {
      case 'substitution':
        performSubstitution(value);
        break;
      case 'rate_previous_order':
        showPreviousOrderRating(value, data["sales_incremental_id"]);
        break;
      case 'app_update':
        updateApp();
        break;
      default:
        navigateToWeb(value);
        break;
    }
  }

  Future handleBackgroundNotification(RemoteMessage message) async {
    print("\n====================>");
    print("got a message in background");
    print("<====================\n");

    logNestoCustom(
        message: 'Message data: ${message.data}', logType: LogType.debug);

    var data = message.data;
    var action = data["action"];
    var value = data["value"];
    var sku = data["product_sku"];
    var catName = data["category/offer_name"];
    var catId = data["category_id"];

    switch (action) {
      case 'order':
        pushToOrders(value);
        break;
      case 'order_update':
        pushToOrders(value);
        break;
      case 'substitution':
        performSubstitution(value);
        break;
      case 'rate_previous_order':
        showPreviousOrderRating(value, data["sales_incremental_id"]);
        break;
      case 'launch_product':
        launchProduct(sku);
        break;
      case 'launch_category':
        launchCategory(catId, catName);
        break;
      case 'app_update':
        updateApp();
        break;
      default:
        navigateToWeb(value);
        break;
    }
  }

  performSubstitution(value) async {
    var subProvider = Provider.of<SubstitutionProvider>(
        _navigation.navigatorKey.currentContext,
        listen: false);
    var orderId = jsonDecode(value)['order_id'];
    var cuttOffTime = jsonDecode(value)['cutoff_time'];
    var outOfStockItemID = jsonDecode(value)['item_id_lambda'];

    // check if time limit exceeded of substitution.
    var localTime = DateTime.parse(cuttOffTime).toLocal();
    int difference = localTime.difference(DateTime.now()).inMinutes;

    log("local time: $localTime");

    //if time exceeded show error and return.
    if (difference <= 0) {
      showError(_navigation.navigatorKey.currentContext,
          "Substitution time limit has exceeded");
      return;
    }

    subProvider.cuttOffTime = localTime;
    subProvider.outOfStockItemID = outOfStockItemID;

    try {
      await subProvider.getOrderSubstitute(orderId.toString());

      showSubstitutionStartModal(orderID: orderId);
    } catch (e) {
      print("ERROR: $e");
      if (e?.message != null) {
        log(e, name: "substitution");
        showError(_navigation.navigatorKey.currentContext, e?.message);
      } else {
        log(e, name: "substitution");
        showError(
            _navigation.navigatorKey.currentContext, "something went wrong!");
      }
    }
  }

  launchProduct(sku) async {
    if (sku != null && sku.isNotEmpty) {
      try {
        Navigator.push(
          _navigation.navigatorKey.currentContext,
          MaterialPageRoute(
            builder: (context) {
              return ProductDetail(
                sku: sku ?? "",
              );
            },
          ),
        );
      } catch (e) {
        logNestoCustom(message: e.toString(), logType: LogType.error);
      }
    }
  }

  launchCategory(catId, catName) async {
    // var provider = Provider.of<StoreProvider>(
    //     _navigation.navigatorKey.currentContext,
    //     listen: false);
    int categoryID = int.parse(catId);

    logNestoCustom(message: "ID: $catId", logType: LogType.debug);
    logNestoCustom(message: "name: $catName", logType: LogType.debug);

    bool isIDValid = catId != null && catId != "" ? true : false;
    bool isNameValid = catName != null && catName.isNotEmpty ? true : false;

    // if (isIDValid && isNameValid) {
    //   provider.selectedCategoryForViewMore = SubCategory(
    //     id: categoryID,
    //     name: catName,
    //     merchandiseCategories: [],
    //   );
    //   Navigator.pushNamed(
    //       _navigation.navigatorKey.currentContext, ViewMoreScreen.routeName);
    // }

    if (isIDValid && isNameValid) {
      try {
        Navigator.push(
          _navigation.navigatorKey.currentContext,
          MaterialPageRoute(
            builder: (context) {
              return CategoryItemsPage(categoryID: categoryID);

              // return ProductListingScreen(
              //   categoryID: categoryID,
              //   categoryTitle: catName ?? "",
              // );
            },
          ),
        );
      } catch (e) {
        logNestoCustom(message: e.toString(), logType: LogType.error);
      }
    }
  }

  pushToOrders(value) async {
    var orderId = jsonDecode(value)['order_id'];
    Navigator.push(
      _navigation.navigatorKey.currentContext,
      MaterialPageRoute(
        builder: (context) {
          return OrderListingScreen(
            orderid: orderId,
          );
        },
      ),
    );
  }

  navigateToWeb(value) async {
    logNestoCustom(message: "navigating to web", logType: LogType.debug);

    try {
      final url = Uri.encodeFull(value ?? "");
      await canLaunch(url)
          ? await launch(url)
          : throw 'Could not launch $value';
    } catch (e) {
      logNestoCustom(
          message: e?.message ?? 'something went wrong',
          logType: LogType.error);
    }
  }

  updateApp() {
    logNestoCustom(
        message: "navigate to playstore/appstore", logType: LogType.debug);

    openAppStoreOrPlaystore();
  }
}
