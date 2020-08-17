import Foundation
import Quick
import Nimble
@testable import VibesPush

class ResourceSpec: QuickSpec {
  override func spec() {
    describe("#toRequest") {
      let data = Data(bytes: [1])
      let headers = ["Accept": "application/json"]
      let resource = HTTPResource<String>(path: "/hello", method: .POST, requestBody: data, headers: headers) { _ in
        return ""
      }

      let request = resource.toRequest(baseURL: URL(string: "http://example.com")!)

      it("sets the URL") {
        expect(request.url).to(equal(URL(string: "http://example.com/hello")!))
      }

      it("copies over headers") {
        expect(request.allHTTPHeaderFields?["Accept"]).to(equal("application/json"))
      }

      it("sets the http method") {
        expect(request.httpMethod).to(equal("POST"))
      }

      it("sets the request body") {
        expect(request.httpBody).to(equal(data))
      }
    }
  }
}
