import Foundation
import Quick
import Nimble
@testable import VibesPush

class DeviceTypeSpec: QuickSpec {
  override func spec() {
    let device = StubDevice()

    describe("properties") {
      it("gather them from disparate locations") {
        expect(device.systemName).to(equal("iOS"))
        expect(device.systemVersion).to(equal("10.2"))
        expect(device.hardwareMake).to(equal("Apple"))
        expect(device.hardwareModel).to(equal("x86_64"))
        expect(device.advertisingIdentifier).to(equal("E621E1F8-C36C-495A-93FC-0C247A3E6E5F"))

        expect(device.localeIdentifier).to(equal("en_US"))
        expect(device.timeZoneIdentifier).to(equal("America/Chicago"))

        expect(device.sdkVersion).to(equal("1.0.0"))
        expect(device.appVersion).to(equal("2.0.0"))
      }
    }

    describe("#encodeJSON") {
      it("represents itself as a JSON Dictionary") {
        let dictionary = device.encodeJSON()
        let deviceJSON = dictionary["device"] as! JSONDictionary
        expect(deviceJSON["os"] as? String).to(equal(device.systemName))
        expect(deviceJSON["os_version"] as? String).to(equal(device.systemVersion))
        expect(deviceJSON["sdk_version"] as? String).to(equal(device.sdkVersion))
        expect(deviceJSON["app_version"] as? String).to(equal(device.appVersion))
        expect(deviceJSON["hardware_make"] as? String).to(equal(device.hardwareMake))
        expect(deviceJSON["hardware_model"] as? String).to(equal(device.hardwareModel))
        expect(deviceJSON["advertising_id"] as? String).to(equal(device.advertisingIdentifier))
        expect(deviceJSON["locale"] as? String).to(equal(device.localeIdentifier))
        expect(deviceJSON["timezone"] as? String).to(equal(device.timeZoneIdentifier))
      }
    }
  }
}
