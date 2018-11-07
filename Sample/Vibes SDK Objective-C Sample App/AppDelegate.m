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

    [Vibes configureWithAppId:@"[YOUR APP ID HERE]"
                configuration: NULL];

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

- (void)didRegisterDeviceWithDeviceId:(NSString *)deviceId error:(NSError *)error {}
- (void)didUnregisterDeviceWithError:(NSError *)error {}
- (void)didRegisterPushWithError:(NSError *)error {}
- (void)didUnregisterPushWithError:(NSError *)error {}

- (void)requestAuthorizationForNotifications {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_10_0
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
#else
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (error) {
            NSLog(@"ERROR registering for push: %@ - %@", error.localizedFailureReason, error.localizedDescription );
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

@end
