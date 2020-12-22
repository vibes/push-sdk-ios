//
//  Vibes_SDK_Objective_C_Sample_AppTests.m
//  Vibes SDK Objective-C Sample AppTests
//
//  Created by Quinn Stephens on 6/29/18.
//  Copyright © 2018 Vibes. All rights reserved.
//

#import <XCTest/XCTest.h>
@import VibesPush;

@interface Vibes_SDK_Objective_C_Sample_AppTests : XCTestCase

@end

@implementation Vibes_SDK_Objective_C_Sample_AppTests

// Rather than using assertions, these tests will verify that API calls can be made
// without errors.

- (void)setUp {
  [Vibes configureWithAppId:@"id" configuration:NULL];
}

- (void)testConfigureWithAppId {
  [Vibes configureWithAppId:@"id" configuration:NULL];
}

- (void)testConfigure {
    [Vibes configureWithAppId:@"PRODINTEGRATIONTEST"
                configuration:NULL];
}

- (void)testSetDelegate {
    [[Vibes shared] setDelegate:nil];
}

- (void)testIsDeviceRegistered {
  [[Vibes shared] isDeviceRegistered];
}

- (void)testIsDevicePushRegistered {
  [[Vibes shared] isDevicePushRegistered];
}

- (void)testSetPushToken {
  NSData *data = [NSData data];
  [[Vibes shared] setPushTokenFromData: data];
}

- (void)testReceivedPush {
  NSDictionary *dict = [NSDictionary dictionary];
  [[Vibes shared] receivedPushWith:dict at: [NSDate date]];
}

- (void)testRegisterDevice {
  [[Vibes shared] registerDevice];
}

- (void)testUnregisterDevice {
  [[Vibes shared] unregisterDevice];
}

- (void)testUpdateDevice {
  [[Vibes shared] updateDeviceWithLat:0 long:0];
}

- (void)testAssociatePerson {
  [[Vibes shared] associatePersonWithExternalPersonId:@"id"];
}

- (void)testRegisterPush {
  [[Vibes shared] registerPush];
}

- (void)testUnregisterPush {
  [[Vibes shared] unregisterPush];
}

@end
