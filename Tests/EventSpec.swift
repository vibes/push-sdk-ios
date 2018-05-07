import Foundation
import Quick
import Nimble
@testable import VibesPush

class EventSpec: QuickSpec {
  override func spec() {
    describe("#encodeJSON") {
      it("represents itself as a JSON Dictionary") {
        let timestamp = Date(timeIntervalSince1970: 0)
        let event = Event(eventType: .launch, properties: ["hey": "there"], timestamp: timestamp)

        let dictionary = event.encodeJSON()
        expect(dictionary["uuid"] as? String).notTo(beNil())
        expect((dictionary["uuid"] as? String)?.characters.count).to(equal(36))
        expect(dictionary["type"] as? String).to(equal("launch"))
        expect(dictionary["timestamp"] as? String).to(equal("1970-01-01T00:00:00.000Z"))

        guard let attributes = dictionary["attributes"] as? [String: Any] else {
          fail("could not read attributes from JSON")
          return
        }

        expect(attributes["hey"] as? String).to(equal("there"))
      }
    }
  }
}
