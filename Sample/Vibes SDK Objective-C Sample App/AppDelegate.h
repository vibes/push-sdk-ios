//
//  AppDelegate.h
//  Vibes SDK Objective-C Sample App
//
//  Created by Quinn Stephens on 6/29/18.
//  Copyright © 2018 Vibes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
@import VibesPush;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate, VibesAPIDelegate, VibesLogger>

@property (strong, nonatomic) UIWindow *window;


@end

