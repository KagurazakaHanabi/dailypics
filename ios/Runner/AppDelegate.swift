import UIKit
import Flutter
import Photos

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
    ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    PHPhotoLibrary.requestAuthorization({status in
        // do nothing.
    })
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
