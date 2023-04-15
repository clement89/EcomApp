import 'package:Nesto/service_locator.dart';
import 'package:Nesto/services/navigation_service.dart';
import 'package:Nesto/utils/util.dart';
import 'package:flutter/material.dart';

var notificationServices = locator<NotificationService>();

class NotificationService {
  var _navigationKey = locator<NavigationService>().navigatorKey;

  void showInformationNotification(String message) {
    showInfo(_navigationKey.currentContext, message);
  }

  void showErrorNotification(String message) {
    showError(_navigationKey.currentContext, message);
  }

  void showSuccessNotification(String message) {
    showSuccess(_navigationKey.currentContext, message);
  }

  Future showCustomDialog(
      {String title,
      String description,
      String negativeText,
      String positiveText,
      Function action,
      Color positiveTextColor = Colors.red,
      Function onNopressed,
      bool barrierDismissible = true}) async{
    showAlerDialog(
        context: _navigationKey.currentContext,
        title: title,
        description: description,
        negativeText: negativeText,
        positiveText: positiveText,
        positiveTextColor: positiveTextColor,
        onPressed: action,
        onNoPressed: onNopressed,
        barrierDismissible: barrierDismissible);
  }
}
