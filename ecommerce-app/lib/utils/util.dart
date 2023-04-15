import 'dart:io';

import 'package:Nesto/models/cartItem.dart';
import 'package:Nesto/services/easy_loading_service.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/utils/constants.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/widgets/custom_dialog.dart';
import 'package:Nesto/widgets/rate_my_app_bottom_sheet_widget.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logger/logger.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:device_info/device_info.dart';
import 'package:Nesto/strings.dart' as strings;
import 'package:another_flushbar/flushbar.dart';

//Store ID and code
int _storeId = 1;
int _websiteId = 1;
final String _env = FlavorConfig.instance.variables["env"];
String _storeCode;
bool _isDefaultStore = true;
String _websiteName = "";
int _sapWebsiteId = 8042;
String homepageLoaderImage = defaultHomepageLoaderImage;
//CJC added
double minSubTotal = 0;
double shippingCharge = 11;
double editOrderMinSubTotal = 0;
double freeShippingMinTotal = 0;

int get storeId {
  return _storeId;
}

set storeId(int value) => _storeId = value;

int get websiteId {
  return _websiteId;
}

set websiteId(int value) => _websiteId = value;

set storeCode(String value) => _storeCode = value;

String get storeCode {
  if (_storeCode == null) {
    if (_env != "production")
      _storeCode = "en_ajh";
    else
      _storeCode = "en_ajman";
  }
  return _storeCode;
}

set websiteName(String value) => _websiteName = value;

String get websiteName {
  return _websiteName;
}

set sapWebsiteId(int value) => _sapWebsiteId = value;

int get sapWebsiteId {
  return _sapWebsiteId;
}

bool get isDefaultStore {
  return _isDefaultStore;
}

set isDefaultStore(value) => _isDefaultStore = value;

Future<void> getVisitCount() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  bool firstOrderPlaced =
      sharedPreferences.getBool('firstOrderPlaced') ?? false;
  if (firstOrderPlaced) {
    int visitCount = (sharedPreferences.getInt('counter') ?? 0) + 1;
    await sharedPreferences.setInt("counter", visitCount);
  }
}

Future<void> showCartTutorial() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  if (sharedPreferences.getBool("showCartTutorial") == null) {
    await sharedPreferences.setBool("showCartTutorial", true);
  } else {
    await sharedPreferences.setBool("showCartTutorial", false);
  }
}

Future<bool> shouldShowRateMyAppBottomSheet() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  int visitCount = sharedPreferences.getInt('counter') ?? 0;
  bool alreadyRated = sharedPreferences.getBool('alreadyRated') ?? false;
  bool firstOrderPlaced =
      sharedPreferences.getBool('firstOrderPlaced') ?? false;
  return !alreadyRated && firstOrderPlaced && ((visitCount % 5) == 0);
}

Future<String> loadHomePageLoadingImageURL() async {
  homepageLoaderImage = await getHomePageLoadingImageURL();
  logNestoCustom(
      message: "Loaded : " + homepageLoaderImage, logType: LogType.error);

  return homepageLoaderImage;
}

Future<String> getHomePageLoadingImageURL() async {
  try {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String _homepageLoaderImage =
        sharedPreferences.getString("homepage_loader_image_url");
    if (_homepageLoaderImage == null) {
      logNestoCustom(message: "Image Not Cached", logType: LogType.error);

      sharedPreferences.setString(
          "homepage_loader_image_url", defaultHomepageLoaderImage);
      _homepageLoaderImage = defaultHomepageLoaderImage;
    } else {
      logNestoCustom(message: "Image Cached", logType: LogType.error);
    }
    return _homepageLoaderImage;
  } catch (e) {
    return defaultHomepageLoaderImage;
  }
}

Future<void> setHomePageLoadingImageURL(String url) async {
  try {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString("homepage_loader_image_url", url);
    logNesto("URL saved successfully");
  } catch (e) {}
}

void showBottomSheetInHomePage(context) async {
  showModalBottomSheet<dynamic>(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      builder: (builder) {
        return RateMyAppBottomSheetWidget();
      });
}

double getInaamPoints(double price) {
  //CONVERSION
  //SALE: 5 AED = 1 POINT
  //CONVERSION: 20 POINT = 1 AED

  double inaamPoints = 0;
  inaamPoints = price / 5;
  return inaamPoints;
}

void showSuccess(BuildContext context, String message) {
  Future.delayed(Duration.zero, () {
    showTopSnackBar(
      context,
      CustomSnackBar.success(message: message),
      displayDuration: Duration(milliseconds: 1000),
      hideOutAnimationDuration: Duration(milliseconds: 350),
    );
  });
}

