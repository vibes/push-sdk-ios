import Foundation
import Quick
import Nimble
@testable import VibesPush

class UserDefaultsStorageSpec: QuickSpec {
  override func spec() {
    let storage = UserDefaultsStorage()

    describe("#set / #get") {
      it("stores and reads strings from user defaults") {
        let item = LocalValue<String>("some-string-key")
        let value = "some value"
        let stored = storage.set(value, for: item)
        expect(stored).to(beTrue())

        let result = storage.get(item)
        expect(result).to(equal(value))
      }

      it("stores and reads dictionaries of strings from user defaults") {
        let item = LocalValue<[String: String]>("some-dictionary-key")
        let value = ["hello": "there"]
        let stored = storage.set(value, for: item)
        expect(stored).to(beTrue())

        let result = storage.get(item)
        expect(result).to(equal(value))
      }

      it("stores and reads objects from user defaults") {
        let item = LocalObject<Credential>("some-credential-key")
        let value = Credential(deviceId: "id", authToken: "token")
        let stored = storage.set(value, for: item)
        expect(stored).to(beTrue())

        let result = storage.get(item)
        expect(result).to(equal(value))
      }

      it("returns nil when no value exists for the key provided") {
        let item = LocalValue<String>("some-non-existent-key")
        let result = storage.get(item)
        expect(result).to(beNil())
      }
    }
  }
}
