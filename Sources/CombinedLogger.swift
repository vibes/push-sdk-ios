//
//  CombinedLogger.swift
//  VibesPush-iOS
//
//  Created by Moin' Victor on 20/08/2020.
//  Copyright © 2020 Vibes. All rights reserved.
//

import Foundation

/// A Logger that writes to the `ConsoleLogger` if enabled, as well as to any custom Logger provider to `VibesConfigration` during init.
@objc public class CombinedLogger: NSObject, VibesLogger {
    /// The custom logger  provided in  `VibesConfigration` during init.
    public var customLogger: VibesLogger?

    /// The console logger to use
    public var consoleLogger: ConsoleLogger? {
        return VibesConfiguration.consoleLogger
    }

    /// Initialize this object.
    ///
    /// - Parameters:
    ///   - customLogger: The custom logger provided in  `VibesConfigration` during init.
    init(customLogger: VibesLogger?) {
        super.init()
        self.customLogger = customLogger
    }

    /// Logs a message to the console if the `logObject.level` matches or is above the configured log `level`
    ///
    /// - Parameters:
    ///   - logObject: The Log object with  log `level` and specified log `message`.
    public func log(_ logObject: LogObject) {
        consoleLogger?.log(logObject)
        customLogger?.log(logObject)
    }

    public func log(request: URLRequest) {
        consoleLogger?.log(request: request)
        customLogger?.log(request: request)
    }

    public func log(response: URLResponse, data: Data?) {
        consoleLogger?.log(response: response, data: data)
        customLogger?.log(response: response, data: data)
    }

    public func log(error: Error) {
        consoleLogger?.log(error: error)
        customLogger?.log(error: error)
    }
}
