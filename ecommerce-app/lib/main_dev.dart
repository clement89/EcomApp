import 'package:Nesto/app.dart';
import 'package:Nesto/service_locator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
  FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
  FlutterStatusbarcolor.setNavigationBarColor(Colors.transparent);
  FlutterStatusbarcolor.setNavigationBarWhiteForeground(false);

  // FlavorConfig(
  //     name: "dev",
  //     color: Colors.red,
  //     location: BannerLocation.bottomStart,
  //     variables: {
  //       "env": "dev",
  //       "BASE_URL": "https://dev.nesto.shop/rest",
  //       "LAMBDA_BASE_URL_MINIMUM": "https://dev-api.nesto.shop",
  //       "LAMBDA_BASE_URL": "https://dev-api.nesto.shop/basic",
  //       "LAMBDA_ORDER_URL": "https://dev-api.nesto.shop/order",
  //       "LAMBDA_SUBSTITUTE_URL": "https://dev-api.nesto.shop/crm",
  //       "PRODUCT_IMAGE_BASE_URL": 'https://cdndev.nesto.shop/catalog/product',
  //       "CATEGORY_IMAGE_BASE_URL": "https://cdndev.nesto.shop",
  //       "PAYMENT_GATEWAY_URL": "https://gateway.nesto.shop/auth/payment",
  //       "PAYMENT_REDIRECT_URL":
  //           "https://gateway.nesto.shop/auth/payment/status?env=dev",
  //       "ROOT_CATEGORY_ID": 1757,
  //       "BUY_NOW_CATEGORY_ID": 1758,
  //       "HOMEPAGE_URL":
  //           "https://7yx1v5nh93.execute-api.eu-central-1.amazonaws.com/dev/cdn/fetch?source=app",
  //       "BASE_URL_GRAPH_QL": "https://dev.nesto.shop/graphql",
  //     });

  FlavorConfig(
      name: "staging",
      color: Colors.orange,
      location: BannerLocation.bottomStart,
      variables: {
        "env": "staging",
        "BASE_URL": "https://staging.nesto.shop/rest",
        "LAMBDA_BASE_URL_MINIMUM": "https://staging-api.nesto.shop",
        "LAMBDA_BASE_URL": "https://staging-api.nesto.shop/basic",
        "LAMBDA_ORDER_URL": "https://staging-api.nesto.shop/order",
        "LAMBDA_SUBSTITUTE_URL": "https://staging-api.nesto.shop/crm",
        "PRODUCT_IMAGE_BASE_URL":
            'https://cdnstaging.nesto.shop/catalog/product',
        "CATEGORY_IMAGE_BASE_URL": "https://cdnstaging.nesto.shop",
        "PAYMENT_GATEWAY_URL": "https://gateway.nesto.shop/auth/payment",
        "PAYMENT_REDIRECT_URL": "https://go.nesto.shop",
        "ROOT_CATEGORY_ID": 1757,
        "BUY_NOW_CATEGORY_ID": 1758,
        "HOMEPAGE_URL":
            "https://builder.nesto.shop/home/staging/cdn/fetch?source=app",
        "BASE_URL_GRAPH_QL": "https://staging.nesto.shop/graphql",
      });

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    setupLocator();
    runApp(
      new MyApp(),
    );
  });
}
