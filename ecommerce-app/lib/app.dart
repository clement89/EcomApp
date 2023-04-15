import 'package:Nesto/providers/auth_provider.dart';
import 'package:Nesto/providers/home_builder_provider.dart';
import 'package:Nesto/providers/notification_provider.dart';
import 'package:Nesto/providers/orders_provider.dart';
import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/providers/substitution_provider.dart';
import 'package:Nesto/screens/about_screen.dart';
import 'package:Nesto/screens/add_address.dart';
import 'package:Nesto/screens/add_new_card.dart';
import 'package:Nesto/screens/address_book_screen.dart';
import 'package:Nesto/screens/base_screen.dart';
import 'package:Nesto/screens/cart_screen.dart';
import 'package:Nesto/screens/category_screen.dart';
import 'package:Nesto/screens/catogory_listing_page.dart';
import 'package:Nesto/screens/checkout_screen.dart';
import 'package:Nesto/screens/contact_us_screen.dart';
import 'package:Nesto/screens/delivery_rating.dart';
import 'package:Nesto/screens/edit_address_screen.dart';
import 'package:Nesto/screens/edit_order_screen.dart';
import 'package:Nesto/screens/error_screen.dart';
import 'package:Nesto/screens/feedback_screen.dart';
import 'package:Nesto/screens/filter_scren.dart';
import 'package:Nesto/screens/image_zoom.dart';
import 'package:Nesto/screens/location_screen.dart';
import 'package:Nesto/screens/login_screen.dart';
import 'package:Nesto/screens/merchandise_category_listing_screen.dart';
import 'package:Nesto/screens/my_inaam.dart';
import 'package:Nesto/screens/notification_listing_screen.dart';
import 'package:Nesto/screens/onboarding_screen.dart';
import 'package:Nesto/screens/order_cancellation.dart';
import 'package:Nesto/screens/order_listing_screen.dart';
import 'package:Nesto/screens/order_screen.dart';
import 'package:Nesto/screens/order_success_screen.dart';
import 'package:Nesto/screens/otp_verification_screen.dart';
import 'package:Nesto/screens/payment_canceled_screen.dart';
import 'package:Nesto/screens/payment_failure_screen.dart';
import 'package:Nesto/screens/payment_gateway_webpage.dart';
import 'package:Nesto/screens/payment_status_check_screen.dart';
import 'package:Nesto/screens/payment_success_page.dart';
import 'package:Nesto/screens/product_details.dart';
import 'package:Nesto/screens/product_list_orders.dart';
import 'package:Nesto/screens/product_listing_screen.dart';
import 'package:Nesto/screens/profile_screen.dart';
import 'package:Nesto/screens/rate_experience.dart';
import 'package:Nesto/screens/referal_screen.dart';
import 'package:Nesto/screens/replace_return_succes_screen.dart';
import 'package:Nesto/screens/return_confirm_screen.dart';
import 'package:Nesto/screens/return_order_screen.dart';
import 'package:Nesto/screens/search_screen.dart';
import 'package:Nesto/screens/sign_up_screen.dart';
import 'package:Nesto/screens/sort_filter_screen.dart';
import 'package:Nesto/screens/splash_screen.dart';
import 'package:Nesto/screens/substitution_order_screen.dart';
import 'package:Nesto/screens/view_more_screen.dart';
import 'package:Nesto/screens/view_more_with_navigation.dart';
import 'package:Nesto/screens/wishlist_screen.dart';
import 'package:Nesto/service_locator.dart';
import 'package:Nesto/services/connectivity_check_service.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/services/navigation_service.dart';
import 'package:country_code_picker/country_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import 'screens/splash_screen.dart';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => StoreProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => OrderProvider()),
        ChangeNotifierProvider(create: (context) => SubstitutionProvider()),
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
        // ChangeNotifierProvider.value(value: StoreProvider()),
        // ChangeNotifierProvider.value(value: AuthProvider()),
        // ChangeNotifierProvider.value(value: OrderProvider()),
        // ChangeNotifierProvider.value(value: SubstitutionProvider()),
        // ChangeNotifierProvider.value(value: NotificationProvider()),
        ChangeNotifierProvider(create: (context) => MultiHomePageProvider()),
      ],
      child: StreamProvider<ConnectivityStatus>(
        initialData: ConnectivityStatus.WiFi,
        create: (context) {
          return ConnectivityService().connectionStatusController.stream;
        },
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: locator<NavigationService>().navigatorKey,
          title: 'Nesto',
          supportedLocales: [
            Locale('en'),
          ],
          localizationsDelegates: [
            CountryLocalizations.delegate,
          ],
          navigatorObservers: [firebaseAnalytics.getAnalyticsObserver()],
          routes: {
            SplashScreen.routeName: (ctx) => SplashScreen(),
            BaseScreen.routeName: (ctx) => BaseScreen(),
            LoginScreen.routeName: (ctx) => LoginScreen(),
            SignUpScreen.routeName: (ctx) => SignUpScreen(),
            OnBoardingScreen.routeName: (ctx) => OnBoardingScreen(),
            CategoryScreen.routeName: (ctx) => CategoryScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            WishListScreen.routeName: (ctx) => WishListScreen(),
            SearchScreen.routeName: (ctx) => SearchScreen(),
            OrderScreen.routeName: (ctx) => OrderScreen(),
            OrderListingScreen.routeName: (ctx) => OrderListingScreen(),
            ProductListDisplay.routeName: (ctx) => ProductListDisplay(),
            CategoryListing.routeName: (ctx) => CategoryListing(),
            ProfileScreen.routeName: (ctx) => ProfileScreen(),
            ProductDetail.routeName: (ctx) => ProductDetail(),
            CartScreen.routeName: (ctx) => CartScreen(),
            CheckoutScreen.routeName: (ctx) => CheckoutScreen(),
            EditOrder.routeName: (ctx) => EditOrder(),
            ReturnReplaceScreen.routeName: (ctx) => ReturnReplaceScreen(),
            PaymentSuccessfullScreen.routeName: (ctx) =>
                PaymentSuccessfullScreen(),
            OrderSuccessfullScreen.routeName: (ctx) => OrderSuccessfullScreen(),
            RateExperience.routeName: (ctx) => RateExperience(),
            ContactUsScreen.routeName: (ctx) => ContactUsScreen(),
            AboutScreen.routeName: (ctx) => AboutScreen(),
            LocationScreen.routeName: (ctx) => LocationScreen(),
            FilterScreen.routeName: (ctx) => FilterScreen(),
            OtpVerificationScreen.routeName: (ctx) => OtpVerificationScreen(),
            PaymentGatewayWebpage.routeName: (ctx) => PaymentGatewayWebpage(),
            PaymentStatusCheckScreen.routeName: (ctx) =>
                PaymentStatusCheckScreen(),
            PaymentFailureScreen.routeName: (ctx) => PaymentFailureScreen(),
            PaymentCancelScreen.routeName: (ctx) => PaymentCancelScreen(),
            OrderCancellation.routeName: (ctx) => OrderCancellation(),
            AddAddress.routeName: (ctx) => AddAddress(),
            EditAddressScreen.routeName: (ctx) => EditAddressScreen(),
            AddressBookScreen.routeName: (ctx) => AddressBookScreen(),
            AddNewCard.routeName: (ctx) => AddNewCard(),
            NotificationListingScreen.routeName: (ctx) =>
                NotificationListingScreen(),
            MerchandiseCategoryListingScreen.routeName: (ctx) =>
                MerchandiseCategoryListingScreen(),
            DeliveryRating.routeName: (ctx) => DeliveryRating(),
            ReferralScreen.routeName: (ctx) => ReferralScreen(),
            FeedbackScreen.routeName: (ctx) => FeedbackScreen(),
            ProductListingScreen.routeName: (ctx) => ProductListingScreen(),
            ViewMoreScreen.routeName: (ctx) => ViewMoreScreen(),
            MyInaam.routeName: (ctx) => MyInaam(),
            ViewMoreScreenWithNavigation.routeName: (ctx) =>
                ViewMoreScreenWithNavigation(),
            ErrorScreen.routeName: (ctx) => ErrorScreen(),
            SubstitutionOrderScreen.routeName: (ctx) =>
                SubstitutionOrderScreen(),
            ImageZoom.routeName: (ctx) => ImageZoom(),
            ReturnOrder.routeName: (ctx) => ReturnOrder(),
            ReturnConfirmScreen.routeName: (ctx) => ReturnConfirmScreen(),
            SortFilterScreen.routeName: (ctx) => SortFilterScreen(),
          },
          theme: ThemeData(
            primaryColor: Color(0xFF00AA07),
            backgroundColor: Colors.white,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: SplashScreen(),
          builder: EasyLoading.init(),
        ),
      ),
    );
  }
}
