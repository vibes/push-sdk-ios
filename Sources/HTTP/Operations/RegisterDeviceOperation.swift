//
//  RegisterDeviceOperation.swift
//  VibesPush-iOS
//
//  Created by Jean-Michel Barbieri on 2/21/18.
//  Copyright © 2018 Vibes. All rights reserved.
//
import Foundation

internal class RegisterDeviceOperation: BaseOperation<VibesCredential> {
    fileprivate let resource: () -> HTTPResource<VibesCredential>
    fileprivate weak var delegate: VibesAPIDelegate?
    fileprivate var callback: VibesCompletion<VibesCredential>?
    /// Completion handler responsible for notifying sdk users
    private lazy var completionHandler: VibesCompletion<VibesCredential> = {[weak self] (result) in
        switch result {
        case .success(let credential):
            self?.credentialManager.currentCredential = credential
            self?.credentialManager.addCredential(credential)
            self?.delegate?.didRegisterDevice?(deviceId: credential.deviceId, error: nil)
            self?.callback?(.success(credential))
        case .failure(let error):
            self?.delegate?.didRegisterDevice?(deviceId: nil, error: error)
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
    ///   - delegate: VibesAPIDelegate.
    public init(credentials: CredentialManager,
                api: VibesAPIType,
                advertisingId: String,
                appId: String,
                delegate: VibesAPIDelegate?,
                callback: VibesCompletion<VibesCredential>? = nil) {
        self.delegate = delegate
        self.callback = callback
        resource = {
            let device = Device(advertisingIdentifier: advertisingId)
            return APIDefinition.registerDevice(appId: appId, device: device)
        }
        super.init(credentials: credentials, api: api, advertisingId: advertisingId, appId: appId)
    }

    /// Override BaseOperation validateOperation: For this request we don't want to check
    /// if the credentials exists.
    override func validateOperation() -> VibesError? {
        return nil
    }

    // Execute the operation
    override func start() {
        super.start()
        if let credentials = self.credentialManager.currentCredential {
            completionHandler(VibesResult<VibesCredential>.success(credentials))
            finish()
            return
        }
        super.execute(resource: resource, completion: completionHandler)
    }
}
