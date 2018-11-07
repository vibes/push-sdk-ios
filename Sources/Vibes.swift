import UIKit

/// A closure used as a completion handler for interacting with the Vibes
/// object.
public typealias VibesCompletion<A> = (VibesResult<A>) -> Void

/// Type of storage to store credential
@objc public enum VibesStorageEnum: Int {
  case KEYCHAIN
  case USERDEFAULTS
}

private var vibesInstance: Vibes!

/// The main entry point for usage of the Vibes API.
@objc public class Vibes: NSObject, EventTracker {
  /// The released version of the Vibes SDK
  public static let SDK_VERSION = "3.1.0"

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
  public weak var delegate: VibesAPIDelegate?

  /// The shared (singleton) instance of Vibes.
  public internal(set) static var shared: Vibes! {
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
  public internal(set) var pushToken: String? {
    get {
      return storage.get(LocalStorageKeys.pushToken)
    }

    set(newToken) {
      self.storage.set(newToken, for: LocalStorageKeys.pushToken)
    }
  }

  // A boolean to show pushToken needs to be updated.
  /// Boolean indicating whether our servers should be notified of any changes to the APNS token.
  /// This defaults to true, such that calling `setPushToken:fromData` or `setPushToken:token`
  ///   will automatically notify our server of the new change.
  /// To disable this behavior, the app developer should call `disablePush()` before updating the
  ///   APNS token, and call `registerPush()` when appropriate.
  private var isPushEnabled: Bool  = true

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
    return self.credentialManager.currentCredential
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
  ///   - appId: the application ID provided by Vibes to identify this
  ///     application
  ///   - api: an object that allows talking to the Vibes API
  ///   - storage: an object that allows storing data locally
  ///   - trackEventTypes : type of tracking events sent to Vibes
  ///   - advertisingId: AdSupport.advertisingId. If the application doesn't
  ///     support it nil will be sent as value to the backend.
  ///   - logger: the logger to use. Defaults to a ConsoleLogger.
  ///
  init(appId: String,
       configuration: VibesConfiguration? = nil) {

    self.configuration = configuration ?? VibesConfiguration()
    self.appId = appId
    let storageToUse = type(of: self).getStorageWith(type: self.configuration.storageType)
    self.storage = storageToUse
    self.credentialManager = CredentialManager(storage: storageToUse)
    self.eventStorage = PersistentEventStorage(storage: storageToUse)

    self.api = VibesAPI(url: self.configuration.vibesAPIURL)

    let userDefaults = UserDefaults.standard

    if userDefaults.bool(forKey: "hasRunBefore") == false {
      // Remove Keychain item in case the application has been reinstalled.
      // When an app is removed, its data in the keychain remains.
      self.storage.set(nil, for: LocalStorageKeys.currentCredential)
      userDefaults.set(true, forKey: "hasRunBefore")
      userDefaults.synchronize()
    }

    let trackedEventTypes = self.configuration.trackedEventTypes as? [TrackedEventType] ?? []
    self.appObserver = AppObserver(trackedEventTypes: trackedEventTypes)
    super.init()
    if !Vibes.isRunningThroughUnitTest {
      self.appObserver.eventTracker = self
    }
  }

  ///
  /// Enables register push
  /// This will result in sending the APNS token to our servers whenever it changes
  ///
  public func enablePush() {
    isPushEnabled = true
  }

  ///
  /// Disable register push
  /// This will result in NOT sending the APNS token to our servers whenever it changes.
  /// By calling this, it will be up to the app developer to call registerPush() when appropriate.
  ///
  public func disablePush() {
    isPushEnabled = false
  }

  ///
  /// Get the status of the device registration
  /// - returns: Boolean
  ///
  public func isDeviceRegistered() -> Bool {
    return self.credentialManager.currentCredential != nil
  }

  ///
  /// Get the status of the device push registration
  /// - returns: Boolean
  ///
  public func isDevicePushRegistered() -> Bool {
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
  public func setPushToken(fromData data: Data) {
    setPushToken(token: data.reduce("", { $0 + String(format: "%02X", $1) }))
  }

  ///
  /// Stores Token in local storage and if Push is enabled it pushes to vibes
  /// servers
  /// - Parameters:
  ///   - Optional token that is set
  ///
  private func setPushToken(token: String?) {
    self.storage.set(token, for: LocalStorageKeys.pushToken)
    if isPushEnabled {
      registerPush()
    }
  }

  ///
  /// Notify Vibes that a push message has been tapped on.
  ///
  /// - parameters:
  ///  - userInfo: the details from the remote notification
  ///  - timestamp: an optional date for the receipt of the push notification
  ///    (default: now)
  ///
  public func receivedPush(with userInfo: [AnyHashable: Any], at timestamp: Date = Date()) {
    appObserver.lastNotification = (userInfo, timestamp)
  }

  ///
  /// Submit a new operation (REG_DEVICE, UNREG_DEVICE ...)
  /// If the current queue isn't empty, the operation will be executed
  /// when the last operation of the queue is finished.
  ///
  fileprivate func submit<A>(operation: BaseOperation<A>) {
    if self.queue.operations.count > 0 {
      operation.addDependency(self.queue.operations.last!)
    }
    self.queue.addOperation(operation)
  }

  ///////////////////////////////////////////// OPERATIONS /////////////////////////////////////////////

  private var advertisingId: String {
    return self.configuration.advertisingId ?? ""
  }

  ///
  /// Registers this device with Vibes.
  ///
  @objc public func registerDevice() {
    self.submit(operation: RegisterDeviceOperation(credentials: self.credentialManager,
                                                   api: self.api,
                                                   advertisingId: advertisingId,
                                                   appId: self.appId,
                                                   delegate: self.delegate))
  }

  ///
  /// Unregisters this device with Vibes.
  ///
  @objc public func unregisterDevice() {
    self.submit(operation: UnregisterDeviceOperation(credentials: self.credentialManager,
                                                     api: self.api,
                                                     advertisingId: advertisingId,
                                                     appId: self.appId,
                                                     delegate: self.delegate))
  }

  ///
  /// Updates this device with Vibes.
  ///
  /// - parameters:
  ///   - lat: latitude of the User location.
  ///   - long: longitude of the User location
  ///
  @objc public func updateDevice(lat: Double, long: Double) {
    self.submit(operation: UpdateDeviceOperation(credentials: self.credentialManager,
                                                 api: self.api,
                                                 advertisingId: advertisingId,
                                                 appId: self.appId,
                                                 delegate: self.delegate,
                                                 location: (lat: lat, long: long)))
  }

  ///
  /// Associate this device with a person
  ///
  /// - paramters:
  ///   - externalPersonId: the third party identifier for the person, stored
  ///                       by vibes as external_person_id
  @objc public func associatePerson(externalPersonId: String) {
    self.submit(operation: AssociatePersonOperation(credentials: self.credentialManager,
                                                    api: self.api,
                                                    advertisingId: advertisingId,
                                                    appId: self.appId,
                                                    delegate: self.delegate,
                                                    externalPersonId: externalPersonId))
  }

  ///
  /// Register push notifications for this device with Vibes.
  ///
  @objc public func registerPush() {
    self.submit(operation: RegisterPushOperation(credentials: self.credentialManager,
                                                 storage: self.storage,
                                                 api: self.api,
                                                 advertisingId: advertisingId,
                                                 appId: self.appId,
                                                 delegate: self.delegate))
  }

  ///
  /// Unregister push notifications for this device with Vibes.
  ///
  @objc public func unregisterPush() {
    self.submit(operation: UnregisterPushOperation(credentials: self.credentialManager,
                                                   storage: self.storage,
                                                   api: self.api,
                                                   advertisingId: advertisingId,
                                                   appId: self.appId,
                                                   delegate: self.delegate))
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
    eventStorage.tracking(events: incomingEvents) { outgoingEvents, trackingCompletion in
      self.submit(operation: EventOperation(credentials: self.credentialManager,
                                            api: self.api,
                                            advertisingId: advertisingId,
                                            appId: self.appId,
                                            completion: completion,
                                            outgoingEvents: outgoingEvents,
                                            trackCompletion: trackingCompletion))
    }
  }
}

extension Vibes {
  ///
  /// Configure the shared Vibes instance. This must be called before using any
  /// of the functionality of Vibes, like registering your device.
  ///
  /// - parameters:
  ///   - configuration: Contains all the properties to configure Vibes
  ///
  @objc public static func configure(appId: String, configuration: VibesConfiguration? = nil) {

    shared = Vibes(appId: appId, configuration: configuration)
  }
}
