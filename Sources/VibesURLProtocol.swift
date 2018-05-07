import Foundation

/// A custom URLProtocol implementation to add logging of HTTP requests, 
/// responses, and errors in an aspect-oriented way.
class VibesURLProtocol: URLProtocol {
  /// The logger to use for HTTP traffic
  static var logger: VibesLogger?

  /// A key to indicate that a request has already been marked as handled by
  /// this protocol implementation.
  fileprivate static let handledKey = "handled"

  /// The connection to use for HTTP requests
  fileprivate var connection: NSURLConnection?

  /// The data received from the connection
  fileprivate var data: Data?

  /// The response to the HTTP request
  fileprivate var response: URLResponse?

  /// A copy of the request we are being asked to handle
  fileprivate var newRequest: NSMutableURLRequest!

  /// Registers this protocol class as a URLProtocol.
  class func register() {
    URLProtocol.registerClass(self)
  }

  /// Un-registers this protocol class as a URLProtocol.
  class func unregister() {
    URLProtocol.unregisterClass(self)
  }

  /// Determines if this URLProtocol can handle a given request.
  ///
  /// - parameters:
  ///   - request: the URLRequest in question
  override class func canInit(with request: URLRequest) -> Bool {
    guard self.property(forKey: VibesURLProtocol.handledKey, in: request) == nil else {
      return false
    }

    return true
  }

  /// Determines the canonical request for a given request.
  ///
  /// - parameters:
  ///   - request: the URLRequest in question
  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    return request
  }

  /// Starts loading the request in question.
  override func startLoading() {
    guard let req = (request as NSURLRequest).mutableCopy() as? NSMutableURLRequest, newRequest == nil else { return }

    self.newRequest = req

    VibesURLProtocol.setProperty(true, forKey: VibesURLProtocol.handledKey, in: newRequest!)

    connection = NSURLConnection(request: newRequest as URLRequest, delegate: self)

    VibesURLProtocol.logger?.log(request: newRequest as URLRequest)
  }

  /// Stops loading the request in question.
  override func stopLoading() {
    connection?.cancel()
    connection = nil
  }
}

extension VibesURLProtocol: NSURLConnectionDelegate, NSURLConnectionDataDelegate {
  func connection(_ connection: NSURLConnection, didReceive response: URLResponse) {
    let policy = URLCache.StoragePolicy(rawValue: request.cachePolicy.rawValue) ?? .notAllowed
    client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: policy)

    self.response = response
    self.data = Data()
  }

  func connection(_ connection: NSURLConnection, didReceive data: Data) {
    client?.urlProtocol(self, didLoad: data)
    self.data?.append(data)
  }

  func connectionDidFinishLoading(_ connection: NSURLConnection) {
    client?.urlProtocolDidFinishLoading(self)

    if let response = response {
      VibesURLProtocol.logger?.log(response: response, data: data)
    }
  }

  func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
    client?.urlProtocol(self, didFailWithError: error as NSError)
    VibesURLProtocol.logger?.log(error: error)
  }
}
