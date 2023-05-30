/// Update Inbox Messages Operation
internal class UpdateMessageOperation: BaseOperation<InboxMessage> {
    fileprivate let storage: LocalStorageType
    fileprivate let resource: () -> HTTPResource<InboxMessage>
    fileprivate var callback: UpdateMessageCallback?

    /// Completion handler responsible for notifying sdk users
    fileprivate lazy var completionHandler: VibesCompletion<InboxMessage> = { [weak self] result in
        switch result {
        case let .success(message):
            self?.callback?(message, nil)
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
    ///   - personKey: The alppanumeric person key
    ///   - messageUID: The unique UID of message to update
    ///   - callback: UpdateMessageCallback (InboxMessage?, Error?)
    public init(credentials: CredentialManager,
                storage: LocalStorageType,
                api: VibesAPIType,
                advertisingId: String,
                appId: String,
                personKey: String,
                messageUID: String,
                payload: VibesJSONDictionary,
                callback: UpdateMessageCallback? = nil) {
        self.callback = callback
        self.storage = storage
        resource = {
            APIDefinition.updateMessage(appId: appId, personKey: personKey, messageUID: messageUID, payload: payload)
        }
        super.init(credentials: credentials, api: api, advertisingId: advertisingId, appId: appId)
    }

    /// Execute the operation
    override func start() {
        super.start()
        super.execute(resource: resource, completion: completionHandler)
    }
}
