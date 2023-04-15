import 'package:flutter_flavor/flutter_flavor.dart';

final String ENV = FlavorConfig.instance.variables["env"];
final String MAGENTO_BASE_URL = FlavorConfig.instance.variables["BASE_URL"];
final String LAMBDA_BASE_URL =
    FlavorConfig.instance.variables["LAMBDA_BASE_URL"];
final String LAMBDA_BASE_URL_MINIMUM =
    FlavorConfig.instance.variables["LAMBDA_BASE_URL_MINIMUM"];
final LAMBDA_ORDER_URL = FlavorConfig.instance.variables["LAMBDA_ORDER_URL"];
final String PRODUCT_IMAGE_BASE_URL =
    FlavorConfig.instance.variables["PRODUCT_IMAGE_BASE_URL"];
final String CATEGORY_IMAGE_BASE_URL =
    FlavorConfig.instance.variables["CATEGORY_IMAGE_BASE_URL"];
final String PAYMENT_GATEWAY_URL =
    FlavorConfig.instance.variables["PAYMENT_GATEWAY_URL"];
final String PAYMENT_REDIRECT_URL =
    FlavorConfig.instance.variables["PAYMENT_REDIRECT_URL"];
final int ROOT_CATEGORY_ID =
    FlavorConfig.instance.variables["ROOT_CATEGORY_ID"];
final int BUY_NOW_CAT_ID =
    FlavorConfig.instance.variables["BUY_NOW_CATEGORY_ID"];
final String HOME_PAGE_URL = FlavorConfig.instance.variables["HOMEPAGE_URL"];
final String GRAPH_QL_CART_URL =
    FlavorConfig.instance.variables["BASE_URL_GRAPH_QL"];
final LAMBDA_SUBSTITUTE_URL =
    FlavorConfig.instance.variables["LAMBDA_SUBSTITUTE_URL"];
