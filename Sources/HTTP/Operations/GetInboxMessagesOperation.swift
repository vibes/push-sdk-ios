//
//  GetInboxMessagesOperation.swift
//  VibesPush-iOS
//
//  Created by Moin' Victor on 16/07/2019.
//  Copyright © 2019 Vibes. All rights reserved.
//

import Foundation

/// Get Inbox Messages Operation
internal class GetInboxMessagesOperation: BaseOperation<[InboxMessage]> {
    fileprivate let storage: LocalStorageType
    fileprivate let resource: () -> HTTPResource<[InboxMessage]>
    fileprivate var callback: GetInboxMessagesCallback?

    /// Completion handler responsible for notifying sdk users
    fileprivate lazy var completionHandler: VibesCompletion<[InboxMessage]> = { [weak self] result in
        switch result {
        case let .success(messages):
            self?.callback?(messages, nil)
        case let .failure(error):
            self?.callback?([], error)
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
    ///   - callback: GetInboxMessagesCallback ([InboxMessage], Error?)
    public init(credentials: CredentialManager,
                storage: LocalStorageType,
                api: VibesAPIType,
                advertisingId: String,
                appId: String,
                personKey: String,
                callback: GetInboxMessagesCallback? = nil) {
        self.callback = callback
        self.storage = storage
        resource = {
            APIDefinition.getInboxMessages(appId: appId, personKey: personKey) 
        }
        super.init(credentials: credentials, api: api, advertisingId: advertisingId, appId: appId)
    }

    /// Execute the operation
    override func start() {
        super.start()
        super.execute(resource: resource, completion: completionHandler)
    }
}
