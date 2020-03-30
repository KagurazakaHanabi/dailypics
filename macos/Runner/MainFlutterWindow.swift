import Cocoa
import FlutterMacOS
import Photos
import StoreKit

class MainFlutterWindow: NSWindow {
    override func awakeFromNib() {
        let controller = FlutterViewController.init()
        let windowFrame = self.frame
        self.contentViewController = controller
        self.setFrame(windowFrame, display: true)
        
        let channel = FlutterMethodChannel(name: "ml.cerasus.pics", binaryMessenger: controller.engine.binaryMessenger)
        channel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            switch call.method {
            case "share":
                let arguments = call.arguments as! Dictionary<String, Any>;
                let originX = arguments["originX"] as! Double, originY = arguments["originY"] as! Double;
                let originWidth = arguments["originWidth"] as! Double, originHeight = arguments["originHeight"] as! Double;
                var originRect: NSRect? = nil;
                if originX != nil && originY != nil && originWidth != nil && originHeight != nil {
                    originRect = NSRect.init(x: originWidth / 2, y: originY + originHeight, width: originWidth, height: originHeight)
                }
                self.share(file: arguments["file"]! as! String, atSource: originRect, result: result)
            case "useAsWallpaper":
                self.useAsWallpaper(file: call.arguments as! String, result: result)
            case "requestReview":
                self.requestReview(inApp: call.arguments as! Bool, result: result)
            case "isAlbumAuthorized":
                self.isAlbumAuthorized(result: result)
            case "openAppSettings":
                self.openAppSettings(result: result)
            case "syncAlbum":
                self.syncAlbum(file: (call.arguments as! Dictionary<String, String>)["file"]!, result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        })
        
        RegisterGeneratedPlugins(registry: controller)
        super.awakeFromNib()
    }
    
    private func share(file: String, atSource: NSRect?, result: FlutterResult) {
        do {
            let data = NSImage(data: try Data(contentsOf: URL.init(string: "file://" + file)!))
            let picker = NSSharingServicePicker(items: [data as Any])
            picker.show(relativeTo: atSource!, of: contentViewController!.view, preferredEdge: .maxY)
            result(nil)
        } catch let error {
            result(FlutterError(code: "0", message: error.localizedDescription, details: nil))
        }
    }
    
    private func useAsWallpaper(file: String, result: FlutterResult) {
        result(FlutterMethodNotImplemented)
    }
    
    private func requestReview(inApp: Bool, result: FlutterResult) {
        if inApp, #available(OSX 10.14, *) {
            SKStoreReviewController.requestReview();
            result(nil)
        } else {
            let url = "itms-apps://itunes.apple.com/app/id1457009047?action=write-review"
            NSWorkspace.shared.open(URL.init(string: url)!)
            result(nil)
        }
    }
    
    private func isAlbumAuthorized(result: FlutterResult) {
        let status = PHPhotoLibrary.authorizationStatus()
        result(status == .authorized || status == .notDetermined)
    }

    private func openAppSettings(result: FlutterResult) {
        result(FlutterMethodNotImplemented)
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
