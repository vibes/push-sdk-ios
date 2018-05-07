import Foundation
import Quick
import Nimble
@testable import VibesPush

class HTTPResourceClientSpec: QuickSpec {
  override func spec() {
    let url = URL(string: "http://example.com")!
    var error: Error?

    func request<A>(resource: HTTPResource<A>,
                    data: Data? = nil,
                    response: URLResponse? = nil,
                    error: Error? = nil,
                    completion: @escaping (ResourceResult<A>) -> Void) {
      let session = StubURLSession(data: data, response: response, error: error)
      let client = HTTPResourceClient(baseURL: url, session: session)

      client.request(resource: resource) { result in
        completion(result)
      }
    }

    context("when there's an error") {
      it("returns an HTTPResourceError that wraps the error") {
        let resource = HTTPResource(path: "/") { _ in }
        let response = HTTPURLResponse(url: url, statusCode: 201, httpVersion: nil, headerFields: nil)
        var error: Error = NSError(domain: "test", code: 1, userInfo: nil)

        request(resource: resource, response: response, error: error) { result in
          if case let .failure(foundError) = result {
            error = foundError
          }
        }

        expect(error).toEventually(matchError(ResourceError.other(error)))
      }
    }

    context("when there's no HTTP response") {
      it("returns an HTTPResourceError") {
        let resource = HTTPResource(path: "/") { _ in }

        request(resource: resource) { result in
          if case let .failure(foundError) = result {
            error = foundError
          }
        }

        expect(error).toEventually(matchError(ResourceError.other(nil)))
      }
    }

    context("when there's not a success status code") {
      it("returns an HTTPResourceError that indicates the status code") {
        let resource = HTTPResource(path: "/") { _ in }
        let response = HTTPURLResponse(url: url, statusCode: 404, httpVersion: nil, headerFields: nil)

        request(resource: resource, response: response) { result in
          if case let .failure(foundError) = result {
            error = foundError
          }
        }

        expect(error).toEventually(matchError(ResourceError.invalidResponse(statusCode: 404, responseText: "")))
      }
    }

    context("when there's no data") {
      it("returns an HTTPResourceError that indicates data was empty") {
        let resource = HTTPResource(path: "/") { _ in }
        let response = HTTPURLResponse(url: url, statusCode: 201, httpVersion: nil, headerFields: nil)

        request(resource: resource, response: response) { result in
          if case let .failure(foundError) = result {
            error = foundError
          }
        }

        expect(error).toEventually(matchError(ResourceError.noData))
      }
    }

    context("when data can't be parsed") {
      it("returns an HTTPResourceError that indicates parsing failed") {
        let resource = HTTPResource<String>(path: "/", method: .GET, requestBody: nil, headers: [:]) { _ in return nil }
        let response = HTTPURLResponse(url: url, statusCode: 201, httpVersion: nil, headerFields: nil)
        let data = Data(bytes: [10])

        request(resource: resource, data: data, response: response) { result in
          if case let .failure(foundError) = result {
            error = foundError
          }
        }

        expect(error).toEventually(matchError(ResourceError.couldNotParse(data: data)))
      }
    }

    context("when data is parsed to correct type") {
      it("returns the value") {
        let resource = HTTPResource<String>(path: "/", method: .GET, requestBody: nil, headers: [:]) { _ in
          return "Hello"
        }
        let response = HTTPURLResponse(url: url, statusCode: 201, httpVersion: nil, headerFields: nil)
        let data = Data(bytes: [10])

        var value: String?

        request(resource: resource, data: data, response: response) { result in
          if case let .success(string) = result {
            value = string
          }
        }

        expect(value).toEventually(equal("Hello"))
      }
    }
  }
}
