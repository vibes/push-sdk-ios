import Foundation
import Quick
import Nimble
@testable import VibesPush

class VibesAPISpec: QuickSpec {
  override func spec() {
    describe("#request") {
      let cannedResult = ResourceResult.success("OK")
      let client = StubHTTPResourceClient(result: cannedResult)
      let api = VibesAPI(client: client)
      let resource = HTTPResource(path: "/") { _ in return "" }

      var string: String?

      context("without auth token") {
        it("requests via the HTTP client") {
          api.request(resource: resource) { result in
            if case let .success(value) = result {
              string = value
            }
          }

          expect(client.behaviorUsed).to(beNil())
          expect(string).toEventually(equal("OK"))
        }
      }

      context("with auth token") {
        it("requests via the HTTP client using a behavior") {
          api.request(authToken: "secret-token", resource: resource) { result in
            if case let .success(value) = result {
              string = value
            }
          }

          expect(client.behaviorUsed).to(beAnInstanceOf(AuthTokenBehavior.self))
          expect(string).toEventually(equal("OK"))
        }
      }
    }
  }
}
