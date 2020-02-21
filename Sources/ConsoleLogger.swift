import Foundation

/// A simple Logger that writes to the Xcode console.
@objc public class ConsoleLogger: NSObject, VibesLogger {
  /// A simple enum for specifying desired log level
  enum Level {
    /// All requests and their info (endpoint, header, body, etc.), and errors
    case verbose

    /// Request method and endpoint, and errors
    case info

    /// Only errors
    case error
  }

  /// The level for this logger
  private var level: Level

  /// Initialize this object.
  ///
  /// - parameters:
  ///   - level: the level for this logger
  init(level: Level = .verbose) {
    self.level = level
    super.init()
  }

  /// Logs an HTTP request to the console.
  ///
  /// - parameters:
  ///   - request: the HTTP request to log
  public func log(request: URLRequest) {
    switch level {
    case .verbose:
      print("Request: \(request.methodDescription) \(request.urlDescription)")
    case .info:
      if let method = request.httpMethod, let url = request.url?.absoluteString {
        print("Request: \(method) \(url)")
      }
    default:
      break
    }
  }

  /// Logs an HTTP response with its accompanying data to the console.
  ///
  /// - parameters:
  ///   - response: the HTTP response to log
  ///   - data: the data received, if any
  public func log(response: URLResponse, data: Data? = nil) {
    guard let response = response as? HTTPURLResponse else { return }

    switch level {
    case .verbose:
      print("Response: \(response.responseCodeDescription)")
      log(data: data)
    case .info:
      print("Response: \(response.statusCode)")
    default:
      break
    }
  }

  /// Logs an error the console.
  ///
  /// - parameters:
  ///   - error: the error that occurred
  public func log(error: Error) {
    print("Error: \(error.localizedDescription)")
  }

  /// Logs data to the console, if it exists.
  ///
  /// - parameters:
  ///   - data: the Data of the HTTP response
  private func log(data: Data?) {
    guard let data = data else { return }

    do {
      let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
      let pretty = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)

      if let string = NSString(data: pretty, encoding: String.Encoding.utf8.rawValue) {
        print("JSON: \(string)")
      }
    } catch {
      if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
        print("Data: \(string)")
      }
    }
  }
}
