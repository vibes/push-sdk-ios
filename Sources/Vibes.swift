import UIKit
// swiftlint:disable line_length

/// A closure used as a completion handler for interacting with the Vibes
/// object.
public typealias VibesCompletion<A> = (VibesResult<A>) -> Void

/// Type Alias for Get Inbox Message callback
public typealias GetInboxMessageCallback = (_ message: InboxMessage?, _ error: Error?) -> Void

/// Type Alias for Get Git Tags callback
public typealias GetGitTagsCallback = (_ tags: [GitTag], _ error: Error?) -> Void

/// Type Alias for Get Inbox Messages callback
public typealias GetInboxMessagesCallback = (_ messages: [InboxMessage], _ error: Error?) -> Void

/// Type Alias for update Inbox Message callback
public typealias UpdateMessageCallback = (_ messages: InboxMessage?, _ error: Error?) -> Void

/// Type Alias for Get Vibes Person callback
public typealias GetPersonCallback = (_ person: Person?, _ error: Error?) -> Void

/// Type Alias for Getting App info callback
public typealias GetVibesAppInfoCallback = (_ status: VibesAppInfo?, _ error: Error?) -> Void

/// Type of storage to store credential
@objc public enum VibesStorageEnum: Int {
    case KEYCHAIN
    case USERDEFAULTS
}

private var vibesInstance: Vibes!

// swiftlint:disable type_body_length
/// The main entry point for usage of the Vibes API.
@objc public class Vibes: NSObject, EventTracker {
    /// The released version of the Vibes SDK
    public static let SDK_VERSION = "4.4.2"

    /// The app ID
    public static let CURRENT_APP_ID = "CURRENT_APP_ID"

    /// Default configuration
    public let configuration: VibesConfiguration

    /// Register push status
    public static let REGISTER_PUSH_STATUS = "VibesRegisterPushStatus"

    /// An object that can communicate with the Vibes API.
    internal var api: VibesAPIType

    // The application ID provided by Vibes to identify this application.
    private let appId: String

    /// An object that handles managing credentials
    let credentialManager: CredentialManager

    /// An object that allows for persisting data locally
    internal var storage: LocalStorageType

