import Foundation
import Quick
import Nimble
@testable import VibesPush

class EventSpec: QuickSpec {
  override func spec() {
    describe("#encodeJSON") {
      it("represents itself as a JSON Dictionary") {
        let timestamp = Date(timeIntervalSince1970: 0)
        let properties = [
            "message_uid": "a6f35649-37de-478b-a905-447f12f5f751",
            "activity_type": "Broadcast",
            "activity_uid": "630f6431-2d81-4423-916b-4d6486533201",
            ]
        let event = Event(eventType: .launch, properties: properties, timestamp: timestamp)

        let dictionary = event.encodeJSON()
        expect(dictionary["uuid"] as? String).notTo(beNil())
        expect((dictionary["uuid"] as? String)?.count).to(equal(36))
        expect(dictionary["type"] as? String).to(equal("launch"))
        expect(dictionary["timestamp"] as? String).to(equal("1970-01-01T00:00:00.000Z"))

        guard let attributes = dictionary["attributes"] as? [String: Any] else {
          fail("could not read attributes from JSON")
          return
        }
        expect(attributes["activity_uid"] as? String).notTo(beNil())
        expect(attributes["activity_type"] as? String).notTo(beNil())
        expect(attributes["message_uid"] as? String).notTo(beNil())
      }
    }
  }
}
