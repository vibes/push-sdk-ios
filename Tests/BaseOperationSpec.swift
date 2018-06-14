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
    override func spec() {
        var api: StubVibesAPI!
        var vibes: Vibes!
        var storage: StubStorage!
        var creds: VibesCredential!
        
        beforeEach {
            api = StubVibesAPI()
            storage = StubStorage()
            let trackedEvent = [TrackedEventType]()
            Vibes.configure(appId: "TEST_APP_KEY",
                            trackedEventTypes: trackedEvent as NSArray,
                            storageType: .USERDEFAULTS,
                            advertisingId: "", logger: nil,
                            apiUrl: "https://public-api.vibescm.com/mobile_apps")
            
            vibes = Vibes(appId: "appId", api: api, storage: storage)
            creds = VibesCredential(deviceId: "id", authToken: "token")
            vibes.credentialManager.currentCredential = creds
            vibes.pushToken = "token"
        }
        
        describe("#RetryOperation") {
            it("when_unreachable_error_is_caught") {
                let cannedResult = ResourceResult<VibesCredential>.failure(.unreachable)
                let client = StubHTTPResourceClient(result: cannedResult)
                let api = VibesAPI(client: client)
                let instance = Vibes(appId: "", api: api)
                let expectation1 = self.expectation(description: "Waiting for the callback")
                class TestDelegate: VibesAPIDelegate {
                    fileprivate let callback: () -> ()
                    func didRegisterDevice(deviceId: String?, error: Error?) {
                        if (error != nil){
                            callback()
                        }
                    }
                    
                    init(callback: @escaping () -> ()) {
                        self.callback = callback
                    }
                }
                instance.set(delegate: TestDelegate(callback: {
                    expectation1.fulfill()
                }))
                instance.registerDevice()
                self.waitForExpectations(timeout: 10, handler: { error in
                    expect(client.retry).toEventually(equal(4))
                })
            }
        }
        describe("#DontRetry") {
            it("when_error_is_not_unreachable") {
                let cannedResult = ResourceResult<VibesCredential>.failure(.other(nil))
                let client = StubHTTPResourceClient(result: cannedResult)
                let api = VibesAPI(client: client)
                let instance = Vibes(appId: "", api: api)

                let expectation1 = self.expectation(description: "Waiting for the callback")
                
                class TestDelegate: VibesAPIDelegate {
                    fileprivate let callback: () -> ()
                    func didRegisterDevice(deviceId: String?, error: Error?) {
                        if (error != nil){
                            callback()
                        }
                    }
                    
                    init(callback: @escaping () -> ()) {
                        self.callback = callback
                    }
                }
                instance.set(delegate: TestDelegate(callback: {
                    expectation1.fulfill()
                }))
                instance.registerDevice()
                self.waitForExpectations(timeout: 10, handler: { error in
                    expect(client.retry).toEventually(equal(1))
                })
            }
        }

        describe("#RetryAfterA404") {
            it("when_404_then_retry") {
                let cannedResult = ResourceResult<Void>.failure(.unauthorized)
                let authResult = ResourceResult<VibesCredential>.success(creds)
                let regPushSuccessResult = ResourceResult<Void>.success()
                api.add(result: cannedResult)
                api.add(result: authResult)
                api.add(result: regPushSuccessResult)

                let expectation2 = self.expectation(description: "Waiting for the callback")
                
                class TestDelegate: VibesAPIDelegate {
                    fileprivate let callback: () -> ()
                    func didRegisterPush(error: Error?) {
                        if (error == nil){
                            callback()
                        }
                    }
                    
                    init(callback: @escaping () -> ()) {
                        self.callback = callback
                    }
                }
                vibes.set(delegate: TestDelegate(callback: {
                    expectation2.fulfill()
                }))
                vibes.registerPush()
                self.waitForExpectations(timeout: 10, handler: { error in
                    expect(api.retry).toEventually(equal(3))
                })
            }
            
            it("when_after_404_the_request_timeout_then_retry") {
                let cannedResult = ResourceResult<Void>.failure(.unauthorized)
                let authResult = ResourceResult<VibesCredential>.success(creds)
                let regPushFailureResult = ResourceResult<Void>.failure(.unreachable)
                let regPushSuccessResult = ResourceResult<Void>.success()
                api.add(result: cannedResult)
                api.add(result: authResult)
                api.add(result: regPushFailureResult)
                api.add(result: regPushFailureResult)
                api.add(result: regPushSuccessResult)
                
                let expectation2 = self.expectation(description: "Waiting for the callback")
                
                class TestDelegate: VibesAPIDelegate {
                    fileprivate let callback: () -> ()
                    func didRegisterPush(error: Error?) {
                        if (error == nil){
                            callback()
                        }
                    }
                    
                    init(callback: @escaping () -> ()) {
                        self.callback = callback
                    }
                }
                vibes.set(delegate: TestDelegate(callback: {
                    expectation2.fulfill()
                }))
                vibes.registerPush()
                self.waitForExpectations(timeout: 10, handler: { error in
                    expect(api.retry).toEventually(equal(5))
                })
            }
            
            it("when_2x_404_then_fails") {
                let unauthorized = ResourceResult<Void>.failure(.unauthorized)
                let authResult = ResourceResult<VibesCredential>.failure(.unauthorized)
                api.add(result: unauthorized)
                api.add(result: authResult)
                
                let expectation2 = self.expectation(description: "Waiting for the callback")
                class TestDelegate: VibesAPIDelegate {
                    fileprivate let callback: () -> ()
                    func didRegisterPush(error: Error?) {
                        if (error != nil){
                            callback()
                        }
                    }
                    
                    init(callback: @escaping () -> ()) {
                        self.callback = callback
                    }
                }
                vibes.set(delegate: TestDelegate(callback: {
                    expectation2.fulfill()
                }))
                vibes.registerPush()
                self.waitForExpectations(timeout: 10, handler: { error in
                    expect(api.retry).toEventually(equal(2))
                })
            }
        }
    }
}
