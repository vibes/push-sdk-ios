import Foundation

/// A protocol for logging the Vibes SDK's HTTP-related logs
@objc public protocol VibesLogger {
    /// Logs a message to the logger if the `logObject.level` matches or is above the configured log `level`
    ///
    /// - Parameters:
    ///   - logObject: The Log object with  log `level` and specified log `message`.
    @objc func log(_ logObject: LogObject)

    /// Logs an HTTP request.
    ///
    /// - parameters:
    ///   - request: the HTTP request to log
    @objc func log(request: URLRequest)

    /// Logs an HTTP response with its accompanying data.
    ///
    /// - parameters:
    ///   - response: the HTTP response to log
    ///   - data: the data received, if any
    @objc func log(response: URLResponse, data: Data?)

    /// Logs an error.
    ///
    /// - parameters:
    ///   - error: the error that occurred
    @objc func log(error: Error)
}

/// Log Object with log `level` and `message`
@objc public class LogObject: NSObject {
    /// The Log leve
    @objc public let level: LogLevel
    /// The log message
    @objc public let message: String

    public init(_ level: LogLevel, message: String) {
        self.level = level
        self.message = message
    }
}

/// A simple enum for specifying desired log level
@objc public enum LogLevel: Int {
    /// All requests and their info (endpoint, header, body, etc.), and errors
    case verbose = 0

    /// Request method and endpoint, and errors
    case info

    /// Only errors
    case error

    public var logPrefix: String {
        switch self {
        case .verbose:
            return "VERBOSE"
        case .info:
            return "INFO"
        default:
            return "ERROR"
        }
    }
}
