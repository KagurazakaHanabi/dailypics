import UIKit
import Flutter
import Photos

@UIApplicationMain
class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "ml.cerasus.pics", binaryMessenger: controller)
    channel.setMethodCallHandler({
        (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        guard call.method == "syncAlbum" else {
            result(FlutterMethodNotImplemented)
            return
        }
        self.syncAlbum(file: call.arguments as! String, result: result)
    })
    GeneratedPluginRegistrant.register(with: self)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    private func syncAlbum(file: String, result: @escaping FlutterResult) {
        PHPhotoLibrary.requestAuthorization({status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: URL.init(string: file)!)
                }, completionHandler: { (success: Bool, error: Error?) in
                    if success {
                        result(nil)
                    } else {
                        result(FlutterError(code: "Unexpected exception.", message: nil, details: nil))
                    }
                })
            } else {
                result(FlutterError(code: "Permission Denied", message: nil, details: nil))
            }
        })
    }
}
