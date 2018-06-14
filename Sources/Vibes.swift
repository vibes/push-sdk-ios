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
  public static let SDK_VERSION = "2.0.00"
  
  /// The default URL to hit when talking to the Vibes API
  private static let ApiUrl = "https://public-api.vibescm.com/mobile_apps"
  
  /// Register push status
  public static let REGISTER_PUSH_STATUS = "VibesRegisterPushStatus"
  
  /// An object that can communicate with the Vibes API.
  private let api: VibesAPIType
  
  /// An object that handles managing credentials
  let credentialManager: CredentialManager
  
  // The application ID provided by Vibes to identify this application.
  private let appId: String
  
  /// An object that allows for persisting data locally
  private let storage: LocalStorageType
  
  /// A unique advertising identifier for this device, e.g.
  /// "E621E1F8-C36C-495A-93FC-0C247A3E6E5F"
  private let advertisingId: String
  
  /// Queue for executing http requests
  fileprivate lazy var queue: OperationQueue = {
    let operationQueue = OperationQueue()
    operationQueue.maxConcurrentOperationCount = 1 // Serial queue operation
    return operationQueue
  }()

  /// List of Vibes delegates
  public var delegate: VibesAPIDelegate?
  
  /// The shared (singleton) instance of Vibes.
  public private(set) static var shared: Vibes! {
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
  var pushToken: String? {
    get {
      return storage.get(LocalStorageKeys.pushToken)
    }
    set(newToken) {
      self.storage.set(newToken, for: LocalStorageKeys.pushToken)
    }
  }
  
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
  
  /// The logger to use. Defaults to a ConsoleLogger.
  private let logger: VibesLogger
  
  fileprivate var credential: VibesCredential? {
    get {
      return self.credentialManager.currentCredential
    }
  }
  
  /// Convenient initializer
  /// - parameters:
  ///   - appId: the application ID provided by Vibes to identify this
  ///     application
  @objc public static func configure(appId: String) {
    let trackEvents = [TrackedEventType.launch, TrackedEventType.clickthru] as NSArray
    configure(appId: appId,
              trackedEventTypes: trackEvents,
              storageType: VibesStorageEnum.KEYCHAIN,
              advertisingId: "",
              logger: ConsoleLogger(),
              apiUrl: Vibes.ApiUrl)
  }
  
  /// Configure the shared Vibes instance. This must be called before using any
  /// of the functionality of Vibes, like registering your device.
  ///
  /// - parameters:
  ///   - appId: the application ID provided by Vibes to identify this
  ///     application
  ///   - trackEventTypes : NSArray for Objc interoperability , type of tracking
  ///     events sent to Vibes; if not present, all events type (.launch, .clickthru)
  ///     will be monitored.
  ///   - storageType: define the type of storage for storing data locally; if not
  ///     present, data will be securely stored in the Keychain.
  ///   - advertisingId: AdSupport.advertisingId. If the application doesn't
  ///     support it nil will be sent as value to the backend.
  ///   - logger: the logger to use. Defaults to a ConsoleLogger.
  ///   - apiUrl: an optional URL to hit for accessing for the Vibes API; if not
  ///     present, the staging URL will be used.
  @objc public static func configure(appId: String,
                                     trackedEventTypes: NSArray,
                                     storageType: VibesStorageEnum,
                                     advertisingId: String?,
                                     logger: VibesLogger?,
                                     apiUrl: String?) {
    let apiUrl = apiUrl ?? Vibes.ApiUrl
    let logger = logger ?? ConsoleLogger()
    let advertisingId = advertisingId ?? ""
    
    VibesURLProtocol.register()
    VibesURLProtocol.logger = logger
    let sessionConfig = URLSessionConfiguration.default
    var protos = sessionConfig.protocolClasses ?? []
    protos.insert(VibesURLProtocol.self, at: 0)
    sessionConfig.protocolClasses = protos
    sessionConfig.timeoutIntervalForRequest = 5.0
    sessionConfig.timeoutIntervalForResource = 5.0
    let session = URLSession(configuration: sessionConfig)
    
    let client = HTTPResourceClient(baseURL: URL(string: apiUrl)!, session: session)
    let api = VibesAPI(client: client)
    let storage = self.getStorageWith(type: storageType)
    let events = trackedEventTypes.flatMap({ $0 as? TrackedEventType }) // Convert NSArray to Array
    shared = Vibes(appId: appId, api: api, storage: storage,
                   trackedEventTypes: events, advertisingId: advertisingId, logger: logger)
  }
  
  /// Add a new Vibes delegate to the list of current delegates.
  /// - parameters:
  ///   - observer: VibesAPIDelegate
  @objc public func set(delegate: VibesAPIDelegate) {
    self.delegate = delegate
  }
  
  /// Get the storage according the storage type choosen by the user.
  /// - parameters:
  ///   - type: VibesStorageType
  /// - returns:
  ///   - LocalStorageType
  fileprivate static func getStorageWith(type: VibesStorageEnum) -> LocalStorageType{
    switch type {
    case .KEYCHAIN: return KeychainStorage(service: "Vibes")
    case .USERDEFAULTS: return UserDefaultsStorage()
    }
  }
  
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
  init(appId: String,
       api: VibesAPIType,
       storage: LocalStorageType = KeychainStorage(service: "Vibes"),
       trackedEventTypes: [TrackedEventType] = TrackedEventType.all,
       advertisingId: String = "",
       logger: VibesLogger = ConsoleLogger()) {
    self.appId = appId
    self.api = api
    self.advertisingId = advertisingId
    self.storage = storage
    self.credentialManager = CredentialManager(storage: storage)
    self.eventStorage = PersistentEventStorage(storage: storage)
    self.logger = logger
    
    let userDefaults = UserDefaults.standard
    
    if userDefaults.bool(forKey: "hasRunBefore") == false {
      // Remove Keychain item in case the application has been reinstalled.
      // When an app is removed, its data in the keychain remains.
      self.storage.set(nil, for: LocalStorageKeys.currentCredential)
      userDefaults.set(true, forKey: "hasRunBefore")
      userDefaults.synchronize()
    }
    
    self.appObserver = AppObserver(trackedEventTypes: trackedEventTypes)
    super.init()
    if !Vibes.isRunningThroughUnitTest {
      self.appObserver.eventTracker = self
    }
  }
  
  /// Get the status of the device registration
  /// - returns: Boolean
  public func isDeviceRegistered() -> Bool {
    return self.credentialManager.currentCredential != nil
  }
  
  /// Get the status of the device push registration
  /// - returns: Boolean
  public func isDevicePushRegistered() -> Bool {
    return UserDefaults.standard.bool(forKey: Vibes.REGISTER_PUSH_STATUS)
  }
  
  /// Parses the push token from the Data that Apple sends, and stores it
  /// locally by converting the data to a hex string. Once this has been called,
  /// `registerPush` can be called at will to enable push notifications from
  /// Vibes.
  ///
  /// - parameters:
  ///   - fromData: the data send from Apple and received in your AppDelegate's
  ///   `application:didRegisterForRemoteNotificationsWithDeviceToken` function.
  public func setPushToken(fromData data: Data) {
    self.pushToken = data.reduce("", { $0 + String(format: "%02X", $1) })
  }
  
  /// Notify Vibes that a push message has been tapped on.
  ///
  /// - parameters:
  ///  - userInfo: the details from the remote notification
  ///  - timestamp: an optional date for the receipt of the push notification
  ///    (default: now)
  public func receivedPush(with userInfo: [AnyHashable: Any], at timestamp: Date = Date()) {
    appObserver.lastNotification = (userInfo, timestamp)
  }
 
  /// Submit a new operation (REG_DEVICE, UNREG_DEVICE ...)
  /// If the current queue isn't empty, the operation will be executed
  /// when the last operation of the queue is finished.
  fileprivate func submit<A>(operation: BaseOperation<A>) {
    if (self.queue.operations.count > 0) {
      operation.addDependency(self.queue.operations.last!)
    }
    self.queue.addOperation(operation)
  }
  
  ///////////////////////////////////////////// OPERATIONS /////////////////////////////////////////////
  
  /// Registers this device with Vibes.
  @objc public func registerDevice() {
    self.submit(operation: RegisterDeviceOperation(credentials: self.credentialManager,
                                                   api: self.api,
                                                   advertisingId: self.advertisingId,
                                                   appId: self.appId,
                                                   delegate: self.delegate))
  }

  /// Unregisters this device with Vibes.
  @objc public func unregisterDevice() {
    self.submit(operation: UnregisterDeviceOperation(credentials: self.credentialManager,
                                                     api: self.api,
                                                     advertisingId: self.advertisingId,
                                                     appId: self.appId,
                                                     delegate: self.delegate))
  }

  /// Updates this device with Vibes.
  ///
  /// - parameters:
  ///   - lat: latitude of the User location.
  ///   - long: longitude of the User location
  @objc public func updateDevice(lat: Double, long: Double) {
    self.submit(operation: UpdateDeviceOperation(credentials: self.credentialManager,
                                                 api: self.api,
                                                 advertisingId: self.advertisingId,
                                                 appId: self.appId,
                                                 delegate: self.delegate,
                                                 location: (lat: lat, long: long)))
  }
  
  /// Register push notifications for this device with Vibes.
  @objc public func registerPush() {
    self.submit(operation: RegisterPushOperation(credentials: self.credentialManager,
                                                 storage: self.storage,
                                                 api: self.api,
                                                 advertisingId: self.advertisingId,
                                                 appId: self.appId,
                                                 delegate: self.delegate))
  }
  
  /// Unregister push notifications for this device with Vibes.
  @objc public func unregisterPush() {
    self.submit(operation: UnregisterPushOperation(credentials: self.credentialManager,
                                                   storage: self.storage,
                                                   api: self.api,
                                                   advertisingId: self.advertisingId,
                                                   appId: self.appId,
                                                   delegate: self.delegate))
  }
  
  /// Tracks events with Vibes.
  ///
  /// - parameters:
  ///   - events: the Events to track, e.g. [.launch]
  ///   - completion: a handler for receiving the result of tracking the events
  ///     (it returns an Array of the events that have been tracked)
  internal func track(events incomingEvents: [Event], completion: VibesCompletion<[Event]>?) {
    eventStorage.tracking(events: incomingEvents) { outgoingEvents, trackingCompletion in
      self.submit(operation: EventOperation(credentials: self.credentialManager,
                                            api: self.api,
                                            advertisingId: self.advertisingId,
                                            appId: self.appId,
                                            completion: completion,
                                            outgoingEvents: outgoingEvents,
                                            trackCompletion: trackingCompletion))
    }
  }
}
