import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/widgets/edge_cases/something_went_wrong.dart';
import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {

  static const routeName = "/error_screen";
  @override
  Widget build(BuildContext context) {
    firebaseAnalytics.screenView(screenName: "Error Screen");
    return SomethingWentWrongWidget();
  }
}
