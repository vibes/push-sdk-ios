import Foundation

@objcMembers
public class VibesConfiguration: NSObject {
    /// The internal console logger
    internal static var consoleLogger: ConsoleLogger?

    // MARK: Public Instance Properties

    /// A unique advertising identifier for this device
    public var advertisingId: String?

    /// The default URL to hit when talking to the Vibes API
    public let apiUrl: String

    /// The default tracking URL to hit when talking to the Vibes API
    public var trackingApiUrl: String

    /// The logger to use.
    public var logger: CombinedLogger?

    /// Storage to store credential
    public let storageType: VibesStorageEnum

    /// Array for Objc interoperability , type of tracking
    public var trackedEventTypes: NSArray

    public var vibesAPIURL: URL {
        if let url = URL(string: apiUrl) {
            return url
        } else {
            return URL(string: VibesConfiguration.defaultApiUrl)!
        }
    }
    
    public var vibesTrackingAPIURL: URL {
        if let url = URL(string: trackingApiUrl) {
            return url
        } else {
            return URL(string: VibesConfiguration.defaultTrackingApiUrl)!
        }
    }

    // MARK: Private Static Properties

    /// The default URL to hit when talking to the Vibes API
    private static let defaultApiUrl = "https://public-api.vibescm.com/mobile_apps"

    /// TThe default URL to use to talk to EU Vibes environment, if not overridden by client settings.
    private static let europeApiUrl = "https://public-api.vibescmeurope.com/mobile_apps"
    
    /// The default URL to use to send tracking info to Vibes, if not overridden by client settings.
    private static let defaultTrackingApiUrl = "https://tagtracking.vibescm.com/track"

    /// The default URL to use to send tracking info to EU Vibes environment
    private static let europeTrackingApiUrl = "https://tagtracking.eu.vibes.com/track"

    /// Enable Developer Logging which will print logs to the console.
    ///
    /// - Parameter level: The minimum Log level, Default is `.verbose`
    public func enableDevLogging(level: LogLevel = .verbose) {
        VibesConfiguration.consoleLogger = ConsoleLogger(level: level)
    }

    /// Disable Developer Logging
    public func disableDevLogging() {
        VibesConfiguration.consoleLogger = nil
    }

    ///
    /// Configure paramenters for Vibes instance.
    ///
    /// - parameters:
    ///   - advertisingId: AdSupport.advertisingId. If the application doesn't
    ///     support it nil will be sent as value to the backend.
    ///   - apiUrl: An optional URL to hit for accessing for the Vibes API; if not
    ///     present, the staging URL will be used.
    ///   - trackingApiUrl: An optional URL to hit for accessing for the Vibes Tracking API ; if not
    ///     present, the staging URL will be used.
    ///   - logger: The logger to use, in addition to`ConsoleLogger`. if enabled.
    ///     You can enable console logging with `Vibes.shared.configuration.enableDevLogging()`
    ///     and disable with `Vibes.shared.configuration.disableDevLogging()` at any point.
    ///   - storageType: define the type of storage for storing data locally; if not
    ///     present, data will be securely stored in the Keychain.
    ///   - trackedEventTypes: NSArray for Objc interoperability , type of tracking
    ///     events sent to Vibes; if not present, all events type (`.launch`,
    ///    `.clickthru` e.t.c) will be monitored.
    ///
    public init(advertisingId: String? = nil,
                apiUrl: String? = nil,
                trackingApiUrl: String? = nil,
                logger: VibesLogger? = nil,
                storageType: VibesStorageEnum = .KEYCHAIN,
                trackedEventTypes: NSArray = TrackedEventType.all as NSArray) {
        self.advertisingId = advertisingId
        self.apiUrl = apiUrl ?? VibesConfiguration.defaultApiUrl
        if let apiUrl = apiUrl,
           let trackingApiUrl = trackingApiUrl,
           apiUrl.contains("vibescmeurope.com") && !trackingApiUrl.contains("eu.vibes.com") {
            self.trackingApiUrl = VibesConfiguration.europeTrackingApiUrl
        } else {
            self.trackingApiUrl = trackingApiUrl ?? VibesConfiguration.defaultTrackingApiUrl
        }
        self.logger = CombinedLogger(customLogger: logger)
        self.storageType = storageType
        self.trackedEventTypes = trackedEventTypes
    }
}
