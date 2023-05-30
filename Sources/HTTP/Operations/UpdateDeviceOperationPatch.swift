//
//  UpdateDeviceOperationPatch.swift
//  VibesPush
//
//  Created by DHwty on 17/06/2021.
//  Copyright © 2021 Vibes. All rights reserved.
//

internal class UpdateDeviceOperationPatch: BaseOperation<Void> {
    fileprivate let resource: () -> HTTPResource<Void>
    fileprivate weak var delegate: VibesAPIDelegate?
    fileprivate var callback: VibesCompletion<Void>?

    /// Completion handler responsible for notifying sdk users
    fileprivate lazy var completionHandler: VibesCompletion<Void> = {[weak self] (result) in
        switch result {
        case .success :
            self?.callback?(.success(()))
            self?.delegate?.didUpdateDevice?(error: nil)
        case .failure(let error) :
            self?.callback?(.failure(error))
            self?.delegate?.didUpdateDevice?(error: error)
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
    ///   - location: contains the current longitude and latitude
    public init(credentials: CredentialManager,
                api: VibesAPIType,
                advertisingId: String,
                appId: String,
                delegate: VibesAPIDelegate?,
                location: (lat: Double, long: Double)?,
                callback: VibesCompletion<Void>? = nil) {
        self.delegate = delegate
        self.callback = callback
        let device = Device(advertisingIdentifier: advertisingId, location: location)
        resource = {
            let deviceId = credentials.currentCredential?.deviceId ?? VibesQueueConstant.NONE
            return APIDefinition.updateDeviceInfoPatch(appId: appId, deviceId: deviceId, device: device)
        }
        super.init(credentials: credentials, api: api, advertisingId: advertisingId, appId: appId)
    }

    /// Execute the operation
    override func start() {
        super.start()
        super.execute(retry: 0, resource: resource, completion: completionHandler)
    }
}
