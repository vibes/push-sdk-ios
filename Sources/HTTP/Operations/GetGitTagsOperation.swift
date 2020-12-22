//
//  GetGitTagsOperation.swift
//  VibesPush
//
//  Created by Moin' Victor on 15/09/2020.
//  Copyright © 2020 Vibes. All rights reserved.
//

import Foundation

/// Get Git Tags Operation
internal class GetGitTagsOperation: BaseOperation<GitTag> {
    fileprivate let storage: LocalStorageType
    fileprivate let resource: () -> HTTPResource<[GitTag]>
    fileprivate var callback: GetGitTagsCallback

    /// Completion handler responsible for notifying the caller
    fileprivate lazy var completionHandler: VibesCompletion<[GitTag]> = { [weak self] result in
        switch result {
        case let .success(tags):
            self?.callback(tags, nil)
        case let .failure(error):
            self?.callback([], error)
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
    ///   - callback: GetInboxMessageCallback (InboxMessage?, Error?)
    public init(credentials: CredentialManager,
                storage: LocalStorageType,
                api: VibesAPIType,
                advertisingId: String,
                appId: String,
                callback: @escaping GetGitTagsCallback) {
        self.callback = callback
        self.storage = storage
        resource = {
            APIDefinition.getGitTags()
        }
        super.init(credentials: credentials, api: api, advertisingId: advertisingId, appId: appId)
    }

    /// Override BaseOperation validateOperation: For this request we don't want to check
    /// if the credentials exists.
    override func validateOperation() -> VibesError? {
        return nil
    }

    /// Execute the operation
    override func start() {
        super.start()
        super.execute(resource: resource, completion: completionHandler)
    }
}
