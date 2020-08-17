import XCTest
import VibesPush
@testable import VibesSDKSampleApp

class Vibes_SDK_Sample_app_Tests: XCTestCase {
    
    // Rather than using assertions, these tests will verify that API calls can be made without errors.
    override func setUp() {
        super.setUp()
        Vibes.configure(appId: "appId")
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testConfigureWithAppId() {
        _ = Vibes.configure(appId: "appId")
    }
    
    func testConfigure() {
        let configuration = VibesConfiguration(storageType: VibesStorageEnum.USERDEFAULTS)
        Vibes.configure(appId: "PRODINTEGRATIONTEST",
                        configuration: configuration)
    }
    
    func testSetDelegate() {
        Vibes.shared.delegate = nil
    }
    
    func testIsDeviceRegisted() {
        _ = Vibes.shared.isDeviceRegistered()
    }
    
    func testSetPushToken() {
        let data = Data()
        Vibes.shared.setPushToken(fromData: data)
    }
    
    func testReceivedPush() {
        let dict = [AnyHashable : Any]()
        Vibes.shared.receivedPush(with: dict)
    }
    
    func testRegisterDevice() {
        _ = Vibes.shared.registerDevice()
    }
    
    func testUnRegisterDevice() {
        _ = Vibes.shared.unregisterDevice()
    }
    
    func testUpdateDevice() {
        Vibes.shared.updateDevice(lat: 0.0, long: 0.0)
    }
    
    func testAssociatePerson() {
        Vibes.shared.associatePerson(externalPersonId: "personID")
    }
    
    func testRegisterPush() {
        _ = Vibes.shared.registerPush()
    }
    
    func testUnregisterPush() {
        _ = Vibes.shared.unregisterPush()
    }
}
