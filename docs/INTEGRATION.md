# Integration Guide

This guide will be a living document of how to integrate the Vibes Push SDK
into an iOS app.

## Configuration

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

## Registering a device

Add the following lines to `application:didFinishLaunchingWithOptions`, or
wherever it makes the most sense for your application:

```swift
Vibes.shared.registerDevice { result in
  // This callback is optional. If you choose to use it, result will be a
  // VibesResult<Credential>.
}
```

## Unregistering a device

You can add the following wherever it makes the most sense for your application:

```swift
Vibes.shared.unregisterDevice { result in
  // This callback is optional. If you choose to use it, result will be a
  // VibesResult<Void>.
}
```

## Registering for push

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

## Unregistering for push

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

## Updating device

You can add the following wherever it makes the most sense for your application:

```swift
Vibes.shared.updateDevice { result in
  // This callback is optional. If you choose to use it, result will be a
  // VibesResult<Credential>.
}
```

> NOTE: If you would like to send the device token to Vibes without enabling
> push (e.g. to separate sending the device token from toggling push on or
> off), you can use this method after calling `setPushToken:fromData`.

## Event Tracking

"Launch" and "clickthru" events are mostly automatically tracked for you. In
order to properly track "clickthru" events, you must add the following to your
`AppDelegate`:

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

[1]: https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/
