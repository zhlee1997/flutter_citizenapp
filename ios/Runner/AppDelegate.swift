import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let channel:FlutterMethodChannel = FlutterMethodChannel.init(name: "com.sma.citizen_mobile/main", binaryMessenger: controller.binaryMessenger)
    channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
        if (call.method == "spayPlaceOrder") {
            let spay = SarawakSDK.defaultService()
            spay?.urlScheme = "citizenMobile"
            if let arg = call.arguments as? NSDictionary {
                
                if UIApplication.shared.canOpenURL(URL.init(string: "sarawakpay://merchantappscheme?$encryptionData")!) {
                    spay?.callSPay(arg["dataString"] as? String)
                }
            }
        }
    }

    FlutterJlBluetoothPlugin.plugin.register(messenger: controller.binaryMessenger)

    GMSServices.provideAPIKey("AIzaSyCa6Dcq2d37Loi05SOL4l_FPud_GNqnkP8")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        verify(url: url)
        return true
    }
    
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        verify(url: url)
        return true
    }
    
    func verify(url:URL) {
        if url.host == "sarawakpay" {
            if let e = FlutterJlBluetoothPlugin.plugin.eSink {
                e(url.query)
            }
        }
    }
}
