import Flutter
import Photos
import UIKit
import StoreKit

@UIApplicationMain
class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
        ) -> Bool {
        let controller: FlutterViewController = window.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: "ml.cerasus.pics", binaryMessenger: controller.binaryMessenger)
        channel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            switch call.method {
            case "share":
                self.share(imageFile: call.arguments as! String, result: result)
            case "requestReview":
                self.requestReview(inApp: call.arguments as! Bool, result: result)
            case "isAlbumAuthorized":
                self.isAlbumAuthorized(result: result)
            case "openAppSettings":
                self.openAppSettings(result: result)
            case "syncAlbum":
                self.syncAlbum(file: call.arguments as! String, result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        })
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func share(imageFile: String, result: FlutterResult) {
        do {
            let data = try Data(contentsOf: URL.init(string: "file://" + imageFile)!)
            let controller = UIActivityViewController.init(activityItems: [UIImage(data: data) as Any], applicationActivities: nil)
            window.rootViewController!.present(controller, animated: true, completion: nil)
            result(nil)
        } catch let error {
            result(FlutterError(code: "0", message: error.localizedDescription, details: nil))
        }
    }

    private func requestReview(inApp: Bool, result: FlutterResult) {
        if inApp && #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview();
            result(nil)
        } else {
            // TODO 2019-08-16: 唤起 App Store 撰写评论页面
        }
    }

    private func isAlbumAuthorized(result: FlutterResult) {
        let status = PHPhotoLibrary.authorizationStatus()
        result(status == .authorized || status == .notDetermined)
    }

    private func openAppSettings(result: FlutterResult) {
        let url = NSURL(string: UIApplicationOpenSettingsURLString)!
        UIApplication.sharedApplication().openURL(url)
        result(nil)
    }
    
    private func syncAlbum(file: String, result: @escaping FlutterResult) {
        PHPhotoLibrary.requestAuthorization({status in
            if status == .authorized {
                let albums: PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
                var album: PHAssetCollection? = nil;
                for i in 0..<albums.count {
                    if albums.object(at: i).localizedTitle == "图鉴日图" {
                        album = albums.object(at: i)
                        break
                    }
                }
                if album == nil {
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: "图鉴日图")
                    }, completionHandler: { (success: Bool, error: Error?) in
                        if success {
                            self.syncAlbum(file: file, result: result)
                        } else {
                            result(FlutterError(code: "0", message: error?.localizedDescription, details: nil))
                        }
                    })
                } else {
                    PHPhotoLibrary.shared().performChanges({
                        let request = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: URL.init(string: file)!)
                        let placeholder = request!.placeholderForCreatedAsset
                        let albumRequest = PHAssetCollectionChangeRequest.init(for: album!)
                        albumRequest!.addAssets([placeholder!] as NSArray)
                    }, completionHandler: { (success: Bool, error: Error?) in
                        if success {
                            result(nil)
                        } else {
                            result(FlutterError(code: "0", message: error?.localizedDescription, details: nil))
                        }
                    })
                    
                }
            } else {
                result(FlutterError(code: "-1", message: "Permission Denied", details: nil))
            }
        })
    }
}