void showError(BuildContext context, String message) {
  if (message.isEmpty) message = "Something went wrong";
  Future.delayed(Duration.zero, () {
    // showTopSnackBar(context, CustomSnackBar.error(message: message));
    showInfoNew(context, message);
  });
}

void showInfoNew(BuildContext context, String message) {
  Flushbar flush;

  flush = Flushbar<bool>(
    flushbarPosition: FlushbarPosition.TOP,
    flushbarStyle: FlushbarStyle.FLOATING, //GROUNDED
    duration: Duration(seconds: 2),
    margin: EdgeInsets.all(8),
    borderRadius: BorderRadius.circular(8),
    backgroundGradient:
        LinearGradient(colors: [Colors.redAccent[400], Colors.red[400]]),
    backgroundColor: Colors.red,
    boxShadows: [
      BoxShadow(
        color: Colors.black12,
        offset: Offset(0.0, 2.0),
        blurRadius: 3.0,
      )
    ],
    title: 'Error',
    message: message,
    messageColor: Colors.white,
    icon: Icon(
      Icons.cancel,
      color: Colors.white,
    ),
    onTap: (flushNew) {
      flush.dismiss(true); // result = true
    },
    mainButton: TextButton(
      onPressed: () {
        flush.dismiss(true); // result = true
      },
      child: Text(
        "DISMISS",
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    ),
  ) // <bool> is the type of the result passed to dismiss() and collected by show().then((result){})
    ..show(context).then((result) {
      // setState(() { // setState() is optional here
      //   _wasButtonClicked = result;
      // });
    });
}

void showInfo(BuildContext context, String message) {
  Future.delayed(Duration.zero, () {
    showTopSnackBar(context, CustomSnackBar.info(message: message));
  });
}

Future showAlerDialog({
  @required BuildContext context,
  @required String title,
  String description,
  @required String positiveText,
  @required String negativeText,
  Color positiveTextColor,
  Function onPressed,
  Function onNoPressed,
  bool barrierDismissible = true,
}) async {
  await showGeneralDialog(
    barrierLabel: title,
    barrierDismissible: barrierDismissible,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: Duration(milliseconds: 200),
    context: context,
    pageBuilder: (context, anim1, anim2) {
      return CustomDialogWidget(
        context: context,
        title: title,
        description: description,
        positiveText: positiveText,
        negativeText: negativeText,
        onNoPressed: onNoPressed,
        onPressed: onPressed,
        positiveTextColor: positiveTextColor,
      );
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return SlideTransition(
        position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim1),
        child: child,
      );
    },
  );
}

double getInaamInAed(double inaamPoints) {
  return (inaamPoints / 20);
}

class SeeMore extends StatelessWidget {
  const SeeMore({
    Key key,
    @required this.onPress,
  }) : super(key: key);

  final Function onPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Text(
        'See More',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: values.NESTO_GREEN,
        ),
      ),
    );
  }
}

void launchPrivacyPolicy() async {
  if (!easyLoadingService.easyLoadingStatus) {
    //firebase analytics logging.
    firebaseAnalytics.privacyPolicy();

    final url = Uri.encodeFull("https://docs.nesto.shop/Privacy.pdf");
    if (await canLaunch(url))
      await launch(url);
    else
      // can't launch url, there is some error
      throw "Could not launch $url";
  }
}

void launchTermsAndConditions() async {
  if (!easyLoadingService.easyLoadingStatus) {
    //firebase analytics logging.
    firebaseAnalytics.termsAndConditions();

    final url = Uri.encodeFull("https://docs.nesto.shop/Terms.html");
    if (await canLaunch(url))
      await launch(url);
    else
      // can't launch url, there is some error
      throw "Could not launch $url";
  }
}

void showLoader() {
  EasyLoading.show(
    //status: 'Processing...',
    maskType: EasyLoadingMaskType.black,
  );
}

void hideLoader() {
  EasyLoading.dismiss();
}

bool isLoaderShowing() {
  return EasyLoading.isShow;
}

Future<int> getBuildNumber() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String buildNumber = packageInfo.buildNumber;
  return int.parse(buildNumber);
}

void closeApplication() {
  if (Platform.isAndroid) {
    Future.delayed(const Duration(milliseconds: 1000), () {
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    });
  } else if (Platform.isIOS) {
    Future.delayed(const Duration(milliseconds: 1000), () {
      exit(0);
    });
  }
}

