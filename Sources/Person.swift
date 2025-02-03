//
//  Person.swift
//  VibesPush
//
//  Created by clemwek on 12/07/2019.
//  Copyright © 2019 Vibes. All rights reserved.
//
import Foundation

@objcMembers
public class Person: NSObject, JSONDecodable, LocalObjectType {
    public var attributes: [String: Any] {
        return [
            "person_key": personKey ?? "",
            "external_person_id": externalPersonId ?? "",
            "mobile_phone": mobilePhone,
        ]
    }

    /// An external identifier assosiated with the device or person if available
    public var externalPersonId: String?
    /// The phone number of the assosiated person if available
    public var mdn: String?
    /// A unique identifier for the person, provided by Vibes when  assosiated.
    public var personKey: String?

    private var mobilePhone: [String: String] = [:]

    override init() {
    }

    /// Initialize for testing
    ///
    /// - Parameters:
    ///   - externalPersonId: external person id
    ///   - mdn: phone number
    ///   - personKey: person key
    init(externalPersonId: String, mdn: String, personKey: String) {
        self.externalPersonId = externalPersonId
        self.mdn = mdn
        self.personKey = personKey
    }

    /// Initialize this object using JSONObject
    ///
    /// - Parameter json: The JSONObject
    required convenience init?(json: VibesJSONDictionary) {
        self.init()

        let mdn: String?

        guard let personKey = json["person_key"] as? String else { return nil }

        if let mobilePhone = json["mobile_phone"] as? [String: String] {
            mdn = mobilePhone["mdn"]
        } else {
            mdn = nil
        }

        self.personKey = personKey
        externalPersonId = json["external_person_id"] as? String
        self.mdn = mdn
    }

    /// Initialize this object using Attributes
    ///
    /// - Parameter attributes: - The dictionary with attributes
    public required convenience init?(attributes: [String: Any]) {
        self.init()

        let mdn: String?

        guard let personKey = attributes["person_key"] as? String,
            !personKey.isEmpty else { return nil }

        if let mobilePhone = attributes["mobile_phone"] as? [String: String] {
            mdn = mobilePhone["mdn"]
        } else {
            mdn = nil
        }

        externalPersonId = attributes["external_person_id"] as? String
        self.mdn = mdn
        self.personKey = personKey
    }
}

/// Equals Comparison operator for Person
///
/// - Parameters:
///   - lhs: The left hand side Person
///   - rhs: The right hand side Person
/// - Returns: `True` if `lhs` is equal to `rhs`, else returns `False`
public func == (lhs: Person, rhs: Person) -> Bool {
    return lhs.personKey == rhs.personKey &&
        lhs.externalPersonId == rhs.externalPersonId &&
        lhs.mdn == rhs.mdn
}
