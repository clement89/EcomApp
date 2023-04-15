import 'dart:async';
import 'dart:io';

import 'package:Nesto/providers/auth_provider.dart';
import 'package:Nesto/providers/home_builder_provider.dart';
import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/screens/base_screen.dart';
import 'package:Nesto/screens/onboarding_screen.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/services/firebase_cloud_messaging.dart';
import 'package:Nesto/strings.dart' as strings;
import 'package:Nesto/utils/util.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/widgets/connectivity_widget.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  static String routeName = "/splash_screen";

  bool didFetch = false;

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

// Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
//   if (message.containsKey('data')) {
//     // Handle data message
//     final dynamic data = message['data'];
//     logNesto( message['data']['screen']);
//   }
//
//   if (message.containsKey('notification')) {
//     // Handle notification message
//     final dynamic notification = message['notification'];
//   }
//
//   // Or do other work.
// }

class _SplashScreenState extends State<SplashScreen> {
  RemoteConfig remoteConfig;
  Future _nestoFuture;
  bool pendingAnalyticsLogging = true;

  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "Splash Screen");
    super.initState();

    var duration = const Duration(seconds: 3);
    new Timer(duration, checkIfVersionIsCompatible);

    fetchAuthToken();
    getVisitCount();
    getFirebaseToken();
    _getRemoteConfig();
    _getCustomerLoginTime();
    _nestoFuture = Provider.of<StoreProvider>(context, listen: false)
        .checkIfFetchFinished();
    startApp();
    this.initDynamicLinks();
  }

  void _getCustomerLoginTime() {
    DateTime dateTime = DateTime.now();
    Provider.of<AuthProvider>(context, listen: false)
        .timeAtWhichCustomerOpenedTheApp = dateTime;
    logNesto("LOGIN TIME:" + dateTime.toString());
  }

  void startApp() async {
    if (!widget.didFetch) {
      widget.didFetch = true;
      //TODO:APP FLOW STARTS FROM HERE
      try {
        var storeProvider = Provider.of<StoreProvider>(context, listen: false);
        var authProvider = Provider.of<AuthProvider>(context, listen: false);
        storeProvider.setIsHomePageLoading(true);
        await authProvider.getUserLocation();
        await storeProvider.fetchAll();
      } catch (e) {
        print('Erorr in splash screen ----> $e');
      } finally {}
    }

    print('reached here....');
    var multiHomePageProvider =
        Provider.of<MultiHomePageProvider>(context, listen: false); //CJC added

    multiHomePageProvider.getAllHomePageData();
  }

  void getFirebaseToken() async {
    await firebaseCloudMessaging.initializeService();
  }

  void _getRemoteConfig() async {
    await Firebase.initializeApp();
    remoteConfig = RemoteConfig.instance;
    try {
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero,
      ));
      await remoteConfig.fetchAndActivate();
    } catch (e) {
      logNesto("Could not fetch remote config");
    }
  }

  void checkIfVersionIsCompatible() async {
    logNesto("VERSION CHECK");
    //logNesto("CHECK IF VERSION IS COMPATIBLE");
    int minimumVersionNumber = remoteConfig.getInt("minimum_version") ?? 0;
    logNesto(minimumVersionNumber.toString());
    //logNesto("MINIMUM VERSION:" + minimumVersionNumber.toString());
    int currentVersionNumber = await getBuildNumber();
    logNesto(currentVersionNumber.toString());
    //logNesto("CURRENT VERSION:" + currentVersionNumber.toString());
    if (currentVersionNumber < minimumVersionNumber) {
      //NOT COMPATIBLE
      showOkAlertDialog(
        barrierDismissible: false,
        context: context,
        title: strings.UPDATE_REQUIRED,
        message: strings.UPDATE_APP_MESSAGE,
      ).then((value) => openAppStoreOrPlaystore());
    } else {
      //COMPATIBLE
      checkIfMaintenanceModeIsOn();
    }
  }

  void checkIfMaintenanceModeIsOn() {
    bool isMaintenanceMode = remoteConfig.getBool("maintenance_mode") ?? false;
    String title =
        remoteConfig.getString("maintenance_mode_title") ?? "Maintenance mode";
    String message = remoteConfig.getString("maintenance_mode_message") ??
        strings.MAINTANANCE_MODE_MESSAGE;
    if (isMaintenanceMode) {
      showOkAlertDialog(
        barrierDismissible: false,
        context: context,
        title: title,
        message: message,
      ).then((value) => closeApplication());
    } else {
      //NO Maintenance,Load the Base Screen
      loadNextScreen();
    }
  }

  Future _handleDeepLinks(PendingDynamicLinkData data) async {
    final Uri deepLink = data?.link;
    if (deepLink != null) {
      logNesto(deepLink.queryParameters['utm_content'].toString());
      logNesto(deepLink.queryParameters['utm_campaign'].toString());
      logNesto(deepLink.queryParameters['utm_medium'].toString());
      logNesto(deepLink.queryParameters['utm_source'].toString());
      String source = '';
      String medium = '';
      String campaign = '';
      String content = '';
      if (deepLink.toString().contains('referral')) {
        source = Platform.isAndroid
            ? "play store"
            : Platform.isIOS
                ? "app store"
                : 'none';
        medium = "referral";
        campaign = '';
        content = '';
      } else {
        source = deepLink.queryParameters['utm_source']?.toString() ?? 'direct';
        medium = deepLink.queryParameters['utm_medium']?.toString() ?? 'none';
        campaign = deepLink.queryParameters['utm_campaign']?.toString() ?? '';
        content = deepLink.queryParameters['utm_content']?.toString() ?? '';
      }
      logInstallToFirebase(
          source: source, medium: medium, campaign: campaign, content: content);
      firebaseAnalytics.logSessionStart(
          campaign: campaign, source: source, medium: medium, content: content);
      pendingAnalyticsLogging = false;
    }
  }

  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      await _handleDeepLinks(dynamicLink);
    }, onError: (OnLinkErrorException e) async {
      logNesto('onLinkError');
      logNesto(e.message);
    });

    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    await _handleDeepLinks(data);
  }

  void loadNextScreen() async {
    logNesto('LOAD NEXT SCREEN');
//Initialize the homepage_loader_image_url
    String _homepageLoaderImage = await loadHomePageLoadingImageURL();
    Provider.of<AuthProvider>(context, listen: false)
        .syncHomepageLoaderImage(_homepageLoaderImage);
    //Store whether the user was already on-boarded or not
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasOnBoarded = prefs.getBool('onBoarded') ?? false;
    logNesto('HAS_ONBOARDED ===========>' + hasOnBoarded.toString());
    if (pendingAnalyticsLogging) {
      firebaseAnalytics.logSessionStart(
        source: 'direct',
        medium: 'none',
        campaign: '',
        content: '',
      );
    }
    if (!hasOnBoarded) {
      logNesto('IMAGE PRE CACHING');
      precacheImage(OptimizedCacheImageProvider(homepageLoaderImage), context);
      logNesto('MOVING TO ONBOARDING SCREEN');
      Navigator.of(context).pushReplacementNamed(OnBoardingScreen.routeName);
      if (pendingAnalyticsLogging) {
        logInstallToFirebase(
            source: 'direct',
            medium: 'none',
            campaign: '',
            content: '',
            skipOnboardingCheck: true);
      }
      await prefs.setBool("onBoarded", true);
    } else {
      Navigator.of(context)
          .pushReplacementNamed(BaseScreen.routeName, arguments: {"index": 0});
    }
  }

  void logInstallToFirebase(
      {String source = 'direct',
      String medium = 'none',
      String campaign = '',
      String content = '',
      bool skipOnboardingCheck = false}) async {
    bool hasOnBoarded = false;
    if (!skipOnboardingCheck) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      hasOnBoarded = prefs.getBool('onBoarded') ?? false;
    }
    if (!hasOnBoarded) {
      firebaseAnalytics.logInstall(
          campaign: campaign, source: source, medium: medium, content: content);
    } else {
      logNesto("has been onborded before");
    }
  }

  bool hasLoaded = false;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return ConnectivityWidget(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Color(0XFFc71712),
        body: Image.asset(
          "assets/images/splash_1.gif",
          height: size.height,
          width: size.width,
        ),
      ),
    );
  }
}
