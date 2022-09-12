import Foundation
import Quick
import Nimble
@testable import VibesPush

class CredentialMaangerSpec: QuickSpec {
  override func spec() {
 
    describe("#currentCredential=") {
      context("with credential") {
        it("stores the current credential") {
          let storage = StubStorage()
          let manager = CredentialManager(storage: storage)
          let credential = VibesCredential(deviceId: "id", authToken: "token")

          manager.currentCredential = credential

          expect(manager.currentCredential).to(equal(credential))
        }
      }

      context("with nil") {
        it("removes the current credential") {
          let storage = StubStorage()
          let manager = CredentialManager(storage: storage)

          manager.currentCredential = nil

          expect(manager.currentCredential).to(beNil())
        }
      }
    }
  }
}
