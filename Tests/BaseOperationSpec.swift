//
//  HTTPExecutor.swift
//  VibesPushTests-iOS
//
//  Created by Jean-Michel Barbieri on 2/22/18.
//  Copyright © 2018 Table XI. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import VibesPush

class BaseOperationSpec: QuickSpec {
    var delegate: StubVibesAPIDelegate!

    override func spec() {
        var api: StubVibesAPI!
        var vibes: Vibes!
        var creds: VibesCredential!

        beforeEach {
            api = StubVibesAPI()
            let trackedEvent = [TrackedEventType]() as NSArray
            let configuration = VibesConfiguration(advertisingId: "",
                                                   apiUrl: "https://google.com",
                                                   storageType: .USERDEFAULTS,
                                                   trackedEventTypes: trackedEvent)
            vibes = StubVibesWithMockStorage(appId: "",
                                             configuration: configuration)
            vibes.api = api
            creds = VibesCredential(deviceId: "id", authToken: "token")
            vibes.credentialManager.currentCredential = creds
            vibes.pushToken = "token"

            self.delegate = StubVibesAPIDelegate()
            vibes.set(delegate: self.delegate)
        }

        describe("when error is 'unreachable'") {
            it("retries the request up to the maximum number of times") {
                let cannedResult = ResourceResult<VibesCredential>.failure(.unreachable)
                let client = StubHTTPResourceClient(result: cannedResult)
                let api = VibesAPI(client: client)
                let configuration = VibesConfiguration()
                let instance = Vibes(appId: "",
                                     configuration: configuration)
                instance.api = api
                instance.set(delegate: self.delegate)

                instance.registerDevice()

                expect(client.retry).toEventually(equal(4))
            }
        }

        describe("when error is not 'unreachable'") {
            it("does not retry the request") {
                let cannedResult = ResourceResult<VibesCredential>.failure(.other(nil))
                let client = StubHTTPResourceClient(result: cannedResult)
                let api = VibesAPI(client: client)
                let configuration = VibesConfiguration()
                let instance = Vibes(appId: "",
                                     configuration: configuration)
                instance.api = api
                instance.set(delegate: self.delegate)

                instance.registerDevice()

                expect(client.retry).toEventually(equal(1))
            }
        }

        describe("when there's an 'unauthorized'") {
            it("will make an auth request and before getting back to the original") {
                let cannedResult = ResourceResult<Void>.failure(.unauthorized)
                let authResult = ResourceResult<VibesCredential>.success(creds)
                let regPushSuccessResult = ResourceResult<Void>.success()
                api.add(result: cannedResult)
                api.add(result: authResult)
                api.add(result: regPushSuccessResult)

                vibes.registerPush()

                expect(api.retry).toEventually(equal(3))
            }

            it("will make an auth request and retry the original up the max number of times") {
                let cannedResult = ResourceResult<Void>.failure(.unauthorized)
                let authResult = ResourceResult<VibesCredential>.success(creds)
                let regPushFailureResult = ResourceResult<Void>.failure(.unreachable)
                let regPushSuccessResult = ResourceResult<Void>.success()
                api.add(result: cannedResult)
                api.add(result: authResult)
                api.add(result: regPushFailureResult)
                api.add(result: regPushFailureResult)
                api.add(result: regPushSuccessResult)

                vibes.registerPush()

                expect(api.retry).toEventually(equal(5))
            }

            it("will give up after getting two another 'unauthorized'") {
                let unauthorized = ResourceResult<Void>.failure(.unauthorized)
                let authResult = ResourceResult<VibesCredential>.failure(.unauthorized)
                api.add(result: unauthorized)
                api.add(result: authResult)

                vibes.registerPush()

                expect(api.retry).toEventually(equal(2))
            }
        }
    }
}
