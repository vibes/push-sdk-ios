//
//  TrackPurchaseActionOperation.swift
//  VibesPush
//
//  Created by Clement  Wekesa on 18/08/2022.
//  Copyright © 2022 Vibes. All rights reserved.
//

import Foundation

/// Track Product Action Operation
internal class TrackPurchaseActionOperation: BaseOperation<Void> {
    fileprivate let storage: LocalStorageType
    fileprivate let resource: () -> HTTPResource<Void>
    fileprivate var callback: TrackPurchaseActionCallback?

    /// Completion handler responsible for notifying sdk users
    fileprivate lazy var completionHandler: VibesCompletion<Void> = { [weak self] result in
        switch result {
        case let .success(messages):
            self?.callback?(nil)
        case let .failure(error):
            self?.callback?(error)
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
    ///   - action: The purchase action
    ///   - purchase: The purchase
    ///   - data: The Vibes tracking data
    ///   - activityUid: The activity UID
    ///   - callback: TrackPurchaseActionCallback ([Success], Error?)
    public init(credentials: CredentialManager,
                storage: LocalStorageType,
                api: VibesAPIType,
                advertisingId: String,
                appId: String,
                action: PurchaseAction,
                purchase: Purchase,
                data: VibesTrackingData,
                activityUid: String?,
                callback: TrackPurchaseActionCallback? = nil) {
        self.callback = callback
        self.storage = storage
        resource = {
            APIDefinition.trackPurchaseAction(action: action,
                                              purchase: purchase,
                                              data: data,
                                              activityUid: activityUid)
        }
        super.init(credentials: credentials,
                   api: api,
                   advertisingId: advertisingId,
                   appId: appId)
    }

    /// Override BaseOperation validateOperation: For this request we don't want to check
    /// if the credentials exists.
    override func validateOperation() -> VibesError? {
        return nil
    }

    /// Whether to inject the auth header, override and return false to disable `Authorization` header in the request
    /// - Returns: `true` or `false`
    override func injectAuthHeader() -> Bool {
        return false
    }

    /// Execute the operation
    override func start() {
        super.start()
        super.execute(resource: resource, completion: completionHandler)
    }
}
