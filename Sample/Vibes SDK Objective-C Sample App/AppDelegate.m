//
//  AppDelegate.m
//  Vibes SDK Objective-C Sample App
//
//  Created by Quinn Stephens on 6/29/18.
//  Copyright © 2018 Vibes. All rights reserved.
//

#import "AppDelegate.h"
@import VibesPush;

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    VibesConfiguration *vibesConfig = [[VibesConfiguration alloc] initWithAdvertisingId:NULL
                                                                                 apiUrl:@"[YOUR_API_URL_HERE]"trackingApiUrl:@"[YOUR_API_URL_HERE]"
                                                                                 logger:self // use NULL if you dont wish to track SDK logs
                                                                            storageType:VibesStorageEnumUSERDEFAULTS
                                                                      trackedEventTypes:[@[] mutableCopy]];

    [Vibes configureWithAppId:@"[YOUR_APP_ID_HERE]"
                configuration:vibesConfig];
    [[Vibes shared] setWithDelegate:(id)self];

    [[Vibes shared] registerDevice];

    [self requestAuthorizationForNotifications];

    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[Vibes shared] setPushTokenFromData:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [[Vibes shared] unregisterPush];
}

- (void)requestAuthorizationForNotifications {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_10_0
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
#else
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge)
                          completionHandler:^(BOOL granted, NSError *_Nullable error) {
        if (error) {
            NSLog(@"ERROR registering for push: %@ - %@", error.localizedFailureReason, error.localizedDescription);
        } else if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                               [[UIApplication sharedApplication] registerForRemoteNotifications];
                           });
        } else {
            NSLog(@"authorization denied for push");
        }
    }];
#endif
}

- (void)didRegisterDeviceWithDeviceId:(NSString *)deviceId error:(NSError *)error {
    if (error == NULL) {
        NSLog(@"---------->>>>>>>>>>>Register Device with deviceID success ✅: %@", deviceId);

        [[NSUserDefaults standardUserDefaults] setObject:deviceId forKey:@"VibesDeviceID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self requestAuthorizationForNotifications];
    } else {
        NSLog(@"---------->>>>>>>>>>>didRegisterDevice Error Device with deviceID--->>>: %@", error);
    }
    // You can also add lines of code here to post the
    // log to an external 3rd party like DataDog or Sematext logs
}

- (void)didRegisterPushWithError:(NSError *)error {
    if (error == NULL) {
        NSLog(@"---------->>>>>>>>>>>Register Push success ✅:");
    } else {
        NSLog(@"---------->>>>>>>>>>>didRegisterPush Error register device: %@", error);
    }
    // You can also add lines of code here to post the
    // log to an external 3rd party like DataDog or Sematext logs
}

- (void)didRegisterDevice:(NSString *)deviceId withError:(NSError *)error
{
    if (error == NULL) {
        NSLog(@"---------->>>>>>>>>>>Register Device success ✅:");
    } else {
        NSLog(@"didRegisterDevice Error register device: %@", error);
    }
    // You can also add lines of code here to post the
    // log to an external 3rd party like DataDog or Sematext logs
}

- (void)didUnregisterDeviceWithError:(NSError *)error {
    if (error == NULL) {
        NSLog(@"---------->>>>>>>>>>>UnRegister Push success ✅:");
    } else {
        NSLog(@"---------->>>>>>>>>>>didRegisterPush Error register device: %@", error);
    }
    // You can also add lines of code here to post the
    // log to an external 3rd party like DataDog or Sematext logs
}

// MARK: VibesLogger
// The following are delegate methods on the VibesLogger,
// Implement them to tack the logs coming from SDK and maybe dispatch them to
// an external console or UI screen or even post them to external service like DataDog
- (void)log:(LogObject *)logObject
{
    // You can generate and prepend timestamps to the log messages too
    NSLog(@"%ld: %@", [logObject level], [logObject message]);
    // Post the log to external 3rd party like DataDog
}


- (void)logWithError:(NSError *)error
{
    NSLog(@"ERROR: %@", error.localizedDescription);
    // Post the log to external 3rd party like DataDog
}

- (void)logWithRequest:(NSURLRequest *)request
{
    NSLog(@"REQUEST: %@", [[request URL] absoluteURL]);
    // Post the log to external 3rd party like DataDog
}

- (void)logWithResponse:(NSURLResponse *)response data:(NSData *)data
{
    NSLog(@"RESPONSE: %@", response);
    // Post the log to external 3rd party like DataDog
}

@end
