import Foundation
import Quick
import Nimble
@testable import VibesPush

class VibesSpec: QuickSpec {
    override func spec() {
        var api: StubVibesAPI!
        var vibes: Vibes!
        var storage: StubStorage!
        var apnsToken: Data!
        
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
        }
        
        describe("#pushToken") {
            it("allows setting and getting token from local storage") {
                vibes.pushToken = "token"
                expect(vibes.pushToken).to(equal("token"))
            }
        }
        
        describe("#setPushToken") {
            it("allows setting token from data") {
                let token = "657F777A291848BCE47C68439F21D326999CC0AE41AD0E824069E568BADFE1AB"
                
                let hexPairs = stride(from: 0, to: token.count, by: 2).map({ (index) -> String in
                    let startIndex = token.index(token.startIndex, offsetBy: index)
                    let endIndex = token.index(startIndex, offsetBy: 2, limitedBy: token.endIndex) ?? token.endIndex
                    return token[startIndex..<endIndex]
                })
                
                let tokenData = hexPairs.reduce(Data(), { (data, hexPair) -> Data in
                    var data = data
                    data.append(UInt8(hexPair, radix: 16)!)
                    return data
                })
                apnsToken = tokenData
                vibes.setPushToken(fromData: tokenData)
                expect(vibes.pushToken).to(equal(token))
            }
        }
        
