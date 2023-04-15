import 'package:Nesto/models/user.dart';
import 'package:Nesto/providers/auth_provider.dart';
import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/screens/about_screen.dart';
import 'package:Nesto/screens/address_book_screen.dart';
import 'package:Nesto/screens/contact_us_screen.dart';
import 'package:Nesto/screens/feedback_screen.dart';
import 'package:Nesto/screens/login_screen.dart';
import 'package:Nesto/screens/notification_listing_screen.dart';
import 'package:Nesto/screens/order_screen.dart';
import 'package:Nesto/screens/profile_screen.dart';
import 'package:Nesto/screens/referal_screen.dart';
import 'package:Nesto/screens/webview_screen.dart';
import 'package:Nesto/screens/wishlist_screen.dart';
import 'package:Nesto/service_locator.dart';
import 'package:Nesto/services/easy_loading_service.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/services/local_storage.dart';
import 'package:Nesto/services/notification_service.dart';
import 'package:Nesto/strings.dart' as strings;
import 'package:Nesto/utils/util.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/widgets/container_custom_myaccount.dart';
import 'package:Nesto/widgets/custom_row_myaccount.dart';
import 'package:Nesto/widgets/inaam_bar_code_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../utils/util.dart';
import 'my_inaam.dart';

class MyAccountScreen extends StatefulWidget {
  @override
  _MyAccountScreenState createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  //key
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String currentVersion;
  bool showInaamBarCodeWidget;
  Future _inaamFuture;
  final AnalyticsService analyticsService = locator.get<AnalyticsService>();
  getVersion() {
    String env = FlavorConfig.instance.variables["env"].toUpperCase();
    return FutureBuilder(
        future: PackageInfo.fromPlatform(),
        builder: (_, snapshot) {
          var data = snapshot.data;
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              var buildNum = data?.buildNumber;
              var version = data?.version;
              var appVersion = 'v$version ($buildNum${env[0]})';
              return Text(
                appVersion,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              );
              break;
            case ConnectionState.waiting:
              return Center(
                  child: SizedBox.fromSize(
                size: Size(
                  ScreenUtil().setWidth(7),
                  ScreenUtil().setWidth(7),
                ),
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.grey),
                  strokeWidth: ScreenUtil().setWidth(1),
                ),
              ));
            default:
              return Text('--');
              break;
          }
        });
  }

  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "My Account Screen");
    _inaamFuture = getInaam();
    super.initState();
  }

  Future getInaam() async {
    try {
      var authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (isAuthTokenValid() && authProvider.magentoUser != null) {
        //init is being called multiple times dont call if already called.
        authProvider.getInaamPointsCall(shouldNotify: false).then((value) {
          if (authProvider.showInaamRetryButton) {
            showError(context,
                strings.COULD_NOT_FETCH_INAAM_DETAILS_PLEASE_TRY_AGAIN);
          }
        });
        return;
      }
      if (isAuthTokenValid()) {
        if (authProvider.magentoUser == null) {
          await authProvider.fetchMagentoUser();
          authProvider.getInaamPointsCall(shouldNotify: false).then((value) {
            if (authProvider.showInaamRetryButton) {
              showError(context,
                  strings.COULD_NOT_FETCH_INAAM_DETAILS_PLEASE_TRY_AGAIN);
            }
          });
        } else if (authProvider.magentoUser != null) {
          authProvider.getInaamPointsCall(shouldNotify: false).then((value) {
            if (authProvider.showInaamRetryButton) {
              showError(context,
                  strings.COULD_NOT_FETCH_INAAM_DETAILS_PLEASE_TRY_AGAIN);
            }
          });
        }
      }
    } catch (e) {
      Future.delayed(Duration(milliseconds: 100), () {
        showError(context, strings.SOMETHING_WENT_WRONG_RETRY);
      });
      return Future.error(strings.SOMETHING_WENT_WRONG_RETRY);
    }
  }

  onPressRestart() {
    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.setShowInaamRetryButton = false;
    authProvider.setShowInaamRetryLoading = true;
    print("on_restart called");
    setState(() {
      _inaamFuture = getInaam();
    });
  }

  _logout() async {
    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    var storeProvider = Provider.of<StoreProvider>(context, listen: false);
    try {
      easyLoadingService.showEasyLoading();
      if (authProvider.magentoUser != null) {
        await authProvider.registerFcmTokenInLambda(removeToken: true);
      }
      storeProvider.shippingAddress = null;
      storeProvider.recentSearches.clear();

      // WidgetsFlutterBinding.ensureInitialized();
      setState(() {
        clearAuthToken();
      });
      storeProvider.clearWishlist();
      storeProvider.resetCart(true);
      storeProvider.resetHasCartBeenFetchedInitially();
      authProvider.resetInaamDetails = "";
      try {
        await LocalStorage().clearCart();
      } catch (e) {
        print(e.toString());
      }
      easyLoadingService.hideEasyLoading();
      showInfo(context,
          strings.YOU_ARE_LOGGED_OUT_PLEASE_SIGN_IN_aGAIN_TO_CONTINUE_SHOPPING);
      //firebase logging.

      firebaseAnalytics.logout();
    } catch (e) {
      print("======================>");
      print("error is: $e");
      print("<======================");

      easyLoadingService.hideEasyLoading();
      showError(context, strings.FAILED_TO_LOGGED_OUT_TRY_AGAIN_LATER);
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);

    var authProvider = Provider.of<AuthProvider>(context);
    var storeProvider = Provider.of<StoreProvider>(context, listen: false);
    User magentoUser = authProvider.magentoUser;

    // logOutUserFunction() async {
    //   if (authProvider.logOutUser) {
    //     await Future.delayed(Duration.zero, () {
    //       easyLoadingService.hideEasyLoading();
    //       logNesto("Logout user");
    //       storeProvider.shippingAddress = null;
    //       storeProvider.recentSearches.clear();

    //       //firebase logging.
    //       analyticsService.logout();
    //       WidgetsFlutterBinding.ensureInitialized();
    //       clearAuthToken();
    //       storeProvider.clearWishlist();
    //       storeProvider.resetCart(true);
    //       storeProvider.resetHasCartBeenFetchedInitially();
    //       authProvider.logOutUser = false;
    //       showInfo(context,
    //           "You are logged out,Please sign in again to continue shopping");
    //     });
    //   }
    //   if (authProvider.logOutUserFailed) {
    //     await Future.delayed(Duration.zero, () {
    //       easyLoadingService.hideEasyLoading();
    //       authProvider.logOutUserFailed = false;
    //       showError(context, "Failed to logged out,Try again later");
    //     });
    //   }
    // }

    // logOutUserFunction();

    return Scaffold(
      key: _scaffoldKey,
      // appBar: rootHeaderBar(
      //     context: context,
      //     showSearchBar: false,
      //     onPress: () =>
      //         Navigator.of(context).pushNamed(SearchScreen.routeName),
      //     title: strings.my_acount),
      backgroundColor: Colors.white,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: ScreenUtil().setWidth(20.0),
                    right: ScreenUtil().setWidth(20.0),
                    bottom: ScreenUtil().setHeight(30.0)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    isAuthTokenValid()
                        ? SizedBox(
                            height: ScreenUtil().setHeight(10),
                          )
                        : Container(),
                    isAuthTokenValid()
                        ? titleText(title: strings.PROFILE)
                        : Container(),
                    isAuthTokenValid()
                        ? AccountFutureWidget(
                            inaamFuture: _inaamFuture,
                            size: Size(
                                double.infinity, ScreenUtil().setWidth(90)),
                            onPressRestart: onPressRestart,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () =>
                                      !easyLoadingService.easyLoadingStatus &&
                                              magentoUser != null
                                          ? Navigator.pushNamed(
                                              context, ProfileScreen.routeName)
                                          : null,
                                  child: ContainerCustom(
                                    text1: magentoUser != null
                                        ? magentoUser.firstName
                                        : "",
                                    text2: "",
                                    widget: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          magentoUser != null
                                              ? magentoUser.emailAddress
                                              : "",
                                          style: TextStyle(
                                            color: Colors.black26,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(
                                          height: ScreenUtil().setHeight(5),
                                        ),
                                        Text(
                                          magentoUser != null
                                              ? magentoUser.phoneNumber
                                              : "",
                                          style: TextStyle(
                                            color: Colors.black26,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(),
                    isAuthTokenValid() &&
                            authProvider.magentoUser != null &&
                            authProvider.inaamCode != null &&
                            authProvider.inaamCode != "" &&
                            authProvider.inaamCode != "NULL"
                        ? SizedBox(
                            height: ScreenUtil().setHeight(10),
                          )
                        : Container(),
                    isAuthTokenValid() &&
                            authProvider.magentoUser != null &&
                            authProvider.inaamCode != null &&
                            authProvider.inaamCode != "" &&
                            authProvider.inaamCode != "NULL"
                        ? AccountFutureWidget(
                            inaamFuture: _inaamFuture,
                            size: Size(
                                double.infinity, ScreenUtil().setWidth(150)),
                            child: Column(
                              children: [
                                InaamBarCodeWidget(
                                  onTap: () async {
                                    if (!easyLoadingService.easyLoadingStatus &&
                                        !authProvider.showInaamRetryButton &&
                                        !authProvider
                                            .getShowInaamRetryLoading) {
                                      Navigator.pushNamed(
                                          context, MyInaam.routeName);
                                    } else if (!easyLoadingService
                                            .easyLoadingStatus &&
                                        authProvider.showInaamRetryButton &&
                                        !authProvider
                                            .getShowInaamRetryLoading) {
                                      await authProvider
                                          .getInaamPointsCall()
                                          .then((value) {
                                        if (!authProvider
                                            .showInaamRetryButton) {
                                          Navigator.pushNamed(
                                              context, MyInaam.routeName);
                                        } else if (authProvider
                                            .showInaamRetryButton) {
                                          showError(
                                              context,
                                              strings
                                                  .COULD_NOT_FETCH_INAAM_DETAILS_PLEASE_TRY_AGAIN);
                                        }
                                      });
                                    } else {}
                                  },
                                ),
                              ],
                            ),
                          )
                        : Container(),
                    isAuthTokenValid()
                        ? SizedBox(
                            height: ScreenUtil().setHeight(10),
                          )
                        : Container(),
                    isAuthTokenValid()
                        ? titleText(title: strings.ORDER_INFORMATION)
                        : Container(),
                    isAuthTokenValid()
                        ? AccountFutureWidget(
                            inaamFuture: _inaamFuture,
                            size: Size(
                                double.infinity, ScreenUtil().setWidth(110)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xffFAFAFA),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            ScreenUtil().setWidth(23.0)),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomRow(
                                          icon: Icons.shopping_cart_outlined,
                                          text: strings.MY_ORDERS,
                                          onPress: () {
                                            if (!easyLoadingService
                                                .easyLoadingStatus) {
                                              Navigator.pushNamed(context,
                                                  OrderScreen.routeName);
                                            }
                                          },
                                        ),
                                        Visibility(
                                            visible: false,
                                            child: Divider(height: 1)),
                                        Visibility(
                                          visible: false,
                                          child: CustomRow(
                                            icon: Icons.credit_card_outlined,
                                            text: strings.PAYMENT_METHODS,
                                          ),
                                        ),
                                        Divider(height: 1),
                                        Visibility(
                                          visible: ((isAuthTokenValid()) &&
                                                  (authProvider.magentoUser !=
                                                      null))
                                              ? true
                                              : false,
                                          child: CustomRow(
                                              icon: Icons.location_on_outlined,
                                              text: strings.Address_Book,
                                              onPress: () {
                                                if (!easyLoadingService
                                                    .easyLoadingStatus) {
                                                  Navigator.pushNamed(
                                                      context,
                                                      AddressBookScreen
                                                          .routeName);
                                                }
                                              }),
                                        ),
                                        Divider(height: 1),
                                        Visibility(
                                          visible: ((isAuthTokenValid()) &&
                                                  (authProvider.magentoUser !=
                                                      null))
                                              ? true
                                              : false,
                                          child: CustomRow(
                                              icon: Icons
                                                  .notifications_none_outlined,
                                              text: "Notifications",
                                              onPress: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            NotificationListingScreen()));
                                              }),
                                        ),
                                        Divider(height: 1),
                                        Visibility(
                                          visible: ((isAuthTokenValid()) &&
                                                  (authProvider.magentoUser !=
                                                      null))
                                              ? true
                                              : false,
                                          child: CustomRow(
                                              icon: Icons.favorite_border,
                                              text: "Favorites",
                                              onPress: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        WishListScreen(),
                                                  ),
                                                );
                                              }),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(),
                    isAuthTokenValid()
                        ? SizedBox(
                            height: ScreenUtil().setHeight(10),
                          )
                        : Container(),
                    titleText(title: 'Application'),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xffFAFAFA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setWidth(23.0)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomRow(
                              svgIcon:
                                  SvgPicture.asset("assets/svg/referals.svg"),
                              text: strings.REFER_A_FRIEND,
                              onPress: () {
                                if (!easyLoadingService.easyLoadingStatus) {
                                  //firebase analytics logging.
                                  firebaseAnalytics.referAFriend();

                                  Navigator.pushNamed(
                                      context, ReferralScreen.routeName);
                                }
                              },
                            ),
                            // #FEEDBACK
                            Divider(height: 1),
                            CustomRow(
                                icon: Icons.feedback_outlined,
                                text: strings.FEEDBACK_HEADER,
                                onPress: () {
                                  Navigator.of(context)
                                      .pushNamed(FeedbackScreen.routeName);
                                }),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(20),
                    ),
                    // Text(
                    //   "Application",
                    //   style: TextStyle(
                    //     color: Colors.black,
                    //     fontSize: 17,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    // SizedBox(
                    //   height: ScreenUtil().setHeight(15),
                    // ),
                    Visibility(
                      visible: false,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xffFAFAFA),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil().setWidth(23.0)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomRow(
                                icon: Icons.settings,
                                text: strings.SETTINGS,
                              ),
                              Divider(),
                              CustomRow(
                                icon: Icons.notifications_outlined,
                                text: strings.NOTIFICATIONS,
                              ),
                              Divider(),
                              CustomRow(
                                icon: Icons.star,
                                text: strings.MY_WISHLIST,
                              ),
                              Divider(),
                              CustomRow(
                                icon: Icons.room_service_outlined,
                                text: strings.MY_REFERALS,
                              ),
                              Divider(),
                              CustomRow(
                                icon: Icons.room_preferences_outlined,
                                text: strings.MY_STATISTICS,
                                onPress: () {},
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(20),
                    ),
                    Text(
                      strings.HELP,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(15),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(23.0),
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xffFAFAFA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomRow(
                            icon: Icons.language_outlined,
                            text: strings.About_Nesto,
                            onPress: () {
                              if (!easyLoadingService.easyLoadingStatus) {
                                //firebase analytics logging.
                                firebaseAnalytics.aboutNesto();

                                Navigator.of(context)
                                    .pushNamed(AboutScreen.routeName);
                              }
                            },
                          ),
                          Divider(height: 1),
                          CustomRow(
                            icon: Icons.policy_outlined,
                            text: strings.TERMS_AND_CONDITIONS,
                            onPress: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WebViewScreen(
                                    title: strings.TERMS_AND_CONDITIONS,
                                    url: 'https://docs.nesto.shop/Terms.html',
                                  ),
                                ),
                              );
                            },
                          ),
                          Divider(height: 1),
                          CustomRow(
                            icon: Icons.privacy_tip_outlined,
                            text: strings.PRIVACY_POLICY,
                            onPress: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WebViewScreen(
                                    title: strings.PRIVACY_POLICY,
                                    url: 'https://docs.nesto.shop/Privacy.pdf',
                                  ),
                                ),
                              );
                            },
                          ),
                          Divider(height: 1),
                          CustomRow(
                            icon: Icons.comment_bank_outlined,
                            text: strings.Contact_Us,
                            onPress: () {
                              if (!easyLoadingService.easyLoadingStatus) {
                                //firebase analytics logging.
                                firebaseAnalytics.logContactUs();

                                Navigator.of(context)
                                    .pushNamed(ContactUsScreen.routeName);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(18),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (!easyLoadingService.easyLoadingStatus) {
                          if (isAuthTokenValid()) {
                            notificationServices.showCustomDialog(
                                title: strings.Logout,
                                description:
                                    strings.ARE_YOU_SURE_YOU_WANT_TO_LOG_OUT,
                                negativeText: strings.NO,
                                positiveText: strings.YES,
                                action: () {
                                  _logout();
                                });
                          } else {
                            Navigator.of(context)
                                .pushNamed(LoginScreen.routeName);
                          }
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xffFAFAFA),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil().setWidth(23.0)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomRow(
                                icon: isAuthTokenValid()
                                    ? Icons.logout
                                    : Icons.login,
                                text: isAuthTokenValid()
                                    ? strings.Log_Out
                                    : strings.LOG_IN,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(30),
                    ),
                    Center(
                      child: Text(
                        strings.POWERED_BY,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Center(
                      child: GestureDetector(
                        onLongPress: () {
                          if (!easyLoadingService.easyLoadingStatus) {
                            showInfo(context,
                                FlavorConfig.instance.variables["env"]);
                          }
                        },
                        child: SizedBox(
                          height: ScreenUtil().setHeight(50),
                          width: ScreenUtil().setWidth(110),
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Image.asset(
                              'assets/images/nestologo.webp',
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setWidth(15)),
                    Center(
                      child: getVersion(),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget titleText({@required String title}) {
    return Padding(
      padding: EdgeInsets.only(
          top: ScreenUtil().setHeight(20.0),
          bottom: ScreenUtil().setHeight(15.0)),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.black,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class AccountFutureWidget extends StatelessWidget {
  AccountFutureWidget({
    Key key,
    @required this.inaamFuture,
    @required this.child,
    @required this.size,
    this.onPressRestart,
  });

  final Future inaamFuture;
  final Widget child;
  final Size size;
  final Function onPressRestart;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: inaamFuture,
      builder: (_, snapshot) {
        Widget _child;
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            _child = Shimmer.fromColors(
              baseColor: Color(0xffFAFAFA),
              highlightColor: Color(0xFFEBEBF4),
              direction: ShimmerDirection.ltr,
              child: Container(
                width: size.width ?? double.infinity,
                height: size.height ?? ScreenUtil().setHeight(100.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.white),
              ),
            );

            break;
          case ConnectionState.done:
            if (snapshot.hasError) {
              _child = Container(
                width: size.width ?? double.infinity,
                height: size.height ?? ScreenUtil().setHeight(100.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Color(0xffFAFAFA)),
                child: Visibility(
                  visible: onPressRestart != null,
                  child: Center(
                    child: SizedBox(
                      height: 40,
                      width: 40,
                      child: RawMaterialButton(
                        onPressed: onPressRestart,
                        elevation: 2.0,
                        fillColor: values.NESTO_GREEN,
                        child: Center(
                          child: Icon(
                            Icons.refresh_rounded,
                            color: Colors.white,
                          ),
                        ),
                        padding: EdgeInsets.all(5.0),
                        shape: CircleBorder(side: BorderSide.none),
                      ),
                    ),
                  ),
                ),
              );
            } else {
              _child = child;
            }
            break;
          default:
            _child = Container();
            break;
        }
        return AnimatedSwitcher(
          switchInCurve: Curves.fastOutSlowIn,
          duration: Duration(milliseconds: 500),
          child: _child,
        );
      },
    );
  }
}
