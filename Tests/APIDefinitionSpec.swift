import Foundation
import Quick
import Nimble
@testable import VibesPush

class APIDefinitionSpec: QuickSpec {
  override func spec() {
    let parser = JSONParser()

    describe("#registerDevice") {
      it("creates a resource") {
        let device = StubDevice()
        let resource = APIDefinition.registerDevice(appId: "app-ID", device: device)
        expect(resource.path).to(equal("/app-ID/devices"))
        expect(resource.method.rawValue).to(equal("POST"))
        expect(resource.requestBody).to(equal(parser.encode(device)))
      }
    }

    describe("#updateDevice") {
      it("creates a resource") {
        let device = StubDevice()
        let resource = APIDefinition.updateDevice(appId: "app-ID", deviceId: "device-id", device: device)
        expect(resource.path).to(equal("/app-ID/devices/device-id"))
        expect(resource.method.rawValue).to(equal("PUT"))
        expect(resource.requestBody).to(equal(parser.encode(device)))
      }
    }

    describe("unregisterDevice") {
      it("creates a resource") {
        let resource = APIDefinition.unregisterDevice(appId: "app-ID", deviceId: "device-id")
        expect(resource.path).to(equal("/app-ID/devices/device-id"))
        expect(resource.method.rawValue).to(equal("DELETE"))
        expect(resource.requestBody).to(beNil())
      }
    }

    describe("registerPush") {
      it("creates a resource") {
        let deviceToken = DeviceToken(token: "a-token")
        let resource = APIDefinition.registerPush(
          appId: "app-ID",
          deviceId: "device-id",
          pushToken: deviceToken.token
        )
        expect(resource.path).to(equal("/app-ID/devices/device-id/push_registration"))
        expect(resource.method.rawValue).to(equal("POST"))
        expect(resource.requestBody).to(equal(parser.encode(deviceToken)))
      }
    }

    describe("unregisterPush") {
      it("creates a resource") {
        let resource = APIDefinition.unregisterPush(appId: "app-ID", deviceId: "device-id")
        expect(resource.path).to(equal("/app-ID/devices/device-id/push_registration"))
        expect(resource.method.rawValue).to(equal("DELETE"))
        expect(resource.requestBody).to(beNil())
      }
    }

    describe("trackEvents") {
      it("creates a resource") {
        let event = Event(eventType: .launch, properties: [:])
        let resource = APIDefinition.trackEvents(appId: "app-ID", deviceId: "device-id", events: [event])

        expect(resource.path).to(equal("/app-ID/devices/device-id/events"))
        expect(resource.method.rawValue).to(equal("POST"))
        expect(resource.headers["X-Event-Type"]).to(equal("launch"))
      }
    }
  }
}
