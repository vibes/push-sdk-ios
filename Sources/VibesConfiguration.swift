import Foundation

@objcMembers
public class VibesConfiguration: NSObject {

    // MARK: Public Instance Properties

    /// A unique advertising identifier for this device
    public var advertisingId: String?

    /// The default URL to hit when talking to the Vibes API
    public let apiUrl: String

    /// The logger to use.
    public var logger: VibesLogger?

    /// storage to store credential
    public let storageType: VibesStorageEnum

    /// Array for Objc interoperability , type of tracking
    public var trackedEventTypes: NSArray

    public var vibesAPIURL: URL {
        if let url = URL(string: self.apiUrl) {
            return url
        } else {
            return URL(string: VibesConfiguration.defaultApiUrl)!
        }
    }

    // MARK: Private Static Properties

    /// The default URL to hit when talking to the Vibes API
    private static let defaultApiUrl = "https://public-api.vibescm.com/mobile_apps"

    ///
    /// Configure paramenters for Vibes instance.
    ///
    /// - parameters:
    ///   - advertisingId: AdSupport.advertisingId. If the application doesn't
    ///     support it nil will be sent as value to the backend.
    ///   - apiUrl: an optional URL to hit for accessing for the Vibes API; if not
    ///     present, the staging URL will be used.
    ///   - appId: the application ID provided by Vibes to identify this
    ///     application
    ///   - logger: the logger to use. Defaults to a ConsoleLogger.
    ///   - storageType: define the type of storage for storing data locally; if not
    ///     present, data will be securely stored in the Keychain.
    ///   - trackedEventTypes: NSArray for Objc interoperability , type of tracking
    ///     events sent to Vibes; if not present, all events type (.launch,
    ///    .clickthru) will be monitored.
    ///
    public init (advertisingId: String? = nil,
                 apiUrl: String? = nil,
                 logger: VibesLogger? = nil,
                 storageType: VibesStorageEnum = .KEYCHAIN,
                 trackedEventTypes: NSArray = TrackedEventType.all as NSArray) {
        self.advertisingId = advertisingId
        self.apiUrl = apiUrl ?? VibesConfiguration.defaultApiUrl
        self.logger = logger
        self.storageType = storageType
        self.trackedEventTypes = trackedEventTypes
    }
}