Color hexToColor(String code) {
  try {
    return Color(int.parse('0XFF' + code.substring(1)));
  } catch (e) {
    print('Error in Hex color --- $e');
    return Colors.white;
  }
}

void largeLog(String tag, String content) {
  if (content.length > 500) {
    logNesto(tag + ":" + content.substring(0, 500));
    largeLog(tag, content.substring(500));
  } else {
    logNesto(tag + ":" + content);
  }
}

// String getStoreNameBasedOnId(int id, String env) {
//   if (env == "staging") {
//     if (id == 1 || id == 2)
//       return "Ajman";
//     else if (id == 9 || id == 10)
//       return "Abu Shagara";
//     else
//       return "";
//   } else if (env == "production") {
//     if (id == 1 || id == 2)
//       return "Ajman";
//     else if (id == 3 || id == 4)
//       return "Abu Shagara";
//     else
//       return "";
//   } else
//     return "";
// }

enum LogType { verbose, debug, info, warning, error }

void logNesto(dynamic message) {
  if (FlavorConfig.instance.variables["env"] != "production") {
    //if(true){
    var logger = Logger(filter: null, output: null, printer: PrettyPrinter());
    logger.i(message.toString());
  }
}

void logNestoCustom({String message, LogType logType}) {
  if (FlavorConfig.instance.variables["env"] != "production") {
    // if(true){
    var logger = Logger(filter: null, output: null, printer: PrettyPrinter());
    switch (logType) {
      case LogType.verbose:
        {
          logger.v(message);
        }
        break;

      case LogType.debug:
        {
          logger.d(message);
        }
        break;

      case LogType.info:
        {
          logger.i(message);
        }
        break;

      case LogType.warning:
        {
          logger.w(message);
        }
        break;

      case LogType.error:
        {
          logger.e(message);
        }
        break;

      default:
        {
          logger.d(message);
        }
        break;
    }
  }
}

//Section [Auth Token Function]
String _authToken = "";
String _lamdaCustomerToken = "";

bool isAuthTokenValid() {
  if (_authToken != "")
    return true;
  else
    return false;
}

bool isLambdaTokenValid() {
  if (_lamdaCustomerToken != "")
    return true;
  else
    return false;
}

String getAuthToken() {
  return _authToken;
}

String getLambdaToken() {
  return _lamdaCustomerToken;
}

void fetchAuthToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var value = prefs.getString(values.AUTH_TOKEN_KEY);
  if (value != null) _authToken = value;
  print("AUTH TOKEN:" + _authToken);
  await fetchLambdaToken();
}

Future fetchLambdaToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var value = prefs.getString(values.LAMBDA_TOKEN_KEY);
  if (value != null) _lamdaCustomerToken = value;
  print("LAMBDA TOKEN:" + _lamdaCustomerToken);
}

void setAuthToken(String value) async {
  _authToken = value;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(values.AUTH_TOKEN_KEY, value).then((status) {
    if (status) {
      print("AUTH TOKEN SET");
      _authToken = value;
    }
  });
}

void setLambdaCustomerToken(String value) async {
  _lamdaCustomerToken = value;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(values.LAMBDA_TOKEN_KEY, value).then((status) {
    if (status) {
      print("LAMBDA TOKEN SET");
      _lamdaCustomerToken = value;
    }
  });
}

void clearAuthToken() {
  _authToken = "";
  setAuthToken("");
}

void clearLambdaToken() {
  _lamdaCustomerToken = "";
  setLambdaCustomerToken("");
}

void openAppStoreOrPlaystore() {
  if (Platform.isAndroid) {
    final androidUrl = Uri.encodeFull(
        "https://play.google.com/store/apps/details?id=shop.nesto.ecommerce");

    launch(androidUrl);
  } else if (Platform.isIOS) {
    final iosUrl = Uri.encodeFull(
        "https://apps.apple.com/in/app/nesto-online-shopping/id1560646978");
    launch(iosUrl);
  }
}

getNetorkType() async {
  ConnectivityResult connectivityResult =
      await Connectivity().checkConnectivity();
  switch (connectivityResult) {
    case ConnectivityResult.mobile:
      return "Mobile";
      break;
    case ConnectivityResult.wifi:
      return "WiFi";
      break;
    default:
      return "none";
      break;
  } // User defined class
}

