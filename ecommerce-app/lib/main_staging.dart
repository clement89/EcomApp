import 'package:Nesto/app.dart';
import 'package:Nesto/service_locator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
  FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
  FlutterStatusbarcolor.setNavigationBarColor(Colors.transparent);
  FlutterStatusbarcolor.setNavigationBarWhiteForeground(false);

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

  // FlavorConfig(
  //     name: "production",
  //     color: Colors.green,
  //     location: BannerLocation.bottomStart,
  //     variables: {
  //       "env": "production",
  //       "BASE_URL": "https://nesto.shop/rest",
  //       "LAMBDA_BASE_URL_MINIMUM": "https://api.nesto.shop",
  //       "LAMBDA_BASE_URL": "https://api.nesto.shop/basic",
  //       "LAMBDA_ORDER_URL": "https://api.nesto.shop/order",
  //       "LAMBDA_SUBSTITUTE_URL": "https://api.nesto.shop/crm",
  //       "PRODUCT_IMAGE_BASE_URL": 'https://cdnprod.nesto.shop/catalog/product',
  //       "CATEGORY_IMAGE_BASE_URL": "https://cdnprod.nesto.shop",
  //       "PAYMENT_GATEWAY_URL":
  //           "https://gateway.nesto.shop/auth/production_payment",
  //       "PAYMENT_REDIRECT_URL":
  //           "https://gateway.nesto.shop/auth/production_payment/status?env=production",
  //       "ROOT_CATEGORY_ID": 2585,
  //       "BUY_NOW_CATEGORY_ID": 2736,
  //       "HOMEPAGE_URL": "https://builder.nesto.shop/home/cdn/fetch?source=app",
  //       "BASE_URL_GRAPH_QL": "https://www.nesto.shop/graphql",
  //     });

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    setupLocator();
    runApp(
      new MyApp(),
    );
  });
}
