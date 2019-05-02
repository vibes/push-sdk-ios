//
//  UpdateDeviceOperation.swift
//  VibesPush-iOS
//
//  Created by Jean-Michel Barbieri on 2/21/18.
//  Copyright © 2018 Vibes. All rights reserved.
//

internal class UpdateDeviceOperation: BaseOperation<Void> {
    fileprivate let resource: () -> HTTPResource<Void>
    fileprivate weak var delegate: VibesAPIDelegate?

    /// Completion handler responsible for notifying sdk users
    fileprivate lazy var completionHandler: VibesCompletion<Void> = {[weak self] (result) in
        switch result {
        case .success :
            self?.delegate?.didUpdateDeviceLocation?(error: nil)
        case .failure(let error) :
            self?.delegate?.didUpdateDeviceLocation?(error: error)
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
                location: (lat: Double, long: Double)) {
        self.delegate = delegate
        let device = Device(advertisingIdentifier: advertisingId, location: location)
        resource = {
            let deviceId = credentials.currentCredential?.deviceId ?? VibesQueueConstant.NONE
            return APIDefinition.updateDeviceInfo(appId: appId, deviceId: deviceId, device: device)
        }
        super.init(credentials: credentials, api: api, advertisingId: advertisingId, appId: appId)
    }

    /// Execute the operation
    override func start() {
        super.start()
        super.execute(retry: 0, resource: resource, completion: completionHandler)
    }
}
