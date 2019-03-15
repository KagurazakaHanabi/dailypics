import UIKit
import Flutter
import Photos

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
    ) -> Bool {
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "ml.cerasus.pics", binaryMessenger: controller)
    channel.setMethodCallHandler({
        (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        guard call.method == "syncGallery" else {
            result(FlutterMethodNotImplemented)
            return
        }
        self.syncGallery(file: call.arguments as! String, result: result)
    })
    GeneratedPluginRegistrant.register(with: self)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    private func syncGallery(file: String, result: @escaping FlutterResult) {
        PHPhotoLibrary.requestAuthorization({status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: URL.init(string: file)!)
                }, completionHandler: { (success: Bool, error: Error?) in
                    if success {
                        result(nil) // 因为是 iOS 所以不需要返回相册中的路径
                    } else {
                        result(FlutterError(code: "Permission Denied", message: nil, details: nil))
                        
                    }
                })
                result("")
            } else {
                result(FlutterError(code: "Permission Denied", message: nil, details: nil))
            }
        })
    }
}
