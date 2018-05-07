import Foundation
import Quick
import Nimble
@testable import VibesPush

class CredentialMaangerSpec: QuickSpec {
  override func spec() {
    describe("#addCredential") {
      it("stores the new credential") {
        let storage = StubStorage()
        let manager = CredentialManager(storage: storage)
        let credential = Credential(deviceId: "id", authToken: "token")

        manager.addCredential(credential)

        let expected = [credential.deviceId: credential.authToken]
        expect(storage.get(LocalStorageKeys.allCredentials)).to(equal(expected))
      }
    }

    describe("#removeCredential") {
      it("removes the credential") {
        let credential = Credential(deviceId: "id", authToken: "token")
        let storage = StubStorage([credential.deviceId: credential.authToken])
        let manager = CredentialManager(storage: storage)

        manager.removeCredential(credential)

        let expected: [String: String] = [:]
        expect(storage.get(LocalStorageKeys.allCredentials)).to(equal(expected))
      }
    }

    describe("#currentCredential=") {
      context("with credential") {
        it("stores the current credential") {
          let storage = StubStorage()
          let manager = CredentialManager(storage: storage)
          let credential = Credential(deviceId: "id", authToken: "token")

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
