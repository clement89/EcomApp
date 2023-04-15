import 'dart:convert';

import 'package:Nesto/dio/utils/urls.dart';
import 'package:Nesto/models/notifications_response.dart';
import 'package:Nesto/utils/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class NotificationProvider extends ChangeNotifier {
  List<Datum> notificationsList = [];
  List<Datum> notificationListToday = [];
  List<Datum> notificationListYesterday = [];
  List<int> allNotificationIdsList = [];
  List<int> allSeenNotificationIdsList = [];
  int notificationCheckBoxCount;

  Future getNotifications({String customerId}) async {
    final url = LAMBDA_BASE_URL +
        "/notification/customer/$customerId";

    logNesto("get notifications url is " + url);
    var headers = {
      "Content-Type": "application/json",
      "access-token": getLambdaToken() ?? "",
    };

    headers.removeWhere(
            (String key, dynamic value) => value == null || key == null);
    logNesto("get notifications called with header "+headers.toString());

    String queryParams = await getQueryParams() ?? "";

    try {
      http.Response response = await http.get(Uri.parse(url.toString()+queryParams), headers: headers);
      if (response.statusCode == 200) {
        notificationsList.clear();
        notificationCheckBoxCount = 0;
        NotificationsCallResponse notificationsCallResponse =
        notificationsCallResponseFromJson(response.body);
        notificationsList.addAll(notificationsCallResponse.data);
        notifyListeners();
        await getAllNotificationsIds();
        await getAllSeenNotificationsIds();
      } else {
        logNesto("something went wrong getting notications");
      }
    } catch (error) {
      logNesto(error);
    }
  }

  Future getAllNotificationsIds() async {
    allNotificationIdsList.clear();
    for (int i = 0; i < notificationsList.length; i++) {
      allNotificationIdsList.add(notificationsList[i].id);
    }
    notifyListeners();
  }

  Future getAllSeenNotificationsIds() async {
    allSeenNotificationIdsList.clear();
    for (int i = 0; i < notificationsList.length; i++) {
      if (notificationsList[i].seen == true) {
        allSeenNotificationIdsList.add(notificationsList[i].id);
      }
    }
    notifyListeners();
  }

  Future updateNotificationsReadStatus(
      {List<int> itemIdListToUpdateReadStatus}) async {
    final url = LAMBDA_BASE_URL +
        "/notification/seen";

    logNesto("update notifications read status url is " + url);
    logNesto("update notifications read status called");
        var headers = {
      "Content-Type": "application/json",
      "access-token": getLambdaToken() ?? "",
    };

    headers.removeWhere(
            (String key, dynamic value) => value == null || key == null);
    logNesto("get notifications called with header "+headers.toString());

    String queryParams = await getQueryParams() ?? "";
    try {
      http.Response response = await http.post(Uri.parse(url.toString()+queryParams),
          headers: headers,
          body:
          json.encode({"notification_ids": itemIdListToUpdateReadStatus}));
      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        logNesto(decodedData["message"].toString());
        for (int i = 0; i < notificationsList.length; i++) {
          for (int j = 0; j < itemIdListToUpdateReadStatus.length; j++) {
            if (notificationsList[i].id == itemIdListToUpdateReadStatus[j]) {
              notificationsList[i].seen = true;
              notifyListeners();
            }
          }
        }
      } else {
        logNesto("something went wrong  updating notifications read status"+response.statusCode.toString());
      }
    } catch (error) {
      logNesto(error);
    }
  }

  Future<bool> markAllNotificationsAsRead() async {
    final url = LAMBDA_BASE_URL +
        "/notification/seen";

    logNesto("mark All Notifications As Read url is " + url);
    logNesto("mark All Notifications As Read called");
            var headers = {
      "Content-Type": "application/json",
      "access-token": getLambdaToken() ?? "",
    };

    headers.removeWhere(
            (String key, dynamic value) => value == null || key == null);
    logNesto("get notifications called with header "+headers.toString());

    String queryParams = await getQueryParams() ?? "";

    try {
      http.Response response = await http.post(Uri.parse(url.toString()+queryParams),
          headers: headers,
          body: json.encode({"notification_ids": allNotificationIdsList}));
      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        logNesto(decodedData["message"].toString());
        for (int i = 0; i < notificationsList.length; i++) {
          notificationsList[i].seen = true;
          notifyListeners();
        }
        return true;
      } else {
        logNesto("something went wrong mark all notifications as read");
        return false;
      }
    } catch (error) {
      logNesto(error);
      return false;
    }
  }

  Future<bool> deleteSpecificNotificationOnly(
      {List<int> itemIdListToDelete}) async {
    final url = LAMBDA_BASE_URL +
        "/notification/clear";

    logNesto("delete specific Notification url is " + url);
    logNesto("delete specific Notification called");
            var headers = {
      "Content-Type": "application/json",
      "access-token": getLambdaToken() ?? "",
    };

    headers.removeWhere(
            (String key, dynamic value) => value == null || key == null);
    logNesto("get notifications called with header "+headers.toString());

    String queryParams = await getQueryParams() ?? "";
    try {
      http.Response response = await http.post(Uri.parse(url.toString()+queryParams),
          headers: headers,
          body: json.encode({"notification_ids": itemIdListToDelete}));
      if (response.statusCode == 200) {
        logNesto("successfully deleted notification");
        for (int i = 0; i < notificationsList.length; i++) {
          for (int j = 0; j < itemIdListToDelete.length; j++) {
            if (notificationsList[i].id == itemIdListToDelete[j]) {
              notificationsList.removeAt(i);
              notifyListeners();
            }
          }
        }
        return true;
      } else {
        logNesto("something went wrong deleting notification");
        return false;
      }
    } catch (error) {
      logNesto(error);
      return false;
    }
  }

  Future<bool> deleteAllReadNotifications() async {
    final url = LAMBDA_BASE_URL +
        "/notification/clear";

    logNesto("delete all read Notification url is " + url);
    logNesto("delete all read Notification called");
            var headers = {
      "Content-Type": "application/json",
      "access-token": getLambdaToken() ?? "",
    };

    headers.removeWhere(
            (String key, dynamic value) => value == null || key == null);
    logNesto("get notifications called with header "+headers.toString());

    String queryParams = await getQueryParams() ?? "";
    await getAllNotificationsIds();
    await getAllSeenNotificationsIds();
    try {
      http.Response response = await http.post(Uri.parse(url.toString()+queryParams),
          headers: headers,
          body: json.encode({"notification_ids": allSeenNotificationIdsList}));
      if (response.statusCode == 200) {
        logNesto("successfully deleted all notifications");
        for (int i = 0; i < notificationsList.length; i++) {
          for (int j = 0; j < allSeenNotificationIdsList.length; j++) {
            if (notificationsList[i].id == allSeenNotificationIdsList[j]) {
              notificationsList.removeAt(i);
              notifyListeners();
            }
          }
        }
        return true;
      } else {
        logNesto("something went wrong deleting all read  notifications");
        return false;
      }
    } catch (error) {
      logNesto(error);
      return false;
    }
  }  Future<bool> clearAllNotifications() async {
    final url = LAMBDA_BASE_URL +
        "/notification/clear";

    logNesto("clear all Notification url is " + url);
    logNesto("clear all Notification called");
            var headers = {
      "Content-Type": "application/json",
      "access-token": getLambdaToken() ?? "",
    };

    headers.removeWhere(
            (String key, dynamic value) => value == null || key == null);
    logNesto("get notifications called with header "+headers.toString());

    String queryParams = await getQueryParams() ?? "";
    await getAllNotificationsIds();
    await getAllSeenNotificationsIds();
    try {
      http.Response response = await http.post(Uri.parse(url.toString()+queryParams),
          headers: headers,
          body: json.encode({"notification_ids": allNotificationIdsList}));
      if (response.statusCode == 200) {
        logNesto("successfully deleted all notifications");
        notificationsList.clear();
        notifyListeners();
        return true;
      } else {
        logNesto("something went wrong deleting all read  notifications");
        return false;
      }
    } catch (error) {
      logNesto(error);
      return false;
    }
  }
}
