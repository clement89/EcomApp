import 'package:Nesto/service_locator.dart';
import 'package:Nesto/utils/util.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

import 'analytics_constants.dart';

final AnalyticsService firebaseAnalytics = locator.get<AnalyticsService>();

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics();

  FirebaseAnalyticsObserver getAnalyticsObserver() => FirebaseAnalyticsObserver(
      analytics: _analytics,
      onError: (e) {
        //log('FIREBASE ANALYTICS ERR $e', name: 'firebase_analytics');
        logNestoCustom(
            message: 'FIREBASE ANALYTICS ERR $e', logType: LogType.error);
      });

  void logUserProperty({String name, String value}) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
    } catch (e) {
      //log('FIREBASE ANALYTICS ERR $e', name: 'firebase_analytics');
      logNestoCustom(
          message: 'FIREBASE ANALYTICS ERR $e', logType: LogType.error);
    }
  }

  void logSignIn({String logInMethod}) async {
    Map<String, dynamic> parameters = {METHOD: logInMethod};
    logNestoCustom(message: "PARAM: $parameters", logType: LogType.debug);
    try {
      await _analytics.logEvent(
        name: LOG_IN,
        parameters: parameters,
      );
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void logSignInFailure({String logInMethod}) async {
    Map<String, dynamic> parameters = {METHOD: logInMethod};
    //log("PARAM: $parameters", name: 'analytics_service');
    logNestoCustom(message: "PARAM: $parameters", logType: LogType.debug);

    try {
      await _analytics.logEvent(
        name: "log_in_failure",
        parameters: parameters,
      );
    } catch (e) {
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void logOtpFailure({String logInMethod}) async {
    try {
      await _analytics.logEvent(
        name: "otp_failure",
      );
    } catch (e) {
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void logSignupFailure({String logInMethod}) async {
    try {
      await _analytics.logEvent(
        name: "signup_failure",
      );
    } catch (e) {
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void logRegister({String method, userId}) async {
    Map<String, dynamic> parameters = {METHOD: method, "user_id": userId};
    //log("PARAM: $parameters", name: 'analytics_service');
    logNestoCustom(message: "PARAM: $parameters", logType: LogType.debug);

    try {
      await _analytics.logEvent(
        name: REGISTER,
        parameters: parameters,
      );
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void logInitiateOtpVerification({String method}) async {
    try {
      await _analytics.logEvent(
        name: "init_otp_verification",
      );
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void logOtpVerificationSuccess() async {
    try {
      await _analytics.logEvent(
        name: "otp_verification_success",
      );
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void logAddToWishlist({
    String sku,
    double price,
    double value,
    String env,
    String currency,
    String itemName,
    String itemCategory,
    int quantity,
  }) async {
    try {
      await _analytics.logAddToWishlist(
        itemId: sku,
        itemName: itemName,
        itemCategory: itemCategory,
        price: price,
        value: value,
        currency: currency ?? "AED",
        quantity: quantity,
      );
    } catch (e) {
      //log('FIREBASE ANALYTICS ERR $e', name: 'firebase_analytics');
      logNestoCustom(
          message: 'FIREBASE ANALYTICS ERR $e', logType: LogType.error);
    }
  }

  void logAddToCart({
    String itemId,
    String itemName,
    String itemCategory,
    int quantity,
    double price,
    double value,
    String currency,
  }) async {
    Map<String, dynamic> parameters = {
      "ITEM_ID": itemId,
      "ITEM_NAME": itemName,
      "PRICE": price,
      "QUANTITY": quantity,
      VALUE: value,
      CURRENCY: "AED"
    };
    parameters.removeWhere(
        (String key, dynamic value) => value == null || key == null);
    logNestoCustom(
        message: "PARAMSCUSTOM: $parameters", logType: LogType.debug);
    try {
      await _analytics.logEvent(name: ADD_TO_CART, parameters: parameters);
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void logRemoveFromCart({
    String itemId,
    String itemName,
    String itemCategory,
    int quantity,
    double price,
    double value,
    String currency,
  }) async {
    Map<String, dynamic> parameters = {
      "ITEM_ID": itemId,
      "ITEM_NAME": itemName,
      "PRICE": price,
      "QUANTITY": quantity,
      VALUE: value,
      CURRENCY: "AED"
    };
    parameters.removeWhere(
        (String key, dynamic value) => value == null || key == null);
    logNestoCustom(
        message: "PARAMSCUSTOM: $parameters", logType: LogType.debug);
    try {
      await _analytics.logEvent(name: REMOVE_FROM_CART, parameters: parameters);
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void logPurchase({
    String paymentType,
    String currency,
    String location,
    String env,
    String cartToken,
    String deliveryTime,
    String deliveryDate,
    String storeID,
    String timeslotID,
    String transactionID,
    String affiliation,
    String value,
    String tax,
    String shipping,
    String cartID,
    String orderID,
    double grandTotal,
    double discount,
  }) async {
    Map<String, dynamic> parameters = {
      "TRANSACTION_ID": transactionID,
      "AFFILIATION": affiliation,
      "VALUE": value,
      "TAX": tax,
      "SHIPPING": shipping,
      "CART_ID": cartID,
      "ORDER_ID": orderID,
      PAYMENT_TYPE: paymentType,
      CURRENCY: currency,
      DISCOUNT: discount,
      LOCATION: location,
      "delivery_time": deliveryTime,
      "delivery_date": deliveryDate,
      "timeslot_id": timeslotID,
      "store_id": storeID,
    };
    parameters.removeWhere(
        (String key, dynamic value) => value == null || key == null);
    //log("PARAMS: $parameters", name: 'analytics_service');
    logNestoCustom(message: "PARAMS: $parameters", logType: LogType.debug);

    try {
      await _analytics.logEvent(name: PURCHASE, parameters: parameters);
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  logViewProduct(
      {String env,
      String currency,
      double price,
      String sku,
      String itemName,
      String itemCategory}) async {
    try {
      // print("view_item_called");
      await _analytics.logViewItem(
        itemId: sku,
        itemName: itemName,
        itemCategory: itemCategory,
        price: price,
      );
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void logViewProductList({
    String categoryID,
    String categoryName,
    String env,
  }) async {
    Map<String, dynamic> parameters = {
      ITEM_LIST_ID: categoryID,
      ITEM_LIST_NAME: categoryName,
      "env": env,
    };
    parameters.removeWhere(
        (String key, dynamic value) => value == null || key == null);
    //log("PARAMS: $parameters", name: 'analytics_service');
    logNestoCustom(message: "PARAMS: $parameters", logType: LogType.debug);

    try {
      await _analytics.logEvent(
        name: VIEW_ITEM_LIST,
        parameters: parameters,
      );
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void logBeginCheckout({
    double total,
    String currency,
    String env,
  }) async {
    Map<String, dynamic> parameters = {
      VALUE: total,
      CURRENCY: currency,
    };
    parameters.removeWhere(
        (String key, dynamic value) => value == null || key == null);
    //log("PARAMS: $parameters", name: 'analytics_service');
    logNestoCustom(message: "PARAMS: $parameters", logType: LogType.debug);

    try {
      _analytics.logEvent(name: BEGIN_CHECKOUT, parameters: parameters);
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void logShippingInfo({
    String location,
  }) async {
    Map<String, dynamic> parameters = {
      LOCATION: location,
    };
    parameters.removeWhere(
        (String key, dynamic value) => value == null || key == null);
    //log("PARAMS: $parameters", name: 'analytics_service');
    logNestoCustom(message: "PARAMS: $parameters", logType: LogType.debug);

    try {
      await _analytics.logEvent(
          name: ADD_SHIPPING_INFO, parameters: parameters);
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void logPaymentInfo(
      {String paymentType,
      String allowSubstitution,
      String address,
      double total,
      String currency,
      String deliveryTime}) async {
    Map<String, dynamic> parameters = {
      METHOD: paymentType,
      "allow_substitution": allowSubstitution,
      LOCATION: address,
      VALUE: total,
      CURRENCY: currency,
      "delivery_time": deliveryTime,
    };
    parameters.removeWhere(
        (String key, dynamic value) => value == null || key == null);
    //log("PARAMS: $parameters", name: 'analytics_service');
    logNestoCustom(message: "PARAMS: $parameters", logType: LogType.debug);

    try {
      await _analytics.logEvent(name: ADD_PAYMENT_INFO, parameters: parameters);
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void logSearch({String searchTerm}) async {
    Map<String, dynamic> parameters = {
      SEARCH_TERM: searchTerm,
    };
    parameters.removeWhere(
        (String key, dynamic value) => value == null || key == null);
    //log("PARAMS: $parameters", name: 'analytics_service');
    logNestoCustom(message: "PARAMS: $parameters", logType: LogType.debug);

    try {
      await _analytics.logEvent(name: SEARCH, parameters: parameters);
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void logSetUserProperties({
    String env,
    String id,
    String gender,
  }) async {
    try {
      await _analytics.setUserProperty(name: "env", value: env ?? 'none');
      await _analytics.setUserProperty(name: "id", value: id ?? 'none');
      await _analytics.setUserProperty(name: "gender", value: gender ?? 'none');
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void editOrderIncrease({
    String itemId,
    String sku,
    double price,
    String currency,
    String orderID,
    String incrementalID,
  }) async {
    Map<String, dynamic> parameters = {
      ITEM_ID: itemId,
      "sku": sku,
      VALUE: price,
      CURRENCY: currency,
      QUANTITY: 1,
      "order_id": orderID,
      "incremental_id": incrementalID,
    };
    parameters.removeWhere(
        (String key, dynamic value) => value == null || key == null);
    //log("PARAMS: $parameters", name: 'analytics_service');
    logNestoCustom(message: "PARAMS: $parameters", logType: LogType.debug);

    try {
      await _analytics.logEvent(
          name: "edit_order_increase", parameters: parameters);
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void editOrderDecrease({
    String itemId,
    String sku,
    double price,
    String currency,
    int quantity,
    String orderID,
    String incrementalID,
  }) async {
    Map<String, dynamic> parameters = {
      ITEM_ID: itemId,
      "sku": sku,
      VALUE: price,
      CURRENCY: currency,
      QUANTITY: quantity,
      "order_id": orderID,
      "incremental_id": incrementalID,
    };
    parameters.removeWhere(
        (String key, dynamic value) => value == null || key == null);
    //log("PARAMS: $parameters", name: 'analytics_service');
    logNestoCustom(message: "PARAMS: $parameters", logType: LogType.debug);

    try {
      await _analytics.logEvent(
          name: "edit_order_decrease", parameters: parameters);
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void logOrderSubstituted({
    String orderID,
    String itemID,
    String incrementalID,
  }) async {
    Map<String, dynamic> parameters = {
      "order_id": orderID,
      "incremental_id": incrementalID,
      ITEM_ID: itemID,
    };
    parameters.removeWhere(
        (String key, dynamic value) => value == null || key == null);
    //log("PARAMS: $parameters", name: 'analytics_service');
    logNestoCustom(message: "PARAMS: $parameters", logType: LogType.debug);

    try {
      await _analytics.logEvent(
          name: "substitute_order", parameters: parameters);
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void logPaymentSuccess() async {
    try {
      await _analytics.logEvent(name: "payment_success");
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void logPaymentFailure() async {
    try {
      await _analytics.logEvent(name: "payment_failure");
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void logPaymentCancel() async {
    try {
      await _analytics.logEvent(name: "payment_cancel");
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void logBackPressPaymentScreen() async {
    try {
      await _analytics.logEvent(name: "back_pressed_payment");
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void logCancelAlert() async {
    try {
      await _analytics.logEvent(name: "cancel_alert_yes");
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void logPaymentRetry() async {
    try {
      await _analytics.logEvent(name: "payment_retry");
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void logShopMore() async {
    try {
      await _analytics.logEvent(name: "shop_more");
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void logHomeScreenLoaded() async {
    try {
      await _analytics.logEvent(name: "home_screen_loaded");
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void logSelectPromotion(
      {String categoryID,
      String category,
      String sku,
      String productName,
      String creativeName,
      String promotionName,
      String promotionID,
      String locationID,
      String tileType,
      String creativeSlot}) async {
    Map<String, dynamic> parameters = {
      "PROMOTION_ID": promotionID,
      "PROMOTION_NAME": promotionName,
      "CREATIVE_SLOT": creativeSlot,
      "CREATIVE_NAME": creativeName,
      "LOCATION_ID": storeId,
    };
    parameters.removeWhere(
        (String key, dynamic value) => value == null || key == null);

    logNestoCustom(message: "PARAMS: $parameters", logType: LogType.debug);

    try {
      await _analytics.logEvent(name: SELECT_PROMOTION, parameters: parameters);
    } catch (e) {
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void logViewPromotion(
      {String promotionID,
      String promotionName,
      String creativeName,
      String creativeSlot,
      String locationID}) async {
    Map<String, dynamic> parameters = {
      "PROMOTION_ID": promotionID,
      "PROMOTION_NAME": promotionName,
      "CREATIVE_SLOT": creativeSlot,
      "CREATIVE_NAME": creativeName,
      "LOCATION_ID": storeId,
    };
    parameters.removeWhere(
        (String key, dynamic value) => value == null || key == null);
    logNestoCustom(
        message: "PARAMS CUSTOM: $parameters", logType: LogType.debug);
    try {
      await _analytics.logEvent(name: VIEW_PROMOTION, parameters: parameters);
    } catch (e) {
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void logSeeMoreClicked({
    String contentType,
    String itemListID,
    String itemListName,
  }) async {
    Map<String, dynamic> parameters = {
      CONTENT_TYPE: contentType,
      ITEM_LIST_ID: itemListID,
      ITEM_LIST_NAME: itemListName,
    };
    parameters.removeWhere(
        (String key, dynamic value) => value == null || key == null);
    //log("PARAMS: $parameters", name: 'analytics_service');
    logNestoCustom(message: "PARAMS: $parameters", logType: LogType.debug);

    try {
      _analytics.logEvent(name: "see_more_clicked", parameters: parameters);
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void logSearchClicked() async {
    try {
      await _analytics.logEvent(name: "search_clicked");
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void logHomeScreenLocationClicked() async {
    try {
      await _analytics.logEvent(name: "home_screen_location_clicked");
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void logCategoryScreenLoaded() async {
    try {
      await _analytics.logEvent(name: "category_screen_loaded");
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void logCategoryExpanded({
    String categoryName,
    String categoryID,
  }) async {
    Map<String, dynamic> parameters = {
      "category_name": categoryName,
      CATEGORY_ID: categoryID,
    };
    parameters.removeWhere(
        (String key, dynamic value) => value == null || key == null);
    //log("PARAMS: $parameters", name: 'analytics_service');
    logNestoCustom(message: "PARAMS: $parameters", logType: LogType.debug);

    try {
      await _analytics.logEvent(
          name: "category_expanded", parameters: parameters);
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void logCategoryItemClicked({
    String categoryName,
    String categoryID,
  }) async {
    Map<String, dynamic> parameters = {
      "category_name": categoryName,
      CATEGORY_ID: categoryID,
    };
    parameters.removeWhere(
        (String key, dynamic value) => value == null || key == null);
    //log("PARAMS: $parameters", name: 'analytics_service');
    logNestoCustom(message: "PARAMS: $parameters", logType: LogType.debug);

    try {
      await _analytics.logEvent(
          name: "category_item_clicked", parameters: parameters);
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void logProductScreenLoaded({String sku}) async {
    Map<String, dynamic> parameters = {
      "sku": sku,
    };
    parameters.removeWhere(
        (String key, dynamic value) => value == null || key == null);
    //log("PARAMS: $parameters", name: 'analytics_service');
    logNestoCustom(message: "PARAMS: $parameters", logType: LogType.debug);

    try {
      await _analytics.logEvent(
          name: "product_screen_loaded", parameters: parameters);
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void logContactUs() async {
    try {
      await _analytics.logEvent(name: "contact_us");
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void onboardingScreenLoaded({int pagePosition}) async {
    Map<String, dynamic> parameters = {
      INDEX: pagePosition + 1,
    };
    parameters.removeWhere(
        (String key, dynamic value) => value == null || key == null);
    //log("PARAMS: $parameters", name: 'analytics_service');
    logNestoCustom(message: "PARAMS: $parameters", logType: LogType.debug);

    try {
      await _analytics.logEvent(
          name: "onboarding_screen_loaded", parameters: parameters);
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void onboardingNextClicked({int pagePosition}) async {
    Map<String, dynamic> parameters = {
      INDEX: pagePosition + 1,
    };
    parameters.removeWhere(
        (String key, dynamic value) => value == null || key == null);
    //log("PARAMS: $parameters", name: 'analytics_service');
    logNestoCustom(message: "PARAMS: $parameters", logType: LogType.debug);

    try {
      await _analytics.logEvent(
          name: "onboarding_next_clicked", parameters: parameters);
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void onboardingSkipClicked({int pagePosition}) async {
    Map<String, dynamic> parameters = {
      INDEX: pagePosition + 1,
    };
    parameters.removeWhere(
        (String key, dynamic value) => value == null || key == null);
    //log("PARAMS: $parameters", name: 'analytics_service');
    logNestoCustom(message: "PARAMS: $parameters", logType: LogType.debug);

    try {
      await _analytics.logEvent(
          name: "onboarding_skipped", parameters: parameters);
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void startShopping() async {
    try {
      await _analytics.logEvent(name: "start_shopping");
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void locationScreenLoaded() async {
    try {
      await _analytics.logEvent(name: "location_screen_loaded");
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void locationConfirmed() async {
    try {
      await _analytics.logEvent(name: "location_confirmed");
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void homeScreenNotificationClicked() async {
    try {
      await _analytics.logEvent(name: "homescreen_notification_clicked");
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void homeScreenLocationClicked() async {
    try {
      await _analytics.logEvent(name: "homescreen_location_clicked");
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void notificationClicked(
      {String action, String orderID, String incrementalID}) async {
    Map<String, dynamic> parameters = {
      "action": action,
      "order_id": orderID,
      "incremental_id": incrementalID,
    };
    parameters.removeWhere(
        (String key, dynamic value) => value == null || key == null);
    //log("PARAMS: $parameters", name: 'analytics_service');
    logNestoCustom(message: "PARAMS: $parameters", logType: LogType.debug);

    try {
      await _analytics.logEvent(
          name: "notification_clicked", parameters: parameters);
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void categoryCartPress() async {
    try {
      await _analytics.logEvent(name: "category_listing_cart_press");
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void cartScreenLoaded() async {
    try {
      await _analytics.logEvent(name: "cart_screen_loaded");
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void rateOrder({String orderID, String rating}) async {
    Map<String, dynamic> parameters = {
      "order_id": orderID,
      "rating": rating,
    };
    parameters.removeWhere(
        (String key, dynamic value) => value == null || key == null);
    //log("PARAMS: $parameters", name: 'analytics_service');
    logNestoCustom(message: "PARAMS: $parameters", logType: LogType.debug);

    try {
      await _analytics.logEvent(name: "rate_order", parameters: parameters);
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void viewInaamPoints() async {
    try {
      await _analytics.logEvent(name: "view_inaam_points");
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void logout() async {
    try {
      await _analytics.logEvent(name: "logout");
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void cancelOrder({
    String orderID,
    String incrementalID,
  }) async {
    Map<String, dynamic> parameters = {
      "order_id": orderID,
      "incremental_id": incrementalID,
    };
    parameters.removeWhere(
        (String key, dynamic value) => value == null || key == null);
    //log("PARAMS: $parameters", name: 'analytics_service');
    logNestoCustom(message: "PARAMS: $parameters", logType: LogType.debug);

    try {
      await _analytics.logEvent(name: "cancel_order", parameters: parameters);
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void viewItems({
    String orderID,
    String incrementalID,
  }) async {
    Map<String, dynamic> parameters = {
      "order_id": orderID,
      "incremental_id": incrementalID,
    };
    parameters.removeWhere(
        (String key, dynamic value) => value == null || key == null);
    //log("PARAMS: $parameters", name: 'analytics_service');
    logNestoCustom(message: "PARAMS: $parameters", logType: LogType.debug);

    try {
      await _analytics.logEvent(name: "view_items", parameters: parameters);
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void ratePreviousDelivery(
      {String orderID, String incrementalID, String rating}) async {
    Map<String, dynamic> parameters = {
      "order_id": orderID,
      "incremental_id": incrementalID,
      "rating": rating,
    };
    parameters.removeWhere(
        (String key, dynamic value) => value == null || key == null);
    //log("PARAMS: $parameters", name: 'analytics_service');
    logNestoCustom(message: "PARAMS: $parameters", logType: LogType.debug);

    try {
      await _analytics.logEvent(
          name: "rate_previous_delivery", parameters: parameters);
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void referAFriend() async {
    try {
      await _analytics.logEvent(name: "refer_a_friend");
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void privacyPolicy() async {
    try {
      await _analytics.logEvent(name: "privacy_policy_pressed");
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void termsAndConditions() async {
    try {
      await _analytics.logEvent(name: "terms_and_conditions_pressed");
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: 'ERR: $e', logType: LogType.error);
    }
  }

  void aboutNesto() async {
    try {
      await _analytics.logEvent(name: "about_nesto_pressed");
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: "ERR: $e", logType: LogType.error);
    }
  }

  void screenView({String screenName}) async {
    Map<String, dynamic> parameters = {
      "custom_screen_name": screenName,
    };
    parameters.removeWhere(
        (String key, dynamic value) => value == null || key == null);
    try {
      await _analytics.logEvent(
          name: "custom_screen_view", parameters: parameters);
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: "ERR: $e", logType: LogType.error);
    }
  }

  void logInstall(
      {String campaign, String source, String medium, String content}) async {
    Map<String, dynamic> parameters = {
      CAMPAIGN: campaign,
      SOURCE: source,
      MEDIUM: medium,
      CONTENT: content
    };
    parameters.removeWhere(
        (String key, dynamic value) => value == null || key == null);
    try {
      await _analytics.logEvent(
          name: "custom_app_install", parameters: parameters);
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: "ERR: $e", logType: LogType.error);
    }
  }

  void logSessionStart(
      {String campaign, String source, String medium, String content}) async {
    Map<String, dynamic> parameters = {
      CAMPAIGN: campaign,
      SOURCE: source,
      MEDIUM: medium,
      CONTENT: content
    };
    parameters.removeWhere(
        (String key, dynamic value) => value == null || key == null);
    try {
      await _analytics.logEvent(
          name: "custom_session_start", parameters: parameters);
    } catch (e) {
      //log("ERR: $e", name: 'analytics_service');
      logNestoCustom(message: "ERR: $e", logType: LogType.error);
    }
  }
}
