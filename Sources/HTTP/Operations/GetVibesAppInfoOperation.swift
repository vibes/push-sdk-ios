/// Check Vibes App Info Operation
internal class GetVibesAppInfoOperation: BaseOperation<VibesAppInfo> {
  fileprivate let storage: LocalStorageType
  fileprivate let resource: () -> HTTPResource<VibesAppInfo>
  fileprivate var callback: GetVibesAppInfoCallback?

  /// Completion handler responsible for notifying sdk users
  fileprivate lazy var completionHandler: VibesCompletion<VibesAppInfo> = { [weak self] result in
    switch result {
    case let .success(status):
      self?.callback?(status, nil)
    case let .failure(error):
      self?.callback?(nil, error)
    }
  }

  /// Initialize this object
  ///
  /// - parameters:
  ///   - credentialManager: an object to store credentials, keeping track of the current Credential..
  ///   - storage: an object that allows storing data locally
  ///   - api: an object that allows talking to the Vibes API
  ///   - advertisingId: AdSupport.advertisingId
  ///   - appId: the application ID provided by Vibes to identify this application
  ///   - callback: GetVibesAppInfoCallback (status?, Error?)
  public init(credentials: CredentialManager,
              storage: LocalStorageType,
              api: VibesAPIType,
              advertisingId: String,
              appId: String,
              callback: GetVibesAppInfoCallback? = nil) {
    self.callback = callback
    self.storage = storage
    resource = {
      APIDefinition.fetchVibesAppInfo(appId: appId)
    }
    super.init(credentials: credentials, api: api, advertisingId: advertisingId, appId: appId)
  }

  /// Execute the operation
  override func start() {
    super.start()
    super.execute(resource: resource, completion: completionHandler)
  }
}
