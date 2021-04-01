//
//  InboxStatus.swift
//  VibesPush
//
//  Created by DHwty on 10/11/2020.
//  Copyright © 2020 Vibes. All rights reserved.
//

import Foundation

/// Vibes App Info
@objcMembers
public class VibesAppInfo: NSObject, JSONDecodable, LocalObjectType, JSONEncodable {

    /// Local Atrributes
    public var attributes: [String: Any] {
        return [
            "app_id": appId ?? "",
            "inbox_enabled": inboxEnabled = false,
        ]
    }

    public func encodeJSON() -> VibesJSONDictionary {
        return [
            "app_id": appId as AnyObject,
            "inbox_enabled": inboxEnabled as AnyObject,
        ] as VibesJSONDictionary
    }

    public var jsonString: String? {
        let jsonData = try? JSONSerialization.data(withJSONObject: encodeJSON(), options: .prettyPrinted)
        return String(data: jsonData!, encoding: .utf8)
    }

    /// An uniqie identifier assosiated with the app
    public internal(set) var appId: String!
    /// The app inbox status
    public internal(set) var inboxEnabled: Bool = false

    override init() {
    }

    /// Initialize new VibesAppInfo using properties
    ///
    /// - Parameters:
    ///   - appId: The app id
    ///   - inboxEnabled: The app inbox status
    init(appId: String, inboxEnabled: Bool) {
        self.appId = appId
        self.inboxEnabled = inboxEnabled
    }

    /// Initialize new VibesAppInfo from JSONObject
    ///
    /// - Parameter json: The JSON object
    required convenience init?(json: VibesJSONDictionary) {
        self.init()
        guard let appId = json["app_id"] as? String,
            let inboxEnabled = json["inbox_enabled"] as? Bool else { return nil }

        self.appId = appId
        self.inboxEnabled = inboxEnabled
    }

    /// Initialize this object using Attributes
    ///
    /// - Parameter attributes: - The dictionary with attributes
    public required convenience init?(attributes: [String: Any]) {
        self.init()

        guard let appId = attributes["app_id"] as? String, !appId.isEmpty,
            let inboxEnabled = attributes["inbox_enabled"] as? Bool else { return nil }

        self.appId = appId
        self.inboxEnabled = inboxEnabled
    }
}