    /// Queue for executing http requests
    fileprivate lazy var queue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1 // Serial queue operation
        return operationQueue
    }()

    /// List of Vibes delegates
    @objc public weak var delegate: VibesAPIDelegate?

    /// The shared (singleton) instance of Vibes.
    @objc public internal(set) static var shared: Vibes! {
        get {
            if vibesInstance == nil {
                fatalError("You must call Vibes.configure before using Vibes.shared")
            }
            return vibesInstance
        }

        set(newValue) {
            vibesInstance = newValue
        }
    }

    /// The currently set push token, if available. This is stored in local
    /// storage.
    @objc public internal(set) var pushToken: String? {
        get {
            return storage.get(LocalStorageKeys.pushToken)
        }

        set(newToken) {
            storage.set(newToken, for: LocalStorageKeys.pushToken)
        }
    }

    // A boolean to show pushToken needs to be updated.
    /// Boolean indicating whether our servers should be notified of any changes to the APNS token.
    /// This defaults to true, such that calling `setPushToken:fromData` or `setPushToken:token`
    ///   will automatically notify our server of the new change.
    /// To disable this behavior, the app developer should call `disablePush()` before updating the
    ///   APNS token, and call `registerPush()` when appropriate.
    private var isPushEnabled: Bool = true

    /// Trick to detect wheter the application has been started for
    /// executing unit tests. In that case, we don't want to send
    /// events to Vibes backend.
    public static let isRunningThroughUnitTest: Bool = {
        if let testClass = NSClassFromString("XCTestCase") {
            return true
        } else {
            return false
        }
    }()

    /// An observer of the application lifecycle. This is used for automatic
    /// tracking of launch and clickthru events.
    private let appObserver: AppObserver

    /// A utility object to persist events locally until such time as they can be
    /// sent to Vibes.
    private let eventStorage: PersistentEventStorage

    fileprivate var credential: VibesCredential? {
        return credentialManager.currentCredential
    }

    ///
    /// Add a new Vibes delegate to the list of current delegates.
    /// - parameters:
    ///   - delegate: VibesAPIDelegate
    ///
    @objc public func set(delegate: VibesAPIDelegate) {
        self.delegate = delegate
    }

    ///
    /// Get the storage according the storage type choosen by the user.
    /// - parameters:
    ///   - type: VibesStorageType
    /// - returns:
    ///   - LocalStorageType
    ///
    internal class func getStorageWith(type: VibesStorageEnum) -> LocalStorageType {
        switch type {
        case .KEYCHAIN: return KeychainStorage(service: "Vibes")
        case .USERDEFAULTS: return UserDefaultsStorage()
        }
    }

    ///
    /// Initialize this object.
    ///
    /// - parameters:
    ///   - appId: The application ID provided by Vibes to identify this
    ///     application
    ///   - configuration: The Vibes Configuration object
    init(appId: String,
         configuration: VibesConfiguration? = nil) {
        self.configuration = configuration ?? VibesConfiguration()
        self.appId = appId
        let storageToUse = type(of: self).getStorageWith(type: self.configuration.storageType)
        storage = storageToUse
        credentialManager = CredentialManager(storage: storageToUse)
        eventStorage = PersistentEventStorage(storage: storageToUse)

        api = VibesAPI(url: self.configuration.vibesAPIURL)

        let userDefaults = UserDefaults.standard

        if userDefaults.bool(forKey: "hasRunBefore") == false {
            // Remove Keychain item in case the application has been reinstalled.
            // When an app is removed, its data in the keychain remains.
            storage.set(nil, for: LocalStorageKeys.currentCredential)
            userDefaults.set(true, forKey: "hasRunBefore")
            userDefaults.synchronize()
        }

        let trackedEventTypes = self.configuration.trackedEventTypes as? [TrackedEventType] ?? []
        appObserver = AppObserver(trackedEventTypes: trackedEventTypes)
        super.init()
        if !Vibes.isRunningThroughUnitTest {
            appObserver.eventTracker = self
        }
    }

    ///
    /// Enables register push
    /// This will result in sending the APNS token to our servers whenever it changes
    ///
    @objc public func enablePush() {
        isPushEnabled = true
    }

    ///
    /// Disable register push
    /// This will result in NOT sending the APNS token to our servers whenever it changes.
    /// By calling this, it will be up to the app developer to call registerPush() when appropriate.
    ///
    @objc public func disablePush() {
        isPushEnabled = false
    }

    ///
    /// Get the status of the device registration
    /// - returns: Boolean
    ///
    @objc public func isDeviceRegistered() -> Bool {
        return credentialManager.currentCredential != nil
    }

    ///
    /// Get the status of the device push registration
    /// - returns: Boolean
    ///
    @objc public func isDevicePushRegistered() -> Bool {
        return UserDefaults.standard.bool(forKey: Vibes.REGISTER_PUSH_STATUS)
    }

    ///
    /// Parses the push token from the Data that Apple sends, and stores it
    /// locally by converting the data to a hex string. Once this has been called,
    /// `registerPush` can be called at will to enable push notifications from
    /// Vibes.
    ///
    /// - parameters:
    ///   - fromData: the data send from Apple and received in your AppDelegate's
    ///   `application:didRegisterForRemoteNotificationsWithDeviceToken` function.
    ///
    @objc public func setPushToken(fromData data: Data) {
        setPushToken(token: data.reduce("", { $0 + String(format: "%02X", $1) }))
    }

    ///
    /// Stores Token in local storage and if Push is enabled it pushes to vibes
    /// servers
    /// - Parameters:
    ///   - Optional token that is set
    ///
    private func setPushToken(token: String?) {
        storage.set(token, for: LocalStorageKeys.pushToken)
        if isPushEnabled {
            registerPush()
        }
    }

    ///
    /// Notify Vibes that a push message has been tapped on or for the case of silent push, has been received.
    ///
    /// - parameters:
    ///  - userInfo: the details from the remote notification
    ///  - timestamp: an optional date for the receipt of the push notification
    ///    (default: now)
    ///
    @objc public func receivedPush(with userInfo: [AnyHashable: Any], at timestamp: Date = Date()) {
        appObserver.lastNotification = (userInfo, timestamp)
        handleSilentMigration(userInfo)
    }

  
  /// Handle Silent migration
  ///
  /// - Parameter userInfo: The push payload
    func handleSilentMigration(_ userInfo: [AnyHashable: Any]) {
        if let customData = userInfo["client_custom_data"] as? [String: Any], // ensure client_custom_data is supplied
           let pushToken = customData["vibes_auto_register_token"] as? String, // ensure push token is supplied in client_custom_data
           let migrationItemId = customData["migration_item_id"] as? String, // ensure the migration item id
           !pushToken.isEmpty { // ensure push token is not empty
            Vibes.shared.configuration.logger?
                .log(LogObject(.info, message: "Migration push received. Processing ..."))
            let registerDeviceCallback: VibesCompletion<VibesCredential> = { [weak self] result in
                switch result {
                case let .success(credential):
                    Vibes.shared.configuration.logger?
                        .log(LogObject(.info, message: "Migration request completed successfully. Device Id: \(credential.deviceId)"))
                    self?.setPushToken(token: pushToken)
                    self?.registerPush()
                    // trigger migration callback
                    if let appId = self?.appId {
                        self?.migrationCallback(appId: appId, migrationItemId: migrationItemId, vibesDeviceId: credential.deviceId)
                    }
                case let .failure(error):
                    Vibes.shared.configuration.logger?
                        .log(LogObject(.error, message: "Migration attempt failed in triggering registerDevice(): \(error)"))
                }
            }

            submit(operation: RegisterDeviceOperation(credentials: credentialManager,
                                                      api: api,
                                                      advertisingId: advertisingId,
                                                      appId: appId,
                                                      delegate: delegate,
                                                      callback: registerDeviceCallback))
        } else {
            Vibes.shared.configuration.logger?
                .log(LogObject(.info, message: "Silent Register Device Failed: Valid Push Token was not supplied"))
        }
    }
  
  /// Trigger Migration Callback Http Operation
  ///
  /// - Parameters:
  ///   - appId: The app id
  ///   - migrationItemId: Migration item id
  ///   - vibesDeviceId: Vibes Device id
    func migrationCallback(appId: String, migrationItemId: String, vibesDeviceId: String) {
        let migrationCallback: VibesCompletion<Void> = { result in
            switch result {
            case .success:
                Vibes.shared.configuration.logger?
                    .log(LogObject(.info, message: "Migration Callback Successfull."))
            case let .failure(error):
                Vibes.shared.configuration.logger?
                    .log(LogObject(.error, message: "Couldn't process migration callback: \(error)"))
            }
        }
        submit(operation: MigrationCallbackOperation(credentials: credentialManager,
                                                     api: api,
                                                     advertisingId: advertisingId,
                                                     appId: appId,
                                                     migrationItemId: migrationItemId,
                                                     vibesDeviceId: vibesDeviceId,
                                                     callback: migrationCallback))
    }

    ///
    /// Submit a new operation (REG_DEVICE, UNREG_DEVICE ...)
    /// If the current queue isn't empty, the operation will be executed
    /// when the last operation of the queue is finished.
    ///
    fileprivate func submit<A>(operation: BaseOperation<A>) {
        if !queue.operations.isEmpty {
            operation.addDependency(queue.operations.last!)
        }
        queue.addOperation(operation)
    }

    // MARK: OPERATIONS

    ///////////////////////////////////////////// OPERATIONS /////////////////////////////////////////////

    ///
    /// Checks and compares the Vibes SDK version in use.
    ///
    internal func checkLatestVersion(_ callback: GetGitTagsCallback? = nil) {
        let gitTagsCallback: GetGitTagsCallback = { tags, error in
            if let error = error {
                self.configuration.logger?
                    .log(LogObject(.error, message: "Unable to fetch latest version of SDK --> \(error)"))
                callback?(tags, error)
                return
            }
            if let latest = tags.first {
                if latest.name.compare(Vibes.SDK_VERSION) == .orderedDescending {
                    self.configuration.logger?
                        .log(LogObject(.info, message: "Latest version of the Vibes SDK is v\(latest.name). We recommend upgrading by following the instructions here: https://developer.vibes.com/display/APIs/Installing+the+iOS+Push+Notifications+SDK."))
                } else {
                    self.configuration.logger?
                        .log(LogObject(.info, message: "Your Vibes SDK v\(Vibes.SDK_VERSION) is up to date."))
                }
            }
            callback?(tags, error)
        }
        submit(operation: GetGitTagsOperation(credentials: credentialManager,
                                              storage: storage,
                                              api: api,
                                              advertisingId: advertisingId,
                                              appId: appId,
                                              callback: gitTagsCallback))
    }

    private var advertisingId: String {
        return configuration.advertisingId ?? ""
    }

    ///
    /// Registers this device with Vibes.
    ///
    @objc public func registerDevice() {
        let registerDeviceCallback: VibesCompletion<VibesCredential> = { [weak self] result in
            switch result {
            case .success:
                self?.configuration.logger?.log(LogObject(.info, message: "Device registered successfully"))
            case let .failure(error):
                self?.configuration.logger?.log(LogObject(.error, message: "Device registered failed: \(error)"))
            }
        }

        submit(operation: RegisterDeviceOperation(credentials: credentialManager,
                                                  api: api,
                                                  advertisingId: advertisingId,
                                                  appId: appId,
                                                  delegate: delegate,
                                                  callback: registerDeviceCallback))
    }

    ///
    /// Unregisters this device with Vibes.
    ///
    @objc public func unregisterDevice() {
        let unRegisterDeviceCallback: VibesCompletion<Void> = { [weak self] result in
            switch result {
            case .success:
                self?.configuration.logger?.log(LogObject(.info, message: "Device unregistered successfully"))
            case let .failure(error):
                self?.configuration.logger?.log(LogObject(.error, message: "Device unregistered faild: \(error)"))
            }
        }

        submit(operation: UnregisterDeviceOperation(credentials: credentialManager,
                                                    api: api,
                                                    advertisingId: advertisingId,
                                                    appId: appId,
                                                    delegate: delegate,
                                                    callback: unRegisterDeviceCallback))
    }

    ///
    /// Updates this device with Vibes.
    ///
    /// - parameters:
    ///   - lat: latitude of the User location.
    ///   - long: longitude of the User location
    ///
    @objc public func updateDevice(lat: Double, long: Double) {
        let updateDeviceCallback: VibesCompletion<Void> = { [weak self] result in
            switch result {
            case .success:
                self?.configuration.logger?.log(LogObject(.info, message: "Device updated successfully"))
            case let .failure(error):
                self?.configuration.logger?.log(LogObject(.error, message: "Update device failed: \(error)"))
            }
        }

        submit(operation: UpdateDeviceOperation(credentials: credentialManager,
                                                api: api,
                                                advertisingId: advertisingId,
                                                appId: appId,
                                                delegate: delegate,
                                                location: (lat: lat, long: long),
                                                callback: updateDeviceCallback))
    }

    ///
    /// Associate this device with a person
    ///
    /// - paramters:
    ///   - externalPersonId: the third party identifier for the person, stored
    ///                       by vibes as external_person_id
    @objc public func associatePerson(externalPersonId: String) {
        let associatePersonCallback: VibesCompletion<Void> = { [weak self] result in
            switch result {
            case .success:
                self?.configuration.logger?.log(LogObject(.info, message: "Associated person with device successfully"))
            case let .failure(error):
                self?.configuration.logger?.log(LogObject(.error, message: "Register Device failed: \(error)"))
            }
        }

        submit(operation: AssociatePersonOperation(credentials: credentialManager,
                                                   api: api,
                                                   advertisingId: advertisingId,
                                                   appId: appId,
                                                   delegate: delegate,
                                                   callback: associatePersonCallback,
                                                   externalPersonId: externalPersonId))
    }

    ///
    /// Register push notifications for this device with Vibes.
    ///
    @objc public func registerPush() {
        let registerPushCallback: VibesCompletion<Void> = { [weak self] result in
            switch result {
            case .success:
                self?.configuration.logger?.log(LogObject(.info, message: "Push token registered successfully"))
            case let .failure(error):
                self?.configuration.logger?.log(LogObject(.error, message: "Push token registration failed: \(error)"))
            }
        }

        submit(operation: RegisterPushOperation(credentials: credentialManager,
                                                storage: storage,
                                                api: api,
                                                advertisingId: advertisingId,
                                                appId: appId,
                                                delegate: delegate,
                                                callback: registerPushCallback))
    }

    ///
    /// Unregister push notifications for this device with Vibes.
    ///
    @objc public func unregisterPush() {
        let unRegisterPushCallback: VibesCompletion<Void> = { [weak self] result in
            switch result {
            case .success:
                self?.configuration.logger?.log(LogObject(.info, message: "Push token unregistered successfully"))
            case let .failure(error):
                self?.configuration.logger?.log(LogObject(.error, message: "Push token unregistered  failed: \(error)"))
            }
        }

        submit(operation: UnregisterPushOperation(credentials: credentialManager,
                                                  storage: storage,
                                                  api: api,
                                                  advertisingId: advertisingId,
                                                  appId: appId,
                                                  delegate: delegate,
                                                  callback: unRegisterPushCallback))
    }

    ///
    /// Get Vibes Person Information.
    ///
    /// - Parameter callback: GetPersonCallback (Person?, Error?)
    @objc public func getPerson(_ callback: GetPersonCallback?) {
        submit(operation: GetPersonOperation(credentials: credentialManager,
                                             storage: storage,
                                             api: api,
                                             advertisingId: advertisingId,
                                             appId: appId,
                                             callback: completionWithLogger(.getPerson, callback)))
    }

    ///
    /// Retrieve inbox messages status for an app
    ///
    /// - Parameter callback: GetVibesAppInfoCallback (Status, Error?)
    @objc public func getAppInfo(_ callback: GetVibesAppInfoCallback?) {
        submit(operation: GetVibesAppInfoOperation(credentials: credentialManager,
                                                   storage: storage,
                                                   api: api,
                                                   advertisingId: advertisingId,
                                                   appId: appId,
                                                   callback: completionWithLogger(.getAppInfo, callback)))
    }

    /// Retrieve inbox messages for a Person
    ///
    /// - Parameters:
    ///   - callback: GetInboxMessagesCallback ([InboxMessage], Error?)
    @objc public func fetchInboxMessages(_ callback: GetInboxMessagesCallback?) {
        let getPersonCallback: GetPersonCallback = { person, error in
            if let person = person, let personKey = person.personKey {
                self.storage.set(person, for: LocalStorageKeys.currentPerson)
                self.submit(operation: GetInboxMessagesOperation(credentials: self.credentialManager,
                                                                 storage: self.storage,
                                                                 api: self.api,
                                                                 advertisingId: self.advertisingId,
                                                                 appId: self.appId,
                                                                 personKey: personKey,
                                                                 callback: self.completionWithLogger(.fetchMessages, callback)))
            } else {
                callback?([], error) // error retrieving person info
            }
        }
        submit(operation: GetPersonOperation(credentials: credentialManager,
                                             storage: storage,
                                             api: api,
                                             advertisingId: advertisingId,
                                             appId: appId,
                                             callback: getPersonCallback))
    }

    /// Retrieve a single  inbox message for a Person
    ///
    /// - Parameters:
    ///   - messageUID: unique UID for the message to be edited
    ///   - callback: GetInboxMessageCallback (InboxMessage, Error?)
    @objc public func fetchInboxMessage(messageUID: String, _ callback: @escaping GetInboxMessageCallback) {
        if let person = storage.get(LocalStorageKeys.currentPerson),
           let personKey = person.personKey {
            submit(operation: GetInboxMessageOperation(credentials: credentialManager,
                                                       storage: storage,
                                                       api: api,
                                                       advertisingId: advertisingId,
                                                       appId: appId,
                                                       personKey: personKey,
                                                       messageUID: messageUID,
                                                       callback: completionWithLogger(.fetchMessage, callback)))
        } else { // we dint find personKey, lets retrieve it then retry
            let getPersonCallback: GetPersonCallback = { person, error in
                if let person = person, let personKey = person.personKey {
                    self.storage.set(person, for: LocalStorageKeys.currentPerson)
                    self.submit(operation: GetInboxMessageOperation(credentials: self.credentialManager,
                                                                    storage: self.storage,
                                                                    api: self.api,
                                                                    advertisingId: self.advertisingId,
                                                                    appId: self.appId,
                                                                    personKey: personKey,
                                                                    messageUID: messageUID,
                                                                    callback: callback))
                } else {
                    callback(nil, error) // error retrieving person info
                }
            }
            submit(operation: GetPersonOperation(credentials: credentialManager,
                                                 storage: storage,
                                                 api: api,
                                                 advertisingId: advertisingId,
                                                 appId: appId,
                                                 callback: getPersonCallback))
        }
    }

    /// Mark inbox message as read
    ///
    /// - Parameters:
    ///   - messageUID: unique UID for the message to be edited
    ///   - callback: UpdateMessageCallback (InboxMessage?, Error?)
    @objc public func markInboxMessageAsRead(messageUID: String, _ callback: @escaping UpdateMessageCallback) {
        updateInboxMessage(messageUID: messageUID,
                           payload: ["read": true as AnyObject],
                           callback: completionWithLogger(.markMessageRead, callback))
    }

    /// Expire inbox message at specified date
    ///
    /// - Parameters:
    ///   - messageUID: unique UID for the message to be edited
    ///   - date: The date to expire the inbox message. if not set, defaults to now.
    ///   - callback: UpdateMessageCallback (InboxMessage?, Error?)
    @objc public func expireInboxMessage(messageUID: String, date: Date = Date(), _ callback: @escaping UpdateMessageCallback) {
        updateInboxMessage(messageUID: messageUID,
                           payload: ["expires_at": date.iso8601WithUpdatingTimezone as AnyObject],
                           callback: completionWithLogger(.markMessageExpired, callback))
    }

    /// Records the fact that an inbox message has been viewed in detail by the user.
    ///
    /// - Parameter inboxMessage: The viewed inbox message
    @objc public func onInboxMessageOpen(inboxMessage: InboxMessage) {
        let event = Event(eventType: .inboxopen, properties: inboxMessage.eventMap())
        track(event: event)
    }

    /// Update inbox message
    ///
    /// - Parameters:
    ///   - messageUID: unique UID for the message to be edited
    ///   - payload: payload to be updated in the backend
    ///   - callback: UpdateMessageCallback (InboxMessage?, Error?)
    internal func updateInboxMessage(messageUID: String, payload: VibesJSONDictionary, callback: @escaping UpdateMessageCallback) {
        // callback, here on success, we use person key to fetch inbox messages
        if let person = storage.get(LocalStorageKeys.currentPerson),
           let personKey = person.personKey {
            submit(operation: UpdateMessageOperation(credentials: credentialManager,
                                                     storage: storage,
                                                     api: api,
                                                     advertisingId: advertisingId,
                                                     appId: appId,
                                                     personKey: personKey,
                                                     messageUID: messageUID,
                                                     payload: payload,
                                                     callback: callback))
        } else { // we dint find personKey, lets retrieve it then retry
            let getPersonCallback: GetPersonCallback = { person, error in
                if let person = person, let personKey = person.personKey {
                    self.storage.set(person, for: LocalStorageKeys.currentPerson)
                    self.submit(operation: UpdateMessageOperation(credentials: self.credentialManager,
                                                                  storage: self.storage,
                                                                  api: self.api,
                                                                  advertisingId: self.advertisingId,
                                                                  appId: self.appId,
                                                                  personKey: personKey,
                                                                  messageUID: messageUID,
                                                                  payload: payload,
                                                                  callback: callback))
                } else {
                    callback(nil, error) // error retrieving person info
                }
            }
            submit(operation: GetPersonOperation(credentials: credentialManager,
                                                 storage: storage,
                                                 api: api,
                                                 advertisingId: advertisingId,
                                                 appId: appId,
                                                 callback: getPersonCallback))
        }
    }

    ///
    /// Tracks events with Vibes.
    ///
    /// - parameters:
    ///   - events: the Events to track, e.g. [.launch]
    ///   - completion: a handler for receiving the result of tracking the events
    ///     (it returns an Array of the events that have been tracked)
    ///
    internal func track(events incomingEvents: [Event], completion: VibesCompletion<[Event]>?) {
        let allowedEvents = handleDuplicateLaunchEventsBySecond(events: incomingEvents, existing: eventStorage.storedEvents)
        eventStorage.tracking(events: allowedEvents) { outgoingEvents, trackingCompletion in
            self.submit(operation: EventOperation(credentials: self.credentialManager,
                                                  api: self.api,
                                                  advertisingId: advertisingId,
                                                  appId: self.appId,
                                                  completion: completion,
                                                  outgoingEvents: outgoingEvents,
                                                  trackCompletion: trackingCompletion))
        }
    }

    internal enum SDKAction<T> {
        case fetchMessage
        case fetchMessages
        case markMessageRead
        case markMessageExpired
        case getPerson
        case getAppInfo

        func successLogObject(_ data: T) -> LogObject {
            switch self {
            case .fetchMessage:
                return LogObject(.info, message: "Inbox Message fetched successfully")
            case .fetchMessages:
                return LogObject(.info, message: "Inbox messages fetched successfully")
            case .markMessageRead:
                return LogObject(.info, message: "Inbox message marked as read successfully")
            case .markMessageExpired:
                return LogObject(.info, message: "Inbox message marked as expired successfully")
            case .getPerson:
                return LogObject(.info, message: "Successfully retrieved person details")
            case .getAppInfo:
                if let info = data as? VibesAppInfo {
                    let state = info.inboxEnabled ? "enabled" : "disabled"
                    return LogObject(.info, message: "App Inbox is \(state).")
                }
                return LogObject(.info, message: "App Inbox status unknown.")
            }
        }

        func errorLogObject(_ error: Error) -> LogObject {
            switch self {
            case .fetchMessage:
                return LogObject(.error, message: "Fetch Messsage Failed: \(error.localizedDescription)")
            case .fetchMessages:
                return LogObject(.error, message: "Fetch Messsages Failed: \(error)")
            case .markMessageRead:
                return LogObject(.info, message: "Inbox message marked as read failed: \(error)")
            case .markMessageExpired:
                return LogObject(.info, message: "Inbox message marked as expired failed: \(error)")
            case .getPerson:
                return LogObject(.info, message: "Retrieve person details failed: \(error)")
            case .getAppInfo:
                return LogObject(.info, message: "Retrieve Vibes App Info failed: \(error)")
            }
        }
    }

    /// Wraps a callback to handle logging
    ///
    /// - Parameters:
    ///   - action: SDK Action to log
    ///   - callback: The callback to wrap
    /// - Returns: The callback with logging capabilities
    internal func completionWithLogger<T>(_ action: SDKAction<T>, _ callback: ((T, Error?) -> Void)?) -> (T, Error?) -> Void {
        let completion: (T, Error?) -> Void = { (result: T, error: Error?) in
            if let error = error {
                self.configuration.logger?.log(action.errorLogObject(error))
                callback?(result, error)
                return
            }
            self.configuration.logger?.log(action.successLogObject(result))
            callback?(result, error)
        }
        return completion
    }
}

