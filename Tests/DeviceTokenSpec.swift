import Foundation
import Quick
import Nimble
@testable import VibesPush

class DeviceTokenSpec: QuickSpec {
  override func spec() {
    let deviceToken = DeviceToken(token: "my-token")

    describe("#encodeJSON") {
      it("represents itself as a JSON Dictionary") {
        let dictionary = deviceToken.encodeJSON()
        let deviceJSON = dictionary["device"] as! JSONDictionary
        expect(deviceJSON["push_token"] as? String).to(equal("my-token"))
      }
    }
  }
}
