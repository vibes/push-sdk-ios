import Foundation
/// A protocol for logging the Vibes SDK's HTTP-related logs
@objc public protocol VibesLogger {
  /// Logs an HTTP request.
  ///
  /// - parameters:
  ///   - request: the HTTP request to log
  func log(request: URLRequest)

  /// Logs an HTTP response with its accompanying data.
  ///
  /// - parameters:
  ///   - response: the HTTP response to log
  ///   - data: the data received, if any
  func log(response: URLResponse, data: Data?)

  /// Logs an error.
  ///
  /// - parameters:
  ///   - error: the error that occurred
  func log(error: Error)
}
