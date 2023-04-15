import 'package:Nesto/services/api_service.dart';
import 'package:Nesto/services/easy_loading_service.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/services/firebase_cloud_messaging.dart';
import 'package:Nesto/services/navigation_service.dart';
import 'package:Nesto/services/notification_service.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerSingleton<NavigationService>(NavigationService());
  locator.registerSingleton<NotificationService>(NotificationService());
  locator.registerLazySingleton<AnalyticsService>(() => AnalyticsService());
  locator.registerLazySingleton<FirebaseCloudMessaging>(
      () => FirebaseCloudMessaging());
  locator.registerLazySingleton<ApiService>(() => ApiService());
  locator.registerSingleton<EasyLoadingService>(EasyLoadingService());
}
