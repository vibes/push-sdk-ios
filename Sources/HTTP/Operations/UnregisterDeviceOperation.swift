//
//  UnregisterDeviceOperation.swift
//  VibesPush-iOS
//
//  Created by Jean-Michel Barbieri on 2/21/18.
//  Copyright © 2018 Vibes. All rights reserved.
//
import Foundation

internal class UnregisterDeviceOperation: BaseOperation<Void> {
    fileprivate weak var delegate: VibesAPIDelegate?
    fileprivate let resource: () -> HTTPResource<Void>
    fileprivate var callback: VibesCompletion<Void>?

    /// Completion handler responsible for notifying sdk users
    fileprivate lazy var completionHandler: VibesCompletion<Void> = {[weak self] (result) in
        switch result {
        case .success:
            self?.credentialManager.currentCredential = nil
            let userDefaults = UserDefaults.standard
            userDefaults.removeObject(forKey: Vibes.REGISTER_PUSH_STATUS)
            userDefaults.synchronize()
            self?.callback?(.success(()))
            self?.delegate?.didUnregisterDevice?(error: nil)
        case .failure(let error):
            if let credential = self?.credentialManager.currentCredential {
                self?.credentialManager.removeCredential(credential)
            }
            self?.callback?(.success(()))
            self?.delegate?.didUnregisterDevice?(error: nil)
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
    ///   - delegate: VibesAPIDelegate.
    public init(credentials: CredentialManager,
                api: VibesAPIType,
                advertisingId: String,
                appId: String,
                delegate: VibesAPIDelegate?,
                callback: VibesCompletion<Void>? = nil) {
        self.delegate = delegate
        self.callback = callback
        resource = {
            let deviceId = credentials.currentCredential?.deviceId ?? VibesQueueConstant.NONE
            return APIDefinition.unregisterDevice(appId: appId, deviceId: deviceId)
        }
        super.init(credentials: credentials, api: api, advertisingId: advertisingId, appId: appId)
    }

    /// Execute the operation.
    override func start() {
        super.start()
        super.execute(resource: resource, completion: completionHandler)
    }
}
