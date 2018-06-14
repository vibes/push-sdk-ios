//
//  VibesAPIDelegate.swift
//  VibesPush-iOS
//
//  Created by Jean-Michel Barbieri on 3/8/18.
//  Copyright © 2018 Vibes. All rights reserved.
//
import Foundation

@objc public protocol VibesAPIDelegate {
    /// Callback to inform SDK users of the result of the device registration
    /// - parameters:
    ///     - deviceId: the vibes device id that uniquely identifies the registered device
    ///     - error: Registration device error
    @objc optional func didRegisterDevice(deviceId: String?, error: Error?)
    
    /// Callback to inform SDK users of the result of the device unregistration
    /// - parameters:
    ///     - error: Unregistration device error
    @objc optional func didUnregisterDevice(error: Error?)
    
    /// Callback to inform SDK users of the result of the device push registration
    /// - parameters:
    ///     - error: Push registration error
    @objc optional func didRegisterPush(error: Error?)
    
    /// Callback to inform SDK users of the result of the device push unregistration
    /// - parameters:
    ///     - error: Push unregistration error
    @objc optional func didUnregisterPush(error: Error?)
    
    /// Callback to inform SDK users of the result of the device location update
    /// - parameters:
    ///     - error: Location update error
    @objc optional func didUpdateDeviceLocation(error: Error?)
}
