# Vibes SDK - iOS

An iOS SDK for handling push integration with the [Vibes API][1].

SDK for Vibes push messaging.

- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Testing](#testing)

## Requirements <a name="requirements"></a>

- iOS 9.0+, iOS 10.0+
- Xcode 8.0+, Xcode 9.0+
- CocoaPods 1.1.0+

## Installing the Vibes Push iOS SDK <a name="installation"></a>
You can install the Vibes Push iOS SDK by using dependency managers, or by manually integrating it.

### Using CocoaPods Dependency Manager

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects that you can use to install the Vibes Push iOS SDK. Install CocoaPods using the following command:

```bash
$ gem install cocoapods
```

Once it's done, you can verify that it's installed correctly:

```bash
$ pod --version
```

If your application doesn't use Cocoapod, you can initialize a Podfile by running the following command:

```bash
$ pod init
```

Integrate VibesPush into your Xcode project using CocoaPods by specifying the following in your `Podfile`:

If your application is swift 3.x compatible (or Objc)

```ruby
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/vibes/pod_specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'VibesPush', '~> 0.0.5'
```

If your application is swift 4.x compatible (or Objc)

```ruby
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/vibes/pod_specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'VibesPush', '~> 1.0.5'
```

Run the following command:

```bash
$ pod install
```

### Manually Integrating Vibes Push

If you prefer not to use any of the aforementioned dependency managers, you can manually integrate VibesPush into your project.

#### Add the VibesPush.framework to Embedded Binaries

1. Download the `VibesPush.zip` from https://github.com/vibes/pod_specs/tree/master/VibesPush/. Version 0.0.x are for client applications compatible with Swift 3.x (and Objc) and Version 1.0.x are for client applications compatible with Swift 4.x (and Objc).
2. Unzip the archive you'll obtain `VibesPush.framework`
3. Select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window, then select the application target under the "Targets" heading in the sidebar.
4. In the tab bar at the top of that window, open the "General" panel.
5. Click the `+` button under the "Embedded Binaries" section.
6. Add the downloaded `VibesPush.framework`.
7. You might need to update the `Framework Search Path` in the tab `Build settings` and add the folder containing ` VibesPush.framework`.

And that's it!

## Usage <a name="usage"></a>

### Configuration

Add the following to your `application:didFinishLaunchingWithOptions` in your
`AppDelegate.swift` file:

```swift
Vibes.configure(appId: "MY_APP_ID")
```

If your application integrates AdSupport, you can specify the Advertisement
identifier:

```swift
Vibes.configure(appId: "MY_APP_ID", advertisingId: "MY_APP_ADV_ID")
```

### Registering a Device

Add the following lines to `application:didFinishLaunchingWithOptions`, or
wherever it makes the most sense for your application:

```swift
Vibes.shared.registerDevice { result in
  // This callback is optional. If you choose to use it, result will be a
  // VibesResult<Credential>.
}
```

### Unregistering a Device

You can add the following wherever it makes the most sense for your application:

```swift
Vibes.shared.unregisterDevice { result in
  // This callback is optional. If you choose to use it, result will be a
  // VibesResult<Void>.
}
```

### Registering for Push

1. Register for remote notifications by following [Apple's Local and Remote
   Notification Programming Guide][1]
2. Add the following to `application:didRegisterForRemoteNotificationsWithDeviceToken`
   in your `AppDelegate`:

        ```swift
        Vibes.shared.setPushToken(fromData: deviceToken)
        ```

3. When you would like to register for push, you should call:

        ```swift
        Vibes.shared.registerPush { result in
          // This callback is optional. If you choose to use it, result will be a
          // VibesResult<Void>.
        }
        ```

> NOTE: This will send the device token to Vibes _and_ enable push; if you want
> to just send the device token to Vibes without enabling push, please see
> "Updating device"

### Unregistering for Push

You can add the following wherever it makes the most sense for your application:

```swift
Vibes.shared.unregisterPush { result in
  // This callback is optional. If you choose to use it, result will be a
  // VibesResult<Void>.
}
```

When push notifications are turned off via the Settings app after being previously enabled, you may choose to unregister push. You can do so by calling `Vibes.shared.unregisterPush` in `application:didFailToRegisterForRemoteNotificationsWithError`:

```swift
  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    Vibes.shared.unregisterPush { result in }
  }
```

### Updating a Device

You can add the following wherever it makes the most sense for your application:

```swift
Vibes.shared.updateDevice { result in
  // This callback is optional. If you choose to use it, result will be a
  // VibesResult<Credential>.
}
```

> NOTE: If you would like to send the device token to Vibes without enabling
> push (e.g., to separate sending the device token from toggling push on or
> off), you can use this method after calling `setPushToken:fromData`.

### Event Tracking

"Launch" and "clickthru" events are automatically tracked for you, except to properly track "clickthru" events, you must add the following to your `AppDelegate`:


```swift
# iOS 9
extension AppDelegate {
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    VibesPush.Vibes.shared.receivedPush(with: userInfo)
  }
}

# iOS 10
extension AppDelegate: UNUserNotificationCenterDelegate {
  public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    VibesPush.Vibes.shared.receivedPush(with: notification.request.content.userInfo)
    completionHandler([])
  }
}
```


If you would like to change the events that are being tracked, you can modify
your `Vibes.configure` call:

```swift
Vibes.configure(appId: "TEST_APP_ID", trackedEventTypes: [.launch])
```

### Deep Linking

If you have `deep_linking` enabled in your push notification setup, you can retrieve its value
in the push notification payload.

```json
{
  "aps": {
    "alert": {
      "title": "Cool title!",
      "subtitle": "From Vibes",
      "body": "Push push 🙌"
    }
  },
  "client_app_data": {
  	...
    "deep_link": "XXXXXXX",
    ...
  },
  "message_uid": "9b8438b7-81cd-4f1f-a50c-4fbc448b0a53"
}
```

One way to handle `deep_linking` in your application is to parse the push notification payload as follows, and push the viewController you want to.

```swift
fileprivate let kClientDataKey = "client_app_data"
fileprivate let kDeepLinkKey = "deep_link"
fileprivate let kPushDeepLinkView = "XXXXXXX"

...
@available(iOS 10.0, *)
func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
  completionHandler()
  receivePushNotif(userInfo: response.notification.request.content.userInfo)
}
  
func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
  receivePushNotif(userInfo: userInfo)
}
  
/// When the user clicks on a push notif, two events will be sent to Vibes backend: .launch, .clickthru events.
/// If you specify a value for 'deep_link' in client_app_data, you can redirect the user to the viewcontrollers of
/// your choice when he clicks on the push notification. The deep_link format is free
/// (best practice:{nameApp}://{viewcontrollers}{%parameters}
fileprivate func receivePushNotif(userInfo: [AnyHashable : Any]) {
  Vibes.configure(appId: kAppKey)
  VibesPush.Vibes.shared.receivedPush(with: userInfo)
    
  // Over simplified deep_link mechanism, but you get the idea.
  guard let client_data = userInfo[kClientDataKey] as? [String: Any],
    let deepLink = client_data[kDeepLinkKey] as? String
    else { return }
  if (deepLink == kPushDeepLinkView) {
    self.navigationController.pushViewController(deepLinkViewController, animated: true)
  }
}
```

## Testing <a name="testing"></a>

In order to test the push notification, you can use the application [Pusher][2] with the following payload:

```json
{
  "aps": {
    "alert": {
      "title": "Cool title!",
      "subtitle": "From Vibes",
      "body": "Push push 🙌"
    }
  },
  "client_app_data": {
    "deep_link": "pouet",
  },
  "message_uid": "9b8438b7-81cd-4f1f-a50c-4fbc448b0a53"
}
```

[1]: https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/
[2]: https://github.com/noodlewerk/NWPusher