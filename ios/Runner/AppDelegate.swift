import UIKit
import Flutter
import Security

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    private let CHANNEL = "biometric_channel"

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller = window.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: CHANNEL, binaryMessenger: controller.binaryMessenger)
        channel.setMethodCallHandler { [weak self] call, result in
            if call.method == "performSigning" {
                guard let data = call.arguments as? [String: Any],
                      let inputData = data["data"] as? String else {
                    result(FlutterError(code: "INVALID_DATA", message: "Data is invalid", details: nil))
                    return
                }
                let signature = self?.performSigning(data: inputData)
                result(signature)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func performSigning(data: String) -> String? {
        // Replace this with your actual signing logic using iOS Keychain and Security Framework
        guard let privateKey = getPrivateKey() else { return nil }
        let inputData = Data(data.utf8)
        
        var error: Unmanaged<CFError>?
        guard let signature = SecKeyCreateSignature(privateKey, .rsaSignatureMessagePKCS1v15SHA256, inputData as CFData, &error) else {
            print("Error creating signature: \(error!.takeRetainedValue() as Error)")
            return nil
        }

        return (signature as Data).base64EncodedString()
    }

    // private func getPrivateKey() -> SecKey? {
    //     // Implement fetching private key from iOS Keychain
    //     // Return the private key for signing
    //     // Replace this with your actual private key retrieval logic
    //     return nil
    // }
}
