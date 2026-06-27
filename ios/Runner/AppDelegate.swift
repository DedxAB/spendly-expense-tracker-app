import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  let blurViewTag = 9999

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func applicationDidEnterBackground(_ application: UIApplication) {
    let blurEffect = UIBlurEffect(style: .dark)
    let blurView = UIVisualEffectView(effect: blurEffect)
    blurView.frame = window?.bounds ?? UIScreen.main.bounds
    blurView.tag = blurViewTag
    window?.addSubview(blurView)
  }

  override func applicationWillEnterForeground(_ application: UIApplication) {
    if let blurView = window?.viewWithTag(blurViewTag) {
      blurView.removeFromSuperview()
    }
  }
}
