//
//  InboxMessageSpec.swift
//  VibesPush-iOS
//
//  Created by Moin' Victor on 16/07/2019.
//  Copyright © 2019 Vibes. All rights reserved.
//

import Foundation
import Nimble
import Quick
@testable import VibesPush

class InboxMessageSpec: QuickSpec {
    override func spec() {
        describe(".decodeJSON") {
            context("with usable JSON dictionary") {
                var dictionary: JSONDictionary = [
                    "message_uid": "0b165b2a-3acb-44ed-ad61-77c419c31da1" as AnyObject,
                    "push_message_uid": "0b165b2a-3acb-44ed-ad61-77c419c31da1"as AnyObject,
                    "subject": "This is the subject" as AnyObject,
                    "content": "This is the content" as AnyObject,
                    "detail": "https://image.jpg" as AnyObject,
                    "collapse_key": "COLLAPSE_KEY" as AnyObject,
                    "read": true as AnyObject,
                    "expires_at": "2019-07-10T15:06:55.012+00:00" as AnyObject,
                    "created_at": "2019-07-10T15:05:55.012+00:00" as AnyObject,
                    "images": [
                        "icon": "icon image" as AnyObject,
                        "main": "main image" as AnyObject,
                    ] as AnyObject,
                    "inbox_custom_data": [
                        "key1": "value1" as AnyObject,
                        "key2": "value2" as AnyObject,
                    ] as AnyObject,
                    "client_app_data": [
                        "inbox_message_uid": "value1" as AnyObject,
                    ] as AnyObject,
                    "apprefdata": [
                        "activityType": "Broadcast" as AnyObject,
                        "activityUid": "0b165b2a-3acb-44ed-ad61-77c419c31da1" as AnyObject,
                        "personUid": "99ee1b83-aaca-474c-8d05-482bea4abc9c" as AnyObject,
                        "flightUid": "73575a17-aaf7-4893-bf99-14fe737e1719" as AnyObject,
                        "vibesDeviceId": "73575a17-aaf7-4893-bf99-14fe737e1719" as AnyObject,
                        "deviceUid": "9bf15fa5-6a25-4b43-9422-b87df6ef7821" as AnyObject,
                    ] as AnyObject,
                ]
                it("returns an InboxMessage") {
                    let actual = InboxMessage(json: dictionary)
                    let expected = InboxMessage(messageUID: "0b165b2a-3acb-44ed-ad61-77c419c31da1", subject: "This is the subject", content: "This is the content", detail: "https://image.jpg", read: true, expiresAt: "2019-07-10T15:05:55.012+00:00".iso8601)
                    expect(actual?.messageUID == expected.messageUID).to(equal(true))
                    expect(actual?.subject == expected.subject).to(equal(true))
                    expect(actual?.content == expected.content).to(equal(true))
                    expect(actual?.detail == expected.detail).to(equal(true))
                    expect(actual?.read).to(equal(expected.read))
                    expect(actual?.iconImage).to(equal("icon image"))
                    expect(actual?.mainImage).to(equal("main image"))
                    expect(actual?.collapseKey).to(equal("COLLAPSE_KEY"))
                    expect(actual?.read).to(equal(expected.read))
                    expect(actual?.createdAt).to(equal("2019-07-10T15:05:55.012+00:00".iso8601))
                    expect(actual?.expiresAt).to(equal("2019-07-10T15:06:55.012+00:00".iso8601))
                    expect(actual?.eventMap()[InboxMessage.eActivityTypeKey]).to(equal("Broadcast"))
                    expect(actual?.eventMap()[InboxMessage.eActivityUidKey]).to(equal("0b165b2a-3acb-44ed-ad61-77c419c31da1"))
                    expect(actual?.eventMap()[InboxMessage.eMessageUidKey]).to(equal(expected.messageUID))
                    expect(actual?.inboxMessageUID == "value1").to(equal(true))
                }

                it("returns an InboxMessage even if subject field is not set") {
                    dictionary["subject"] = nil
                    let actual = InboxMessage(json: dictionary)
                    let expected = InboxMessage(messageUID: "0b165b2a-3acb-44ed-ad61-77c419c31da1", subject: nil, content: "This is the content", detail: "https://image.jpg", read: true, expiresAt: "2019-07-10T15:05:55.012+00:00".iso8601)
                    expect(actual?.messageUID == expected.messageUID).to(equal(true))
                    expect(actual?.subject == expected.subject).to(equal(true))
                    expect(actual?.content == expected.content).to(equal(true))
                    expect(actual?.detail == expected.detail).to(equal(true))
                    expect(actual?.read).to(equal(expected.read))
                    expect(actual?.iconImage).to(equal("icon image"))
                    expect(actual?.mainImage).to(equal("main image"))
                    expect(actual?.collapseKey).to(equal("COLLAPSE_KEY"))
                    expect(actual?.read).to(equal(expected.read))
                    expect(actual?.createdAt).to(equal("2019-07-10T15:05:55.012+00:00".iso8601))
                    expect(actual?.expiresAt).to(equal("2019-07-10T15:06:55.012+00:00".iso8601))
                    expect(actual?.eventMap()[InboxMessage.eActivityTypeKey]).to(equal("Broadcast"))
                    expect(actual?.eventMap()[InboxMessage.eActivityUidKey]).to(equal("0b165b2a-3acb-44ed-ad61-77c419c31da1"))
                    expect(actual?.eventMap()[InboxMessage.eMessageUidKey]).to(equal(expected.messageUID))
                    expect(actual?.inboxMessageUID == "value1").to(equal(true))
                }

                context("with unusable JSON dictionary") {
                    it("returns nil") {
                        let dictionary: JSONDictionary = [:]
                        expect(InboxMessage(json: dictionary)).to(beNil())
                    }
                }
            }
        }
    }
}
