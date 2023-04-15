import UIKit
import Flutter
import GoogleMaps


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    #if DEV
        GMSServices.provideAPIKey("AIzaSyAimaNx9Tt9eNjl_urKFci2g_aom8n0hno")
    #elseif PRODUCTION
        GMSServices.provideAPIKey("AIzaSyDLG4LWs4cAdr03jGfJy3DcPuJHQSRz54Q")
    #endif
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
