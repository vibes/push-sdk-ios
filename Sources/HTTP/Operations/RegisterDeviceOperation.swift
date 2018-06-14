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
    fileprivate let delegate: VibesAPIDelegate?
    
    /// Completion handler responsible for notifying sdk users
    private lazy var completionHandler: VibesCompletion<VibesCredential> = {[weak self] (result) in
        switch (result) {
        case .success(let credential) :
            self?.credentialManager.currentCredential = credential
            self?.credentialManager.addCredential(credential)
            self?.delegate?.didRegisterDevice?(deviceId: credential.deviceId, error: nil)
        case .failure(let error) :
            self?.delegate?.didRegisterDevice?(deviceId: nil, error: error)
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
                delegate: VibesAPIDelegate?){
        self.delegate = delegate
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
            // The device has already been registered.
            // In case we switch to another environment, the device must be unregistered first
            // before registering it against the new environment. By unregistereing the device,
            // its credentials are deleted.
            NSLog("Device already registered!")
            completionHandler(VibesResult<VibesCredential>.success(credentials))
            finish()
            return
        }
        super.execute(resource: resource, completion: completionHandler)
    }
}