getQueryParams({bool forMail = false}) async {
  String packageDetails = '';
  String deviceDetails = '';
  String networkDetails = '';
  var packageInfo = await PackageInfo.fromPlatform();
  if (forMail) {
    if (Platform.isAndroid) {
      packageDetails =
          "PackageName : ${packageInfo?.packageName ?? "no_package_name"}\nAppName : ${packageInfo?.appName ?? "no_app_name"}\nApp Version : ${packageInfo?.version ?? "no_package_version"}\nBuild Number : ${packageInfo?.buildNumber ?? "no_build_number"}\n";
    }
    if (Platform.isIOS) {
      packageDetails =
          "PackageName : ${packageInfo?.packageName ?? "no_package_name"} | App Version : ${packageInfo?.version ?? "no_package_version"} | Build Number : ${packageInfo?.buildNumber ?? "no_build_number"} | ";
    }
  } else {
    packageDetails =
        "?packageName=${packageInfo?.packageName ?? "no_package_name"}&appName=${packageInfo?.appName ?? "no_app_name"}&buildNumber=${packageInfo?.buildNumber ?? "no_build_number"}&packageVersion=${packageInfo?.version ?? "no_package_version"}";
  }
  if (Platform.isAndroid) {
    var androidInfo = await DeviceInfoPlugin().androidInfo;
    var release = androidInfo?.version?.release ?? "no_release";
    var sdkInt = androidInfo?.version?.sdkInt ?? "no_sdk";
    var manufacturer = androidInfo?.manufacturer ?? "no_manufacturer";
    var model = androidInfo?.model ?? "no_model";
    if (forMail) {
      deviceDetails =
          'OS : Android\nVersion : $release\nSDK : $sdkInt\nName : $manufacturer\nModel : $model\n';
    } else {
      deviceDetails =
          '&os=Android&version=$release&sdk=$sdkInt&name=$manufacturer&model=$model';
    }
    // print('Android $release (SDK $sdkInt), $manufacturer $model');
    // Android 9 (SDK 28), Xiaomi Redmi Note 7
  }

  if (Platform.isIOS) {
    var iosInfo = await DeviceInfoPlugin().iosInfo;
    var systemName = iosInfo?.systemName ?? "no_os_name";
    var version = iosInfo?.systemVersion ?? "no_version";
    var name = iosInfo.utsname.machine ?? "no_name";
    var model = iosInfo?.model ?? "no_model";
    if (forMail) {
      deviceDetails =
          'OS : $systemName | Version : $version | Name : $name | Model : $model |';
    } else {
      deviceDetails =
          '&os=$systemName&version=$version&name=$name&model=$model';
    }
    // print('$systemName $version, $name $model');
    // iOS 13.1, iPhone 11 Pro Max iPhone
  }
  if (forMail) {
    networkDetails = "";
  } else {
    networkDetails = "&network=${await getNetorkType() ?? "none"}";
  }
  return packageDetails + deviceDetails + networkDetails;
}

String getErrorTextForStepper(CartItem cartItem) {
  if (cartItem.product.inStock) {
    if (cartItem.productInStockMagento) {
      if ((cartItem.product.isBackOrder ?? false) == true) {
        if (cartItem.quantity < cartItem.minimumQuantity) {
          return "${strings.min_quantity_allowed_in_cart_error} ${cartItem.minimumQuantity}";
        } else if (cartItem.quantity > cartItem.maximumQuantity) {
          return "${strings.max_quantity_allowed_in_cart_error} ${cartItem.maximumQuantity}";
        } else {
          return "";
        }
      } else {
        if (cartItem.quantity > cartItem.quantityMagento) {
          if (cartItem.maximumQuantity < cartItem.quantityMagento) {
            return "${strings.max_quantity_allowed_in_cart_error} ${cartItem.maximumQuantity}";
          } else {
            return "only ${cartItem.quantityMagento} in stock";
          }
        } else {
          if (cartItem.quantity < cartItem.minimumQuantity) {
            return "${strings.min_quantity_allowed_in_cart_error} ${cartItem.minimumQuantity}";
          } else if (cartItem.quantity > cartItem.maximumQuantity) {
            if (cartItem.maximumQuantity > cartItem.quantityMagento) {
              return "only ${cartItem.quantityMagento} in stock";
            } else {
              return "${strings.max_quantity_allowed_in_cart_error} ${cartItem.maximumQuantity}";
            }
          } else {
            return "";
          }
        }
      }
    } else {
      return "out of stock";
    }
  } else {
    return "out of stock";
  }
}

String encodeQueryParameters(Map<String, String> params) {
  return params.entries
      .map((e) =>
          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
}
