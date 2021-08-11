/// Migration callback Operation
internal class MigrationCallbackOperation: BaseOperation<Void> {
    fileprivate let resource: () -> HTTPResource<Void>
    fileprivate var callback: VibesCompletion<Void>?

    /// Completion handler responsible for notifying sdk users
    fileprivate lazy var completionHandler: VibesCompletion<Void> = { [weak self] result in
        switch result {
        case .success:
            self?.callback?(.success(()))
        case let .failure(error):
            self?.callback?(.failure(error))
        }
    }

    /// Initialize this object
    ///
    /// - parameters:
    ///   - credentialManager: an object to store credentials, keeping track of the current Credential..
    ///   - api: an object that allows talking to the Vibes API
    ///   - advertisingId: AdSupport.advertisingId
    ///   - appId: the application ID provided by Vibes to identify this application
    ///   - migrationItemId: The migration item Id
    ///   - vibesDeviceId: Vibes Device Id
    ///   - callback: MigrationCallback (Error?)
    public init(credentials: CredentialManager,
                api: VibesAPIType,
                advertisingId: String,
                appId: String,
                migrationItemId: String,
                vibesDeviceId: String,
                callback: VibesCompletion<Void>? = nil) {
        self.callback = callback
        resource = {
            APIDefinition.migrationCallback(appId: appId, migrationItemId: migrationItemId, vibesDeviceId: vibesDeviceId)
        }
        super.init(credentials: credentials, api: api, advertisingId: advertisingId, appId: appId)
    }

    /// Execute the operation.
    override func start() {
        super.start()
        super.execute(resource: resource, completion: completionHandler)
    }
}
