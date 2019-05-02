import Foundation
import Quick
import Nimble
@testable import VibesPush

class AuthTokenBehaviorSpec: QuickSpec {
  override func spec() {
    describe("#modifyRequest") {
      let behavior = AuthTokenBehavior(token: "super-secret")

      it("sets the Authorization header") {
        let url = URL(string: "http://example.com")!
        var request = URLRequest(url: url)

        behavior.modifyRequest(request: &request)

        expect(request.allHTTPHeaderFields?["Authorization"]).to(equal("MobileAppToken super-secret"))
      }
    }
  }
}
