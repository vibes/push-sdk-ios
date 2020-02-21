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
          expect(VibesCredential(json: dictionary)).to(equal(VibesCredential(deviceId: "an-id", authToken: "a-token")))
        }

        context("with unusable JSON dictionary") {
          it("returns nil") {
            let dictionary: JSONDictionary = [:]
            expect(VibesCredential(json: dictionary)).to(beNil())
          }
        }
      }
    }
  }
}
