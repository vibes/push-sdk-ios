import UIKit
import UserNotifications
import VibesPush

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        registerForPushNotifications()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
}

extension AppDelegate: VibesAPIDelegate {
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, _) in
            print("Permission granted: \(granted)")
            guard granted else { return }
            DispatchQueue.main.async {
                Vibes.configure(appId: "appId")
                Vibes.shared.set(delegate: self)
                
                Vibes.shared.registerDevice()
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        // Save to userdefaults
        let defaults = UserDefaults.standard
        defaults.set(token, forKey: "deviceToken")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications with error: \(error)")
    }
    
    // MARK: - Application-specific handling of push notification
    func handlePushNotification(userInfo: [AnyHashable: Any]) {
        print("received push with details: \(userInfo)")
    }
    
    // MARK: - VibesAPIDelegate
    // Callback for when the device is registered with Vibes
    func didRegisterDevice(deviceId: String?, error: Error?) {
        print("didRegisterDevice - \(successOrError(error, fallback: "deviceId: \(deviceId ?? ""))"))")
    }
    
    // Callback for when the device is unregistered with Vibes
    func didUnregisterDevice(error: Error?) {
        print("didUnregisterDevice - \(successOrError(error))")
    }
    
    // Callback for when the device's push token is sent to Vibes
    func didRegisterPush(error: Error?) {
        print("didRegisterPush - \(successOrError(error))")
    }
    
    // Callback for when the device's push token is removed from Vibes
    func didUnregisterPush(error: Error?) {
        print("didUnregisterPush - \(successOrError(error))")
    }
    
    // Callback for when the device's location is updated
    func didUpdateDeviceLocation(error: Error?) {
        print("didUpdateDeviceLocation - \(successOrError(error))")
    }
    
    // A small utility function to either display an error or success message
    private func successOrError(_ error: Error?, fallback: String = "success") -> String {
        if let error = error {
            return "error: \(error)"
        } else {
            return fallback
        }
    }
}
