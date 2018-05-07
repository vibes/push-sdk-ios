import Foundation
import Quick
import Nimble
@testable import VibesPush

class CredentialSpec: QuickSpec {
  override func spec() {
    describe(".decodeJSON") {
      context("with usable JSON dictionary") {
        it("returns a Credential") {
          let dictionary: JSONDictionary = [
            "auth_token": "a-token" as AnyObject,
            "device": [
              "vibes_device_id": "an-id",
            ] as AnyObject,
          ]
          expect(Credential(json: dictionary)).to(equal(Credential(deviceId: "an-id", authToken: "a-token")))
        }

        context("with unusable JSON dictionary") {
          it("returns nil") {
            let dictionary: JSONDictionary = [:]
            expect(Credential(json: dictionary)).to(beNil())
          }
        }
      }
    }
  }
}
