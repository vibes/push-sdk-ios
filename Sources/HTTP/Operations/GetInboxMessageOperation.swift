//
//  GetInboxMessageOperation.swift
//  VibesPush-iOS
//
//  Created by Moin' Victor on 22/10/2019.
//  Copyright © 2019 Vibes. All rights reserved.
//

import Foundation

/// Get Inbox Messages Operation
internal class GetInboxMessageOperation: BaseOperation<InboxMessage> {
    fileprivate let storage: LocalStorageType
    fileprivate let resource: () -> HTTPResource<InboxMessage>
    fileprivate var callback: GetInboxMessageCallback

    /// Completion handler responsible for notifying sdk users
    fileprivate lazy var completionHandler: VibesCompletion<InboxMessage> = { [weak self] result in
        switch result {
        case let .success(message):
            self?.callback(message, nil)
        case let .failure(error):
            self?.callback(nil, error)
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
    ///   - messageUID: The alppanumeric message UID
    ///   - callback: GetInboxMessageCallback (InboxMessage?, Error?)
    public init(credentials: CredentialManager,
                storage: LocalStorageType,
                api: VibesAPIType,
                advertisingId: String,
                appId: String,
                personKey: String,
                messageUID: String,
                callback: @escaping GetInboxMessageCallback) {
        self.callback = callback
        self.storage = storage
        resource = {
            APIDefinition.getInboxMessage(appId: appId, personKey: personKey, messageUID: messageUID)
        }
        super.init(credentials: credentials, api: api, advertisingId: advertisingId, appId: appId)
    }

    /// Execute the operation
    override func start() {
        super.start()
        super.execute(resource: resource, completion: completionHandler)
    }
}
