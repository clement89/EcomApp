import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> _navigatorKey =
      new GlobalKey<NavigatorState>();
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;
  Future<dynamic> navigateTo(String routeName) {
    return _navigatorKey.currentState.pushNamed(routeName);
  }
}