        context("without credentials") {
            var expected: Error?
            
            describe("#registerDevice") {
                context("with success") {
                    it("hits the API and returns a Credential") {
                        let cannedCredential = VibesCredential(deviceId: "", authToken: "")
                        api.add(result: ResourceResult.success(cannedCredential))
                        
                        var expected: VibesCredential?
                        let expectation1 = self.expectation(description: "Should receive a response")
                        class TestDelegate: VibesAPIDelegate {
                            fileprivate let callback: (String?) -> ()
                            
                            func didRegisterDevice(deviceId: String?, error: Error?) {
                                callback(deviceId)
                            }
                            
                            init(callback: @escaping (String?) -> ()) {
                                self.callback = callback
                            }
                        }
                        vibes.set(delegate: TestDelegate(callback: { deviceId in
                            expected = VibesCredential(deviceId: deviceId!, authToken: "")
                            expectation1.fulfill()
                        }))
                        
                        vibes.registerDevice()
                        self.waitForExpectations(timeout: 1) { error in
                            expect(expected).toEventually(equal(cannedCredential))
                        }
                    }
                    
                    context("with failure") {
                        it("hits the API and returns an error") {
                            let cannedError: ResourceError = .noData
                            api.add(result: ResourceResult<VibesCredential>.failure(cannedError))
                            
                            let expectation1 = self.expectation(description: "Should receive a response")
                            
                            class TestDelegate: VibesAPIDelegate {
                                fileprivate let callback: (Error?) -> ()
                                
                                func didRegisterDevice(deviceId: String?, error: Error?) {
                                    callback(error)
                                }
                                
                                init(callback: @escaping (Error?) -> ()) {
                                    self.callback = callback
                                }
                            }
                            vibes.set(delegate: TestDelegate(callback: { error in
                                expected = error
                                expectation1.fulfill()
                            }))
                            
                            vibes.registerDevice()
                            self.waitForExpectations(timeout: 1) { error in
                                expect(expected).to(matchError(VibesError.self))
                            }
                        }
                    }
                }
            }
            
            describe("#unregisterDevice") {
                context("without credential") {
                    it("returns an error without hitting the API") {
                        let expectation1 = self.expectation(description: "Should receive a response")
                        class TestDelegate: VibesAPIDelegate {
                            fileprivate let callback: (Error?) -> ()
                            
                            func didUnregisterDevice(error: Error?) {
                                callback(error)
                            }
                            
                            init(callback: @escaping (Error?) -> ()) {
                                self.callback = callback
                            }
                        }
                        vibes.set(delegate: TestDelegate(callback: { error in
                            expected = error
                            expectation1.fulfill()
                        }))
                        
                        vibes.unregisterDevice()
                        self.waitForExpectations(timeout: 1, handler: { error in
                            expect(expected).to(matchError(VibesError.noCredentials))
                        })
                    }
                }
            }
            
            describe("#updateDevice") {
                it("returns an error without hitting the API") {
                    let expectation1 = self.expectation(description: "Should receive a response")
                    class TestDelegate: VibesAPIDelegate {
                        fileprivate let callback: (Error?) -> ()
                        
                        func didUpdateDeviceLocation(error: Error?) {
                            callback(error)
                        }
                        
                        init(callback: @escaping (Error?) -> ()) {
                            self.callback = callback
                        }
                    }
                    vibes.set(delegate: TestDelegate(callback: { error in
                        expected = error
                        expectation1.fulfill()
                    }))
                    vibes.updateDevice(lat: 48.2, long: 3.333)
                    self.waitForExpectations(timeout: 1, handler: { error in
                        expect(expected).to(matchError(VibesError.noCredentials))
                    })
                }
            }
            
            describe("#registerPush") {
                it("returns an error without hitting the API") {
                    vibes.setPushToken(fromData: apnsToken)
                    let expectation1 = self.expectation(description: "Should receive a response")
                    
                    class TestDelegate: VibesAPIDelegate {
                        fileprivate let callback: (Error?) -> ()
                        
                        func didRegisterPush(error: Error?) {
                            callback(error)
                        }
                        
                        init(callback: @escaping (Error?) -> ()) {
                            self.callback = callback
                        }
                    }
                    vibes.set(delegate: TestDelegate(callback: { error in
                        expected = error
                        expectation1.fulfill()
                    }))
                    
                    vibes.registerPush()
                    self.waitForExpectations(timeout: 1, handler: { error in
                        expect(expected).to(matchError(VibesError.noCredentials))
                    })
                }
            }
            
            describe("#unregisterPush") {
                it("returns an error without hitting the API") {
                    let expectation1 = self.expectation(description: "Should receive a response")
                    vibes.setPushToken(fromData: apnsToken)
                    
                    class TestDelegate: VibesAPIDelegate {
                        fileprivate let callback: (Error?) -> ()
                        
                        func didUnregisterPush(error: Error?) {
                            callback(error)
                        }
                        
                        init(callback: @escaping (Error?) -> ()) {
                            self.callback = callback
                        }
                    }
                    vibes.set(delegate: TestDelegate(callback: { error in
                        expected = error
                        expectation1.fulfill()
                    }))
                    
                    vibes.unregisterPush()
                    self.waitForExpectations(timeout: 1, handler: { error in
                        expect(expected).to(matchError(VibesError.noCredentials))
                    })
                }
            }
            
            context("with credentials") {
                beforeEach {
                    let storedCredential = VibesCredential(deviceId: "id", authToken: "token")
                    vibes.credentialManager.currentCredential = storedCredential
                }
                
                describe("#unregisterDevice") {
                    context("with success") {
                        it("hits the API and returns nothing") {
                            api.add(result: ResourceResult<Void>.success())
                            
                            var called: Bool = false
                            class TestDelegate: VibesAPIDelegate {
                                fileprivate let callback: (Bool) -> ()
                                
                                func didUnregisterDevice(error: Error?) {
                                    if (error == nil) {
                                        callback(true)
                                    }
                                }
                                
                                init(callback: @escaping (Bool) -> ()) {
                                    self.callback = callback
                                }
                            }
                            vibes.set(delegate: TestDelegate(callback: { value in
                                called = value
                            }))
                            
                            vibes.unregisterDevice()
                            expect(called).toEventually(beTruthy())
                        }
                    }
                    
                    context("with failure") {
                        it("hits the API and returns an error") {
                            let cannedError: ResourceError = .noData
                            api.add(result: ResourceResult<Void>.failure(cannedError))
                            let expectation1 = self.expectation(description: "Should receive a response")
                            var expected: Error?
                            class TestDelegate: VibesAPIDelegate {
                                fileprivate let callback: (Error?) -> ()
                                
                                func didUnregisterDevice(error: Error?) {
                                    callback(error)
                                }
                                
                                init(callback: @escaping (Error?) -> ()) {
                                    self.callback = callback
                                }
                            }
                            vibes.set(delegate: TestDelegate(callback: { value in
                                expected = value
                                expectation1.fulfill()
                            }))
                            
                            vibes.unregisterDevice()
                            self.waitForExpectations(timeout: 1, handler: { error in
                                expect(expected).to(matchError(VibesError.other("no data")))
                            })
                        }
                    }
                }
                
                describe("#updateDevice") {
                    context("with failure") {
                        it("hits the API and returns an error") {
                            let cannedError: ResourceError = .noData
                            api.add(result: ResourceResult<VibesCredential>.failure(cannedError))
                            var expected: Error?
                            let expectation1 = self.expectation(description: "Should receive a response")
                            vibes.credentialManager.currentCredential = nil
                            
                            class TestDelegate: VibesAPIDelegate {
                                fileprivate let callback: (Error?) -> ()
                                
                                func didRegisterDevice(deviceId: String?, error: Error?) {
                                    callback(error)
                                }
                                
                                init(callback: @escaping (Error?) -> ()) {
                                    self.callback = callback
                                }
                            }
                            vibes.set(delegate: TestDelegate(callback: { value in
                                expected = value
                                expectation1.fulfill()
                            }))
                            
                            vibes.registerDevice()
                            self.waitForExpectations(timeout: 1, handler: { error in
                                expect(expected).to(matchError(VibesError.other("no data")))
                            })
                        }
                    }
                }
                
                describe("#registerPush") {
                    context("without push token") {
                        it("returns an error without hitting the API") {
                            var expected: Error?
                            let expectation1 = self.expectation(description: "Should receive a response")
                            class TestDelegate: VibesAPIDelegate {
                                fileprivate let callback: (Error?) -> ()
                                
                                func didRegisterPush(error: Error?) {
                                    callback(error)
                                }
                                
                                init(callback: @escaping (Error?) -> ()) {
                                    self.callback = callback
                                }
                            }
                            vibes.set(delegate: TestDelegate(callback: { value in
                                expected = value
                                expectation1.fulfill()
                            }))
                            
                            vibes.registerPush()
                            self.waitForExpectations(timeout: 1, handler: { error in
                                expect(expected).to(matchError(VibesError.noPushToken))
                            })
                        }
                    }
                    
                    context("with success") {
                        it("hits the API and returns nothing") {
                            vibes.pushToken = "token"
                            api.add(result: ResourceResult<Void>.success())
                            
                            var called: Bool = false
                            class TestDelegate: VibesAPIDelegate {
                                fileprivate let callback: (Bool) -> ()
                                
                                func didRegisterPush(error: Error?) {
                                    if (error == nil) {
                                        callback(true)
                                    }
                                }
                                
                                init(callback: @escaping (Bool) -> ()) {
                                    self.callback = callback
                                }
                            }
                            vibes.set(delegate: TestDelegate(callback: { value in
                                called = value
                            }))
                            
                            vibes.registerPush()
                            expect(called).toEventually(beTruthy())
                        }
                    }
                    
                    context("with failure") {
                        it("hits the API and returns an error") {
                            vibes.pushToken = "token"
                            let cannedError: ResourceError = .noData
                            api.add(result: ResourceResult<Void>.failure(cannedError))
                            
                            var expected: Error?
                            let expectation1 = self.expectation(description: "Should receive a response")
                            class TestDelegate: VibesAPIDelegate {
                                fileprivate let callback: (Error?) -> ()
                                
                                func didRegisterPush(error: Error?) {
                                    callback(error)
                                }
                                
                                init(callback: @escaping (Error?) -> ()) {
                                    self.callback = callback
                                }
                            }
                            vibes.set(delegate: TestDelegate(callback: { value in
                                expected = value
                                expectation1.fulfill()
                            }))
                            
                            vibes.registerPush()
                            self.waitForExpectations(timeout: 1, handler: { error in
                                expect(expected).to(matchError(VibesError.other("no data")))
                            })
                        }
                    }
                }
                
                describe("#unregisterPush") {
                    context("with success") {
                        it("hits the API and returns nothing") {
                            api.add(result: ResourceResult<Void>.success())
                            
                            var called: Bool = false
                            vibes.setPushToken(fromData: apnsToken)
                            class TestDelegate: VibesAPIDelegate {
                                fileprivate let callback: (Bool) -> ()
                                
                                func didUnregisterPush(error: Error?) {
                                    if (error == nil) {
                                        callback(true)
                                    }
                                }
                                
                                init(callback: @escaping (Bool) -> ()) {
                                    self.callback = callback
                                }
                            }
                            vibes.set(delegate: TestDelegate(callback: { value in
                                called = value
                            }))
                            
                            vibes.unregisterPush()
                            expect(called).toEventually(beTruthy())
                        }
                    }
                    
                    context("with failure") {
                        it("hits the API and returns an error") {
                            let cannedError: ResourceError = .noData
                            api.add(result: ResourceResult<Void>.failure(cannedError))
                            
                            var expected: Error?
                            let expectation1 = self.expectation(description: "Should receive a response")
                            vibes.setPushToken(fromData: apnsToken)
                            class TestDelegate: VibesAPIDelegate {
                                fileprivate let callback: (Error?) -> ()
                                
                                func didUnregisterPush(error: Error?) {
                                    callback(error)
                                }
                                
                                init(callback: @escaping (Error?) -> ()) {
                                    self.callback = callback
                                }
                            }
                            vibes.set(delegate: TestDelegate(callback: { value in
                                expected = value
                                expectation1.fulfill()
                            }))
                            
                            vibes.unregisterPush()
                            self.waitForExpectations(timeout: 1, handler: { error in
                                expect(expected).to(matchError(VibesError.other("no data")))
                            })
                        }
                    }
                }
            }
        }
    }
}