extension Vibes {
    ///
    /// Configure the shared Vibes instance. This must be called before using any
    /// of the functionality of Vibes, like registering your device.
    ///
    /// - Parameters:
    ///   - appId: The Vibes App ID
    ///   - configuration: Contains all the properties to configure Vibes
    ///
    @objc public static func configure(appId: String, configuration: VibesConfiguration? = nil) {
        guard !appId.isEmpty else {
            fatalError("App ID must not be null or empty")
        }

        shared = Vibes(appId: appId, configuration: configuration)
        Vibes.shared.configuration.logger?.log(LogObject(.info, message: "\(ConsoleLogger.versionInfoLogPrefix)\(Vibes.SDK_VERSION)"))
        Vibes.shared.checkLatestVersion()
        Vibes.shared.getAppInfo(nil)

        let userDefaults = UserDefaults.standard
        let currentAppId = userDefaults.string(forKey: CURRENT_APP_ID) ?? ""

        if currentAppId != appId {
            // Save the new appId and log the new appId
            userDefaults.set(appId, forKey: CURRENT_APP_ID)
            userDefaults.synchronize()
            Vibes.shared.configuration.logger?.log(LogObject(.info, message: "AppId has changed to: \(appId)"))
        }
    }

    /// Will first ensure the events are unique, stripped of any dupicates based on equality test.
    /// Will then go through events and compare with any existing stored events,
    /// and handle any duplicate based on seconds difference in timestamp
    ///
    /// - Parameters:
    ///    - events: The events to check
    ///    - existing: The existing events list to check against
    /// - Returns: Events with any duplicates removed
    internal func handleDuplicateLaunchEventsBySecond(events: [Event], existing: [Event]) -> [Event] {
        let uniqueEvents = events.firstUniqueElements
        // filter all stored launch events
        let storedLaunchSorted = existing.filter({ (event) -> Bool in
            event.isLaunchEvent
        }).sorted { $0.timestamp > $1.timestamp }
        // get first from sorted list, which should be the latest one
        if let latestStoredLaunchEvent = storedLaunchSorted.first {
            let launchEvents = uniqueEvents.filter { (event) -> Bool in
                event.isLaunchEvent
            }
            if launchEvents.isEmpty {
                return uniqueEvents
            }
            let otherEvents = uniqueEvents.filter { (event) -> Bool in
                !event.isLaunchEvent
            }
            // find the accepted launch events to keep
            let acceptedLaunch = launchEvents.filter { (event) -> Bool in
                if let seconds = latestStoredLaunchEvent.timestamp.secondsDifference(with: event.timestamp),
                   seconds > 1 { // add it to accepted list
                    return true
                }
                print("Filtered out a launch event, similar exists within the second: \(event.encodeJSON())")
                return false // else dont add to accepted list
            }
            let result = otherEvents + acceptedLaunch
            return result
        }
        return uniqueEvents
    }
}

public extension Sequence where Element: Equatable {
    /// Get the unique elements off this array, based on Eqality test
    var firstUniqueElements: [Element] {
        reduce(into: []) { uniqueElements, element in
            if !uniqueElements.contains(element) {
                uniqueElements.append(element)
            }
        }
    }
}

extension Date {
    /// Get seconds difference between two dates
    /// - Parameter date: The other date
    /// - Returns: Seconds difference
    func secondsDifference(with date: Date) -> Int? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self, to: date)
        let seconds = components.second
        return seconds
    }
}
