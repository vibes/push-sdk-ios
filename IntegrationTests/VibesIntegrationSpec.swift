import Foundation
import Quick
import Nimble
@testable import VibesPush

/// A helper function to register a device with the given Vibes object.
func performInitialDeviceRegistration(vibes: Vibes) {
  waitUntil { done in
    vibes.registerDevice { result in
      if case let .failure(error) = result {
        fail("could not register device: \(error)")
      }
      done()
    }
  }
}

class VibesIntegrationSpec: QuickSpec {
  // Blocked for now!
  // Need to be rewritten, doesn't work with Xcode 9!!!
  // OHHTTPStube and MockingJay isn't yet compatible with Xcode 9 / Carthage.
  override func spec() {
    beforeSuite {
      Vibes.configure(appId: "TEST_APP_KEY")
    }

    describe("#registerDevice") {
      it("returns a Credential") {
        var deviceId: String?
        var authToken: String?

        Vibes.shared.registerDevice { result in
          if case let .success(credential) = result {
            deviceId = credential.deviceId
            authToken = credential.authToken
          }
        }

        expect(deviceId).toEventually(beginWith("MOCK_"))
        expect(authToken).toEventually(beginWith("mock_auth_token"))
      }
    }

    describe("#unregisterDevice") {
      context("with auth token") {
        beforeEach {
          performInitialDeviceRegistration(vibes: Vibes.shared)
        }

        it("returns successfully") {
          var called: Bool = false

          Vibes.shared.unregisterDevice { result in
            if case .success = result {
              called = true
            }
          }

          expect(called).toEventually(beTruthy())
        }
      }

      context("without auth token") {
        beforeEach {
          Vibes.shared.credentialManager.currentCredential = nil
        }

        it("returns a failure with error") {
          var error: Error?

          Vibes.shared.unregisterDevice { result in
            if case let .failure(foundError) = result {
              error = foundError
            }
          }

          expect(error).toEventually(matchError(VibesError.self))
        }
      }
    }

    describe("#updateDevice") {
      beforeEach {
        performInitialDeviceRegistration(vibes: Vibes.shared)
      }

      it("returns successfully") {
        var credential: Credential?

        Vibes.shared.updateDevice { result in
          if case let .success(foundCredential) = result {
            credential = foundCredential
          }
        }

        expect(credential).toEventuallyNot(beNil())
      }
    }

    describe("#registerPush") {
      beforeEach {
        performInitialDeviceRegistration(vibes: Vibes.shared)
        Vibes.shared.pushToken = "token"
      }

      it("returns successfully") {
        var called: Bool = false

        Vibes.shared.registerPush { result in
          if case .success = result {
            called = true
          }
          if case let .failure(error) = result {
            fail(error.description)
          }
        }

        expect(called).toEventually(beTruthy())
      }
    }

    describe("#unregisterPush") {
      beforeEach {
        performInitialDeviceRegistration(vibes: Vibes.shared)
      }

      it("returns successfully") {
        var called: Bool = false

        Vibes.shared.unregisterPush { result in
          if case .success = result {
            called = true
          }
        }

        expect(called).toEventually(beTruthy())
      }
    }
    describe("#trackEvent") {
      beforeEach {
        performInitialDeviceRegistration(vibes: Vibes.shared)
      }

      it("returns successfully") {
        var called: Bool = false

        let event = Event(eventType: .launch, properties: ["hey": "there"])
        Vibes.shared.track(event: event) { result in
          if case .success = result {
            called = true
          } else if case let .failure(error) = result {
            print(error)
          }
        }

        expect(called).toEventually(beTruthy())
      }
    }
  }
}
