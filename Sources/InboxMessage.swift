//
//  InboxMessage.swift
//  VibesPush
//
//  Created by Moin' Victor on 12/07/2019.
//  Copyright © 2019 Vibes. All rights reserved.
//

import Foundation

/// Inbox Message Model
public class InboxMessage: NSObject, JSONDecodable, LocalObjectType, JSONEncodable {

    static let kActivityTypeKey = "activityType";
    static let kActivityUidKey = "activityUid";

    static let eActivityTypeKey = "activity_type";
    static let eActivityUidKey = "activity_uid";
    static let eMessageUidKey = "message_uid";

    /// Local Atrributes
    public var attributes: [String: Any] {
        return [
            "message_uid": messageUID ?? "",
            "subject": subject ?? "",
            "content": content ?? "",
            "detail": detail ?? "",
            "expires_at": expiresAt ?? Date(),
            "created_at": createdAt,
            "collapse_key": collapseKey ?? "",
            "images": images,
            "read": read,
            "inbox_custom_data": inboxCustomData,
            "client_app_data": clientAppData,
            "apprefdata": apprefData,
        ]
    }

    func encodeJSON() -> VibesJSONDictionary {
        return [
            "message_uid": messageUID as AnyObject,
            "subject": subject as AnyObject,
            "content": content as AnyObject,
            "detail": detail as AnyObject,
            "expires_at": expiresAt?.iso8601 as AnyObject,
            "created_at": createdAt.iso8601 as AnyObject,
            "collapse_key": collapseKey as AnyObject,
            "images": images as AnyObject,
            "read": read as AnyObject,
            "inbox_custom_data": inboxCustomData as AnyObject,
            "client_app_data": clientAppData as AnyObject,
            "apprefdata": apprefData as AnyObject,
        ] as VibesJSONDictionary
    }

    public var jsonString: String? {
        let jsonData = try? JSONSerialization.data(withJSONObject: encodeJSON(), options: .prettyPrinted)
        return String(data: jsonData!, encoding: .utf8)
    }

    /// Main Image for this inbox message
    @objc public var mainImage: String? {
        return images["main"]
    }

    /// Icon image for this push message
    @objc public var iconImage: String? {
        return images["icon"]
    }

    /// Inbox message uid
    @objc public var inboxMessageUID: String? {
        return clientAppData["inbox_message_uid"] as? String
    }

    /// An uniqie identifier assosiated with the message
    @objc public internal(set) var messageUID: String?
    /// The collapse key
    @objc public internal(set) var collapseKey: String?
    /// The subject of the message
    @objc public var subject: String?
    /// A message content
    @objc public var content: String?
    /// Some details for this message, Currently this is the media URL
    @objc public internal(set) var detail: String?
    /// If the message is read
    @objc public var read: Bool = false
    /// images details for this message
    @objc public internal(set) var images = [String: String]()
    /// inbox custom data details for this message
    @objc public internal(set) var inboxCustomData = VibesJSONDictionary()
    /// client app data details for this message
    @objc public internal(set) var clientAppData = VibesJSONDictionary()
    /// Appref data details for this message
    @objc public internal(set) var apprefData = VibesJSONDictionary()
    /// When the message expires
    @objc public var expiresAt: Date?
    /// When the message was created
    @objc public internal(set) var createdAt: Date = Date()

    override init() {
    }

    /// Initialize new InboxMessage using properties
    ///
    /// - Parameters:
    ///   - messageUID: The message id
    ///   - subject: The subject of the message
    ///   - content: The content of the message
    ///   - detail: The message details
    ///   - readStatus: The read status of the message in bool
    ///   - expiresAt: Date when the message expires
    init(messageUID: String, subject: String, content: String, detail: String, read: Bool, expiresAt: Date? = nil) {
        self.messageUID = messageUID
        self.subject = subject
        self.content = content
        self.detail = detail
        self.read = read
        self.expiresAt = expiresAt
    }

    /// Initialize new InboxMessage from JSONObject
    ///
    /// - Parameter json: The JSON object
    required convenience init?(json: VibesJSONDictionary) {
        self.init()
        guard let messageUID = json["message_uid"] as? String,
            let subject = json["subject"] as? String,
            let content = json["content"] as? String else { return nil }

        detail = json["detail"] as? String
        collapseKey = json["collapse_key"] as? String
        if let readStatusValue = json["read"] as? Bool {
            read = readStatusValue
        }
        if let expireDateString = json["expires_at"] as? String,
            let expireDateTime = expireDateString.iso8601 {
            expiresAt = expireDateTime
        }
        if let createdDateString = json["created_at"] as? String,
            let createdDateTime = createdDateString.iso8601 {
            createdAt = createdDateTime
        }
        if let images = json["images"] as? [String: String] {
            self.images = images
        }
        if let inboxCustomData = json["inbox_custom_data"] as? VibesJSONDictionary {
            self.inboxCustomData = inboxCustomData
        }
        if let clientAppData = json["client_app_data"] as? VibesJSONDictionary {
            self.clientAppData = clientAppData
        }
        if let apprefData = json["apprefdata"] as? VibesJSONDictionary {
            self.apprefData = apprefData
        }
        self.messageUID = messageUID
        self.subject = subject
        self.content = content
    }

    /// Initialize this object using Attributes
    ///
    /// - Parameter attributes: - The dictionary with attributes
    public required convenience init?(attributes: [String: Any]) {
        self.init()

        guard let messageUID = attributes["message_uid"] as? String, !messageUID.isEmpty,
            let subject = attributes["subject"] as? String,
            let content = attributes["content"] as? String else { return nil }
        detail = attributes["detail"] as? String
        collapseKey = attributes["collapse_key"] as? String
        if let readStatusValue = attributes["read"] as? Bool {
            read = readStatusValue
        }
        if let expireDate = attributes["expires_at"] as? Date {
            expiresAt = expireDate
        }
        if let createdDateTime = attributes["created_at"] as? Date {
            createdAt = createdDateTime
        }
        if let images = attributes["images"] as? [String: String] {
            self.images = images
        }
        if let inboxCustomData = attributes["inbox_custom_data"] as? VibesJSONDictionary {
            self.inboxCustomData = inboxCustomData
        }
        if let clientAppData = attributes["client_app_data"] as? VibesJSONDictionary {
            self.clientAppData = clientAppData
        }
        if let apprefData = attributes["apprefdata"] as? VibesJSONDictionary {
            self.apprefData = apprefData
        }
        self.messageUID = messageUID
        self.subject = subject
        self.content = content
    }
}

/// Equals Comparison operator for InboxMessage
///
/// - Parameters:
///   - lhs: The left hand side InboxMessage
///   - rhs: The right hand side InboxMessage
/// - Returns: `True` if `lhs` is equal to `rhs`, else returns `False`
public func == (lhs: InboxMessage, rhs: InboxMessage) -> Bool {
    return lhs.messageUID == rhs.messageUID
}

extension InboxMessage {

    /// The vent map for this inbox message
    internal func eventMap() -> [String: String] {
        var evMap = [String: String]()
        evMap[InboxMessage.eMessageUidKey] = messageUID
        evMap[InboxMessage.eActivityTypeKey] = apprefData[InboxMessage.kActivityTypeKey] as? String
        evMap[InboxMessage.eActivityUidKey] = apprefData[InboxMessage.kActivityUidKey] as? String
        return evMap
    }
}
