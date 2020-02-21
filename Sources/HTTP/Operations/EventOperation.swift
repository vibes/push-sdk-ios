//
//  EventOperation.swift
//  VibesPush-iOS
//
//  Created by Jean-Michel Barbieri on 2/21/18.
//  Copyright © 2018 Vibes. All rights reserved.
//

internal class EventOperation: BaseOperation<[Event]> {
    fileprivate let completion: VibesCompletion<[Event]>?
    fileprivate let resource: () -> HTTPResource<Void>
    fileprivate let outgoingEvents: [Event]
    fileprivate let trackCompletion: (VibesResult<Void>) -> Void?

    /// Initialize this object
    ///
    /// - parameters:
    ///   - credentialManager: an object to store credentials, keeping track of the current Credential..
    ///   - api: an object that allows talking to the Vibes API
    ///   - advertisingId: AdSupport.advertisingId
    ///   - appId: the application ID provided by Vibes to identify this application
    ///   - completion: Vibes completion block executed by BaseOperation when the request is finished.
    ///   - outgoingEvents: contains the list of event to send
    ///   - trackCompletion: Completion block for the tracking system
    public init(credentials: CredentialManager,
                api: VibesAPIType,
                advertisingId: String,
                appId: String,
                completion: VibesCompletion<[Event]>?,
                outgoingEvents: [Event],
                trackCompletion: @escaping (VibesResult<Void>) -> Void?) {
        self.completion = completion
        self.outgoingEvents = outgoingEvents
        self.trackCompletion = trackCompletion
        self.resource = {
            let deviceId = credentials.currentCredential?.deviceId ?? VibesQueueConstant.NONE
            return APIDefinition.trackEvents(appId: appId, deviceId: deviceId, events: outgoingEvents)
        }
        super.init(credentials: credentials, api: api, advertisingId: advertisingId, appId: appId)
    }

    /// Validate that the event are present and that the event sending concerns only one type.
    /// Super will validate that credential exist.
    /// - returns:
    ///     - VibesError: nullable error
    override func validateOperation() -> VibesError? {
        guard outgoingEvents.first != nil else {
            completion?(.failure(.noEvents))
            return .noEvents
        }

        guard Set(outgoingEvents.map { $0.type }).count == 1 else {
            completion?(.failure(.tooManyEventTypes))
            return .tooManyEventTypes
        }

        return super.validateOperation()
    }

    /// Execute the operation
    override func start() {
        super.start()
        super.execute(retry: 0, resource: resource) {[weak self] result in
            switch result {
            case .success:
                self?.trackCompletion(VibesResult.success(()))
                self?.completion?(VibesResult.success((self?.outgoingEvents)!))
            case .failure(let error):
                self?.completion?(VibesResult.failure(error))
            }
        }
    }
}
