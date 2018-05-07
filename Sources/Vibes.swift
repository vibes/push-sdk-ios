import UIKit

/// A closure used as a completion handler for interacting with the Vibes
/// object.
public typealias VibesCompletion<A> = (VibesResult<A>) -> Void

private var vibesInstance: Vibes!

/// The main entry point for usage of the Vibes API.
public class Vibes: EventTracker {
  /// The released version of the Vibes SDK
  public static let SDK_VERSION = "1.0.1"

  /// The default URL to hit when talking to the Vibes API
  private static let ApiUrl = "https://public-api.vibescm.com/mobile_apps"

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
  fileprivate static let isRunningThroughUnitTest: Bool = {
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

  /// Configure the shared Vibes instance. This must be called before using any
  /// of the functionality of Vibes, like registering your device.
  ///
  /// - parameters:
  ///   - appId: the application ID provided by Vibes to identify this
  ///     application
  ///   - trackEventTypes : type of tracking events sent to Vibes; if not
  ///     present, all events type (.launch, .clickthru) will be monitored.
  ///   - storage: an optional object that allows storing data locally; if not
  ///     present, data will be securely stored in the Keychain.
  ///   - advertisingId: AdSupport.advertisingId. If the application doesn't
  ///     support it nil will be sent as value to the backend.
  ///   - logger: the logger to use. Defaults to a ConsoleLogger.
  ///   - apiUrl: an optional URL to hit for accessing for the Vibes API; if not
  ///     present, the staging URL will be used.
  public static func configure(appId: String,
                               trackedEventTypes: [TrackedEventType] = TrackedEventType.all,
                               storage: LocalStorageType = KeychainStorage(service: "Vibes"),
                               advertisingId: String = "",
                               logger: VibesLogger = ConsoleLogger(),
                               apiUrl: String = Vibes.ApiUrl) {
    let client = HTTPResourceClient(baseURL: URL(string: apiUrl)!)
    let api = VibesAPI(client: client)

    shared = Vibes(appId: appId, api: api, storage: storage,
      trackedEventTypes: trackedEventTypes, advertisingId: advertisingId, logger: logger)
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
    
    VibesURLProtocol.register()
    VibesURLProtocol.logger = logger

    self.appObserver = AppObserver(trackedEventTypes: trackedEventTypes)
    if !Vibes.isRunningThroughUnitTest {
      self.appObserver.eventTracker = self
    }
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

  /// Registers this device with Vibes.
  ///
  /// - parameters:
  ///   - completion: a handler for receiving the result of registering this
  ///     device.
  public func registerDevice(completion: VibesCompletion<Credential>?) {
    if let credentials = self.credentialManager.currentCredential, let completionBlock = completion {
      // The device has already been registered.
      // In case we switch to another environment, the device must be unregistered first
      // before registering it against the new environment. By unregistereing the device,
      // its credentials are deleted.
      print("Device already registered!")
      completionBlock(VibesResult<Credential>.success(credentials))
      return
    }
    let device = Device(advertisingIdentifier: self.advertisingId)

    let resource = APIDefinition.registerDevice(appId: appId, device: device)
    self.api.request(resource: resource) { [weak self] apiResult in
      if case .success(let credential) = apiResult {
        self?.credentialManager.currentCredential = credential
        self?.credentialManager.addCredential(credential)
      }
      completion?(VibesResult<Credential>(apiResult))
    }
  }

  /// Updates this device with Vibes.
  ///
  /// - parameters:
  ///   - completion: a handler for receiving the result of updating this
  ///     device.
  public func updateDevice(completion: VibesCompletion<Credential>?) {
    guard let credential = self.credentialManager.currentCredential else {
      completion?(.failure(.noCredentials))
      return
    }

    let device = Device(advertisingIdentifier: self.advertisingId)
    let resource = APIDefinition.updateDevice(appId: appId, deviceId: credential.deviceId, device: device)

    self.api.request(authToken: credential.authToken, resource: resource) {[weak self] apiResult in
      if case .success(let credential) = apiResult {
        self?.credentialManager.currentCredential = credential
        self?.credentialManager.addCredential(credential)
      }
      completion?(VibesResult<Credential>(apiResult))
    }
  }

  /// Unregisters this device with Vibes.
  ///
  /// - parameters:
  ///   - completion: a handler for receiving the result of unregistering this
  ///     device.
  public func unregisterDevice(completion: VibesCompletion<Void>?) {
    guard let credential = self.credentialManager.currentCredential else {
      completion?(.failure(.noCredentials))
      return
    }

    let resource = APIDefinition.unregisterDevice(appId: appId, deviceId: credential.deviceId)
    retryableRequest(credential: credential, resource: resource) { [weak self] result in
      if case .success(_) = result {
        self?.credentialManager.currentCredential = nil
        self?.credentialManager.removeCredential(credential)
      }
      completion?(result)
    }
  }

  /// Register push notifications for this device with Vibes.
  ///
  /// - parameters:
  ///   - completion: a handler for receiving the result of unregistering this
  ///     device.
  public func registerPush(completion: VibesCompletion<Void>?) {
    guard let credential = self.credentialManager.currentCredential else {
      completion?(.failure(.noCredentials))
      return
    }

    guard let pushToken = storage.get(LocalStorageKeys.pushToken) else {
      completion?(.failure(.noPushToken))
      return
    }

    let resource = APIDefinition.registerPush(appId: appId, deviceId: credential.deviceId, pushToken: pushToken)
    retryableRequest(credential: credential, resource: resource) { result in
      completion?(result)
    }
  }

  /// Unregister push notifications for this device with Vibes.
  ///
  /// - parameters:
  ///   - completion: a handler for receiving the result of unregistering this
  ///     device.
  public func unregisterPush(completion: VibesCompletion<Void>?) {
    guard let credential = self.credentialManager.currentCredential else {
      completion?(.failure(.noCredentials))
      return
    }

    let resource = APIDefinition.unregisterPush(appId: appId, deviceId: credential.deviceId)
    retryableRequest(credential: credential, resource: resource) { result in
      completion?(result)
    }
  }

  /// Tracks events with Vibes.
  ///
  /// - parameters:
  ///   - events: the Events to track, e.g. [.launch]
  ///   - completion: a handler for receiving the result of tracking the events
  ///     (it returns an Array of the events that have been tracked)
  func track(events incomingEvents: [Event], completion: VibesCompletion<[Event]>? = nil) {
    guard let credential = self.credentialManager.currentCredential else {
      completion?(.failure(.noCredentials))
      return
    }

    guard incomingEvents.first != nil else {
      completion?(.failure(.noEvents))
      return
    }

    guard Set(incomingEvents.map { $0.type }).count == 1 else {
      completion?(.failure(.tooManyEventTypes))
      return
    }

    eventStorage.tracking(events: incomingEvents) { outgoingEvents, trackingCompletion in
      let resource = APIDefinition.trackEvents(appId: appId, deviceId: credential.deviceId, events: outgoingEvents)

      retryableRequest(credential: credential, resource: resource) { result in
        switch result {
        case .success:
          trackingCompletion(VibesResult.success())
          completion?(VibesResult.success(outgoingEvents))
        case .failure(let error):
          completion?(VibesResult.failure(error))
        }
      }
    }
  }

  /// Makes a request to the Vibes API that can be retried once _if_ the initial
  /// response was that authentication failed on the initial request.
  ///
  /// - parameters:
  ///   - resource: the `HTTPResource` to request from the API
  ///   - credential: the `Credential` to use for the request
  ///   - completion: a handler for receiving the result of the request
  private func retryableRequest<A>(credential: Credential, resource: HTTPResource<A>, completion: VibesCompletion<A>?) {
    self.api.request(authToken: credential.authToken, resource: resource) {[weak self] initialResult in
      if case .failure(.invalidResponse(statusCode: 401, responseText: _)) = initialResult {
        self?.updateDevice { updateResult in
          switch updateResult {
          case .success(let newCredential):
            self?.api.request(authToken: newCredential.authToken, resource: resource) { lastChanceResult in
              completion?(VibesResult<A>(lastChanceResult))
            }
          case .failure(let error):
            completion?(VibesResult<A>.failure(error))
          }
        }
      } else {
        let vibesResult = VibesResult<A>(initialResult)
        completion?(vibesResult)
      }
    }
  }
}
