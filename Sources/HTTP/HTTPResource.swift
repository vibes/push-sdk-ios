import Foundation

/// A generic value object representing an HTTP resource that can be requested
/// and parsed.
///
/// T represents the Type that will be returned for this resource, e.g.
/// `Credential` or `String`.
struct HTTPResource<T> {
  /// The path of the resource relative to the base url, e.g. "/devices"
  let path: String

  /// The HTTP method to use to fetch this resource, e.g. .POST
  let method: HTTPMethod

  /// The body to send when requesting this resource.
  let requestBody: Data?

  /// A set of headers to send when requesting this resource.
  let headers: [String: String]

  /// A closure to use to transform the returned Data for the resource into
  /// the generic type, T.
  let parse: (Data) -> T?

  /// Initialize this object.
  ///
  /// - parameters:
  ///   - path: The path of the resource relative to the base url, e.g.
  ///     "/devices"
  ///   - method: The HTTP method to use to fetch this resource, e.g. .POST
  ///   - requestBody: The body to send when requesting this resource.
  ///   - headers: A set of headers to send when requesting this resource.
  ///   - parse: A closure to use to transform the returned Data for the
  ///     resource into the generic type, T.
  // swiftlint:disable:next line_length
  init(path: String, method: HTTPMethod = .GET, requestBody: Data? = nil, headers: [String: String] = [:], parse: @escaping (Data) -> T?) {
    self.path = path
    self.method = method
    self.requestBody = requestBody
    self.headers = headers
    self.parse = parse
  }

  /// Creates a new URLRequest for this resource. This can be passed to
  /// URLSession to make a network request.
  ///
  /// - parameters:
  ///   - baseURL: The base URL to use for a request for this resource, e.g.
  ///     "http://example.com". The path will be appended to this.
  func toRequest(baseURL: URL) -> URLRequest {
    let url = baseURL.appendingPathComponent(path)
    var request = URLRequest(url: url)

    for (key, value) in headers {
      request.setValue(value, forHTTPHeaderField: key)
    }
    request.httpMethod = method.rawValue
    if method != .GET {
      request.httpBody = requestBody
    }

    return request
  }
}
