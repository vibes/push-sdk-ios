import Foundation
import Quick
import Nimble
@testable import VibesPush

class VibesErrorSpec: QuickSpec {
  override func spec() {
    describe("description") {
      it("handles noCredentials") {
        expect(VibesError.noCredentials.description).to(equal("There are no available credentials"))
      }

      it("handles noPushToken") {
        expect(VibesError.noPushToken.description).to(equal("There is no push token available"))
      }

      it("handles noEvents") {
        expect(VibesError.noEvents.description).to(equal("There are no events to track"))
      }

      it("handles tooManyEventTypes") {
        let expected = "Too many types of events - can only handle one type at a time"
        expect(VibesError.tooManyEventTypes.description).to(equal(expected))
      }

      it("handles authFailed") {
        expect(VibesError.authFailed("details").description).to(equal("Authentication failed: details"))
      }

      it("handles other") {
        expect(VibesError.other("details").description).to(equal("Error: details"))
      }
    }
  }
}
