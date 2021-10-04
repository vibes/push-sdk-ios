//
//  InboxStatusSpec.swift
//  VibesPushTests-iOS
//
//  Created by DHwty on 11/11/2020.
//  Copyright © 2020 Vibes. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import VibesPush

class VibesAppInfoSpec: QuickSpec {
    override func spec() {
        describe(".decodeJSON") {
            context("with usable JSON dictionary") {
                let dictionary: JSONDictionary = [
                    "app_id": "0b165b2a-3acb-44ed-ad61-77c419c31da1" as AnyObject,
                    "inbox_enabled": true as AnyObject,
                ]
                it("returns an InboxStatus") {
                    let actual = VibesAppInfo(json: dictionary)
                    let expected = VibesAppInfo(appId: "0b165b2a-3acb-44ed-ad61-77c419c31da1", inboxEnabled: true)
                    expect(actual?.appId == expected.appId).to(beTrue())
                    expect(actual?.inboxEnabled).to(equal(expected.inboxEnabled))
                }

                context("with unusable JSON dictionary") {
                    it("returns nil") {
                        let dictionary: JSONDictionary = [:]
                        expect(VibesAppInfo(json: dictionary)).to(beNil())
                    }
                }
            }
        }
    }
}
