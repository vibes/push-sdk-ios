//
//  RegisterPushOperation.swift
//  VibesPush-iOS
//
//  Created by Jean-Michel Barbieri on 2/21/18.
//  Copyright © 2018 Vibes. All rights reserved.
//
import Foundation

internal class RegisterPushOperation: BaseOperation<Void> {
    fileprivate let storage: LocalStorageType
    fileprivate let resource: () -> HTTPResource<Void>
    fileprivate weak var delegate: VibesAPIDelegate?

    /// Completion handler responsible for notifying sdk users
    fileprivate lazy var completionHandler: VibesCompletion<Void> = {[weak self] (result) in
        switch result {
        case .success :
            let userDefaults = UserDefaults.standard
            userDefaults.setValue(true, forKey: Vibes.REGISTER_PUSH_STATUS)
            userDefaults.synchronize()
            self?.delegate?.didRegisterPush?(error: nil)
        case .failure(let error) :
            self?.delegate?.didRegisterPush?(error: error)
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
                storage: LocalStorageType,
                api: VibesAPIType,
                advertisingId: String,
                appId: String,
                delegate: VibesAPIDelegate?) {
        self.delegate = delegate
        self.storage = storage
        resource = {
            let deviceId = credentials.currentCredential?.deviceId ?? VibesQueueConstant.NONE
            let pushToken = storage.get(LocalStorageKeys.pushToken) ?? VibesQueueConstant.NONE
            return APIDefinition.registerPush(appId: appId, deviceId: deviceId, pushToken: pushToken)
        }
        super.init(credentials: credentials, api: api, advertisingId: advertisingId, appId: appId)
    }

    /// Validate that the push token exists and the credentials aren't nil (super class)
    /// - returns:
    ///     - VibesError: nullable error
    override func validateOperation() -> VibesError? {
        if self.storage.get(LocalStorageKeys.pushToken) == nil {
            return .noPushToken
        }
        return super.validateOperation()
    }

    /// Execute the operation
    override func start() {
        super.start()
        super.execute(resource: resource, completion: completionHandler)
    }
}
