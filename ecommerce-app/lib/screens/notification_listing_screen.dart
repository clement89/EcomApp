import 'dart:async';
import 'dart:developer';

import 'package:Nesto/models/notifications_response.dart';
import 'package:Nesto/providers/auth_provider.dart';
import 'package:Nesto/providers/notification_provider.dart';
import 'package:Nesto/providers/substitution_provider.dart';
import 'package:Nesto/screens/category_items_page.dart';
import 'package:Nesto/screens/order_listing_screen.dart';
import 'package:Nesto/screens/product_details.dart';
import 'package:Nesto/screens/product_listing_screen.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/utils/util.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/widgets/connectivity_widget.dart';
import 'package:Nesto/widgets/headers.dart';
import 'package:Nesto/widgets/no_notification_widget.dart';
import 'package:Nesto/widgets/notification_screen_description_widget.dart';
import 'package:Nesto/widgets/notification_screen_header_widget.dart';
import 'package:Nesto/widgets/substitution_start_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';
import 'package:Nesto/strings.dart' as strings;

class NotificationListingScreen extends StatefulWidget {
  static final routeName = "/notification_listing_screen";

  @override
  _NotificationListingScreenState createState() =>
      _NotificationListingScreenState();
}

class _NotificationListingScreenState extends State<NotificationListingScreen> {
  Future ft;
  bool checkBoxStatus;
  bool loadingForMarkAllAsRead;
  bool loadingForClearAll;
  bool markAllRead;
  List<bool> showHamburgerArray = [];

  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "Notification Listing Screen");
    loadingForMarkAllAsRead = false;
    loadingForClearAll = false;
    checkBoxStatus = false;
    markAllRead = false;
    getNotification();
    super.initState();
  }

  Future getNotification() async {
    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    var notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    if (isAuthTokenValid()) {
      if (authProvider.magentoUser == null) {
        ft = authProvider.fetchMagentoUser().then((value) async {
          await notificationProvider.getNotifications(
              customerId: authProvider.magentoUser.id.toString());
        });
      } else if (authProvider.magentoUser != null) {
        ft = notificationProvider.getNotifications(
            customerId: authProvider.magentoUser.id.toString());
      }
    }
  }

  Future updateReadStatus({List<int> itemIdArray}) async {
    logNesto("updateReadStatus called");
    var notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    await notificationProvider.updateNotificationsReadStatus(
        itemIdListToUpdateReadStatus: itemIdArray);
  }

  Future markAllAsRead() async {
    logNesto("markAllAsRead called");
    var notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    await notificationProvider.markAllNotificationsAsRead().then((value) {
      if (value == true) {
        setState(() {
          markAllRead = true;
          loadingForMarkAllAsRead = false;
          checkBoxStatus = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: headerBar(title: strings.NOTIFICATIONS, context: context),
        body: ConnectivityWidget(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: FutureBuilder(
                  future: ft,
                  builder: (context, snapshot) {
                    if ((snapshot.connectionState == ConnectionState.done)) {
                      return Provider.of<NotificationProvider>(context)
                                  .notificationsList
                                  .length ==
                              0
                          ? Container(
                              color: Colors.white,
                              child: NoNotificationWidget(),
                            )
                          : Container(
                              child: GroupedListView<Datum, String>(
                                elements:
                                    Provider.of<NotificationProvider>(context)
                                        .notificationsList,
                                order: GroupedListOrder.DESC,
                                itemComparator: (item1, item2) =>
                                    item1.id.compareTo(item2.id),
                                groupBy: (Datum element) {
                                  return element.createdAt
                                      .toString()
                                      .split(" ")
                                      .first;
                                },
                                floatingHeader: true,
                                groupHeaderBuilder: (Datum element) {
                                  String headerTitle;
                                  final now = DateTime.now();
                                  final today =
                                      DateTime(now.year, now.month, now.day);
                                  final yesterday = DateTime(
                                      now.year, now.month, now.day - 1);
                                  if ((element.createdAt
                                          .toString()
                                          .split(" ")
                                          .first) ==
                                      (today.toString().split(" ").first)) {
                                    headerTitle = strings.TODAY;
                                  } else if ((element.createdAt
                                          .toString()
                                          .split(" ")
                                          .first) ==
                                      (yesterday.toString().split(" ").first)) {
                                    headerTitle = strings.YESTERDAY;
                                  } else {
                                    headerTitle = element.createdAt
                                        .toString()
                                        .split(" ")
                                        .first;
                                  }
                                  bool getShowCheckBox() {
                                    if ((element.createdAt
                                            .toString()
                                            .split(" ")
                                            .first) ==
                                        (Provider.of<NotificationProvider>(
                                                context)
                                            .notificationsList[
                                                Provider.of<NotificationProvider>(
                                                            context)
                                                        .notificationsList
                                                        .length -
                                                    1]
                                            .createdAt
                                            .toString()
                                            .split(" ")
                                            .first)) {
                                      return true;
                                    } else {
                                      return false;
                                    }
                                  }

                                  return NotificationScreenHeaderWidget(
                                    title: headerTitle,
                                    showRightIcon: true,
                                    checkBoxStatus: checkBoxStatus,
                                    showCheckBox: getShowCheckBox(),
                                    onChangedCheckBox: (bool value) {
                                      setState(() {
                                        checkBoxStatus = value;
                                      });
                                      if (value == true) {
                                        loadingForMarkAllAsRead = true;
                                        markAllAsRead();
                                      }
                                    },
                                    onTapClearAll: () {
                                      setState(() {
                                        loadingForClearAll = true;
                                      });
                                      Provider.of<NotificationProvider>(context,
                                              listen: false)
                                          .clearAllNotifications()
                                          .then((value) {
                                        setState(() {
                                          loadingForClearAll = false;
                                        });
                                      });
                                    },
                                  );
                                },
                                itemBuilder: (_, Datum element) {
                                  return NotificationScreenDescriptionWidget(
                                    element: element,
                                    markAllAsReadStatus: markAllRead,
                                    onTapSingleNotification: () {
                                      if (element.seen == false) {
                                        setState(() {
                                          element.seen = true;
                                        });
                                        updateReadStatus(
                                            itemIdArray: [element.id]);
                                      } else {
                                        handleNotifications(element);
                                      }
                                    },
                                    onTapDeleteButton: () {
                                      setState(() {
                                        loadingForMarkAllAsRead = true;
                                      });
                                      Provider.of<NotificationProvider>(context,
                                              listen: false)
                                          .deleteSpecificNotificationOnly(
                                              itemIdListToDelete: [
                                            element.id
                                          ]).then((value) {
                                        setState(() {
                                          loadingForMarkAllAsRead = false;
                                        });
                                      });
                                    },
                                    onTapDeleteAllReadButton: () {
                                      setState(() {
                                        loadingForMarkAllAsRead = true;
                                      });
                                      Provider.of<NotificationProvider>(context,
                                              listen: false)
                                          .deleteAllReadNotifications()
                                          .then((value) {
                                        setState(() {
                                          loadingForMarkAllAsRead = false;
                                        });
                                      });
                                    },
                                  );
                                },
                              ),
                            );
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(
                          child: CircularProgressIndicator(
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                  values.NESTO_GREEN)));
                    } else
                      return Container(
                          color: Colors.white, child: NoNotificationWidget());
                  },
                ),
              ),
              ((loadingForMarkAllAsRead == true) ||
                      (loadingForClearAll == true))
                  ? Center(
                      child: CircularProgressIndicator(
                          valueColor: new AlwaysStoppedAnimation<Color>(
                              values.NESTO_GREEN)))
                  : Container()
            ],
          ),
        ),
      ),
    );
  }

  void handleNotifications(Datum element) async {
    logNesto('In app notification handling!');
    logNesto('Message data: ${element.data}');

    if ((element.data.action == "order") ||
        (element.data.action == "order_update") ||
        (element.data.action == "rate_previous_order")) {
      logNesto('action: $element.data.action');
      String orderId = element.data.value.orderId.toString();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return OrderListingScreen(
              orderid: orderId,
            );
          },
        ),
      );
    }
    if (element.data.action == 'substitution') {
      logNesto('action: $element.data.action');
      var subProvider =
          Provider.of<SubstitutionProvider>(context, listen: false);
      var orderId = element.data.value.orderId;
      var cuttOffTime = element.data.value.cutoffTime.toString();
      var outOfStockItemID = element.data.value.itemIdLambda;
      log("Substitution(OrderID): $orderId", name: 'notification_listing');

      //check if time limit exceeded of substitution.
      var localTime = DateTime.parse(cuttOffTime).toLocal();
      log(localTime.toString(), name: 'handleBackgroundNotifications');

      var difference = localTime.difference(DateTime.now()).inMinutes;

      //if time exceeded show error and return.
      if (difference <= 0) {
        showError(context, strings.SUBSTITUTION_TIME_LIMIT_HAS_EXCEEDED);
        return;
      }

      subProvider.cuttOffTime = localTime;
      subProvider.outOfStockItemID = outOfStockItemID;

      try {
        EasyLoading.show();
        await subProvider.getOrderSubstitute(orderId.toString());
        EasyLoading.dismiss();
        showSubstitutionStartModal(orderID: orderId);
      } catch (e) {
        EasyLoading.dismiss();
        log(e.toString(), name: "substitution/notification_listing");
        if (e?.message != null) {
          showError(context, e?.message);
        } else {
          showError(context, strings.SOMETHING_WENT_WRONG_WITH_EXCLAMATION);
        }
      }
    } else if (element.data.action == "launch_product") {
      // var storeProvider = Provider.of<StoreProvider>(context, listen: false);
      String sku = element.data.value.productSku;
      //log("SKU: $sku", name: "handleBackgroundNotifications");
      logNestoCustom(message: "SKU: $sku", logType: LogType.debug);

      if (sku != null && sku.isNotEmpty) {
        try {
          Navigator.push(
            context,
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
    } else if (element.data.action == "launch_category") {
      // var provider = Provider.of<StoreProvider>(context, listen: false);
      int categoryID = int.parse(element.data.value.categoryId);

      //log("ID: ${element.data.value.categoryId}",
      //name: "handleBackgroundNotifications");
      logNestoCustom(
          message: "ID: ${element.data.value.categoryId}",
          logType: LogType.debug);

      //log("name: ${element.data.value.categoryOfferName}",
      //name: "handleBackgroundNotifications");
      logNestoCustom(
          message: "name: ${element.data.value.categoryOfferName}",
          logType: LogType.debug);

      bool isIDValid = element.data.value.categoryId != null &&
              element.data.value.categoryId != ""
          ? true
          : false;
      bool isNameValid = element.data.value.categoryOfferName != null &&
              element.data.value.categoryOfferName.isNotEmpty
          ? true
          : false;

      if (isIDValid && isNameValid) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return CategoryItemsPage(categoryID: categoryID);

              // return ProductListingScreen(
              //   categoryID: categoryID,
              //   categoryTitle: element.data.value.categoryOfferName ?? "",
              // );
            },
          ),
        );
      }
    }
  }
}
