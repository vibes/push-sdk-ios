import Foundation

/// A simple Logger that writes to the Xcode console.
@objc public class ConsoleLogger: NSObject, VibesLogger {
    /// Prefix for logging SDK initialization
    static let versionInfoLogPrefix = "Initializing Vibes SDK v"

    /// The level for this logger
    private var level: LogLevel

    /// Initialize this object.
    ///
    /// - Parameters:
    ///   - level: the level for this logger
    init(level: LogLevel = .verbose) {
        self.level = level
        super.init()
    }

    /// Logs a message to the console if the `logObject.level` matches or is above the configured log `level`
    ///
    /// - Parameters:
    ///   - logObject: The Log object with  log `level` and specified log `message`.
    public func log(_ logObject: LogObject) {
        if logObject.level.rawValue >= level.rawValue {
            printLogMessage(logObject.level, message: logObject.message)
        }
    }

    /// Logs an HTTP request to the console.
    ///
    /// - Parameters:
    ///   - request: the HTTP request to log
    public func log(request: URLRequest) {
        switch level {
        case .verbose:
            log(LogObject(.verbose, message: "Request: \(request.toString())"))
        default:
            break
        }
    }

    /// Logs an HTTP response with its accompanying data to the console.
    ///
    /// - Parameters:
    ///   - response: the HTTP response to log
    ///   - data: the data received, if any
    public func log(response: URLResponse, data: Data? = nil) {
        guard let response = response as? HTTPURLResponse else { return }

        switch level {
        case .verbose:
            log(LogObject(.verbose, message: "Response: \(response.responseCodeDescription)"))
            log(data: data)
        default:
            break
        }
    }

    /// Logs an error the console.
    ///
    /// - Parameters:
    ///   - error: the error that occurred
    public func log(error: Error) {
        log(LogObject(.error, message: "Error: \(error.localizedDescription)"))
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
                log(LogObject(.verbose, message: "JSON: \(string)"))
            }
        } catch {
            if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                log(LogObject(.verbose, message: "Data: \(string)"))
            }
        }
    }

    /// Prints out the log message with template `[TIMESTAMP] VibesPush/[logLevel]: <MSG>`
    ///
    /// - Parameters:
    ///   - msgLogLevel: The log level for the message
    ///   - message: The message to print on the log
    func printLogMessage(_ msgLogLevel: LogLevel = .verbose, message: String) {
        print("\(Date.logPrefix) VibesPush/\(msgLogLevel.logPrefix): \(message)")
    }
}
