//
//  AssociatePersonOperation.swift
//  VibesPush-iOS
//
//  Created by Peter Compernolle on 5/30/2018.
//  Copyright © 2018 Vibes. All rights reserved.
//

internal class AssociatePersonOperation: BaseOperation<Void> {
    fileprivate let resource: () -> HTTPResource<Void>
    fileprivate weak var delegate: VibesAPIDelegate?
    fileprivate var callback: VibesCompletion<Void>?

    /// Completion handler responsible for notifying sdk users
    fileprivate lazy var completionHandler: VibesCompletion<Void> = {[weak self] (result) in
        switch result {
        case .success:
            self?.callback?(.success(()))
            self?.delegate?.didAssociatePerson?(error: nil)
        case .failure(let error):
            self?.callback?(.failure(error))
            self?.delegate?.didAssociatePerson?(error: error)
        }
    }

    /// Initialize this object
    ///
    /// - parameters:
    ///   - credentialManager: an object to store credentials, keeping track of the current Credential..
    ///   - api: an object that allows talking to the Vibes API
    ///   - advertisingId: AdSupport.advertisingId
    ///   - appId: the application ID provided by Vibes to identify this application
    ///   - delegate: VibesAPIDelegate.
    ///   - externalPersonId: a String representation of the third party person identifier
    public init(credentials: CredentialManager,
                api: VibesAPIType,
                advertisingId: String,
                appId: String,
                delegate: VibesAPIDelegate?,
                callback: VibesCompletion<Void>? = nil,
                externalPersonId: String) {
        self.delegate = delegate
        self.callback = callback
        resource = {
            let deviceId = credentials.currentCredential?.deviceId ?? VibesQueueConstant.NONE
            return APIDefinition.associatePerson(appId: appId, deviceId: deviceId, externalPersonId: externalPersonId)
        }
        super.init(credentials: credentials, api: api, advertisingId: advertisingId, appId: appId)
    }

    /// Execute the operation
    override func start() {
        super.start()
        super.execute(retry: 0, resource: resource, completion: completionHandler)
    }
}
