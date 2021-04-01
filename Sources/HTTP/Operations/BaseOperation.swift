//
//  BackendOperation.swift
//  VibesPush-iOS
//
//  Created by Jean-Michel Barbieri on 2/21/18.
//  Copyright © 2018 Vibes. All rights reserved.
//
import Foundation

struct VibesQueueConstant {
    static let NONE = ""
    static let MAX_RETRY = 3
    static let MAX_SEC: UInt32 = 15
}

internal class BaseOperation<A>: VibesQueueOperation {
    internal var credentialManager: CredentialManager
    fileprivate let api: VibesAPIType
    fileprivate let advertisingId: String
    fileprivate let appId: String
    fileprivate let MAX_SEC = 15

    /// Initialize this object
    ///
    /// - parameters:
    ///   - credentialManager: an object to store credentials, keeping track of the current Credential..
    ///   - api: an object that allows talking to the Vibes API
    ///   - advertisingId: AdSupport.advertisingId
    ///   - appId: the application ID provided by Vibes to identify this application
    init(credentials: CredentialManager,
         api: VibesAPIType,
         advertisingId: String,
         appId: String) {
        self.credentialManager = credentials
        self.api = api
        self.advertisingId = advertisingId
        self.appId = appId

        super.init()
    }

    /// If the auth token expires (error 401), this method is called before retrying to execute the failing request.
    /// It requests a new auth token, and if the call is successful, store it locally in the keychain.
    /// - parameters:
    ///   - completion: a handler for receiving the result of updating the auth token
    fileprivate func updateDeviceToken(completion: @escaping VibesCompletion<VibesCredential>) {
        guard let credential = credentialManager.currentCredential else {
            // Should never be the case as we check credential for every request except reg_device
            completion(VibesResult<VibesCredential>.failure(.noCredentials))
            return
        }
        let device = Device(advertisingIdentifier: self.advertisingId)
        let resource = APIDefinition.updateDevice(appId: self.appId, deviceId: credential.deviceId, device: device)

        self.api.request(authToken: credential.authToken, resource: resource) {[weak self] apiResult in
            if case .success(let credential) = apiResult {
                self?.credentialManager.currentCredential = credential
                self?.credentialManager.addCredential(credential)
            }
            completion(VibesResult<VibesCredential>(apiResult))
        }
    }

    /// Validate that credentials aren't nil
    /// - returns:
    ///     - VibesError: .noCredential if currentCredential are nil
    func validateOperation() -> VibesError? {
        if self.credentialManager.currentCredential == nil {
            return .noCredentials
        }
        return nil
    }

    /// Method called to execute a new http request. The request might be first added to a queue. This persisted queue
    /// will be reexecuted later on, if for instance a request is failing, even after several attempts.
    /// Between each request attempt, there is a delay of several seconds (random(15s))
    /// - parameters:
    ///   - type: the request type (ex: REG_DEVICE, REG_PUSH ...)
    ///   - retry: Number of retry if the request is failing. By default, if no value is provided, the retry == 2
    ///   - resource: The resource to request
    ///   - completion: Completion block executed after the request execution.
    internal func execute<A>(retry: Int = VibesQueueConstant.MAX_RETRY,
                             resource: @escaping () -> HTTPResource<A>,
                             completion: @escaping VibesCompletion<A>) {
        if let error = validateOperation() {
            completion(VibesResult.failure(error))
            self.finish()
            return
        }
        let retry = (retry > VibesQueueConstant.MAX_RETRY) ? VibesQueueConstant.MAX_RETRY : retry
        // if the auth_token is nil, 'Authorization' is not injected in the header (see class AuthTokenBehavior)
        let authToken = self.credentialManager.currentCredential?.authToken
        self.api.request(authToken: authToken, resource: resource()) {[weak self] initialResult in
            // Check for Token expiration error. If so, this piece of code get a new auth_token and retry the request.
            guard let _self = self else { return }

            func doRetry() {
                guard retry == 0 else {
                    // When run in a unit Test, DispatchQueue.asynAfter... throws an exception.
                    if Vibes.isRunningThroughUnitTest {
                        self?.execute(retry: retry - 1, resource: resource, completion: completion)
                    } else {
                      let randomDelay = Int(arc4random_uniform(VibesQueueConstant.MAX_SEC))
                        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + .seconds(randomDelay)) {
                          self?.execute(retry: retry - 1, resource: resource, completion: completion)
                        }
                    }
                    return
                }
                let vibesResult = VibesResult<A>(initialResult)
                completion(vibesResult)
                _self.finish()
            }

            switch initialResult {
            case .failure(.unauthorized):
                _self.updateDeviceToken(completion: { updateResult in
                    switch updateResult {
                    case .success:
                        _self.execute(retry: retry, resource: resource, completion: completion)
                    case .failure(let error):
                        completion(VibesResult<A>.failure(error))
                        _self.finish()
                    }
                })
            case .failure(.unreachable):
                doRetry()
            case .failure(.invalidResponse(let statusCode, _)) where statusCode.isStatusCodeForRetryableServerError():
                doRetry()
            default:
                let vibesResult = VibesResult<A>(initialResult)
                completion(vibesResult)
                _self.finish()
            }
        }
    }
}
