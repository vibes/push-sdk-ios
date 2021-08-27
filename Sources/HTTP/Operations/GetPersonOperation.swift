//
//  GetPersonOperation.swift
//  VibesPush-iOS
//
//  Created by clemwek on 16/07/2019.
//  Copyright © 2019 Vibes. All rights reserved.
//

/// Get Vibes Person Operation
internal class GetPersonOperation: BaseOperation<Person> {
    fileprivate let storage: LocalStorageType
    fileprivate let resource: () -> HTTPResource<Person>
    fileprivate var callback: GetPersonCallback?
    /// Completion handler responsible for notifying sdk users
    fileprivate lazy var completionHandler: VibesCompletion<Person> = { [weak self] result in
        switch result {
        case let .success(person):
            self?.callback?(person, nil)
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
    ///   - callback: GetPersonCallback (Person?, Error?)
    public init(credentials: CredentialManager,
                storage: LocalStorageType,
                api: VibesAPIType,
                advertisingId: String,
                appId: String,
                callback: GetPersonCallback? = nil) {
        self.storage = storage
        self.callback = callback
        resource = {
            let deviceId = credentials.currentCredential?.deviceId ?? VibesQueueConstant.NONE
            return APIDefinition.getPerson(appId: appId, deviceId: deviceId)
        }
        super.init(credentials: credentials, api: api, advertisingId: advertisingId, appId: appId)
    }

    /// Execute the operation
    override func start() {
        super.start()
        super.execute(resource: resource, completion: completionHandler)
    }
}
