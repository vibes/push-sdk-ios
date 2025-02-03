//
//  Purchase.swift
//  VibesPush
//
//  Created by Clement  Wekesa on 19/08/2022.
//  Copyright © 2022 Vibes. All rights reserved.
//

import Foundation

@objcMembers
public class Purchase: NSObject, JSONDecodable, LocalObjectType {
    public var attributes: [String: Any] {
        return [
            "id": id ?? "",
            "affiliation": affiliation ?? "",
            "revenue": revenue ?? "",
            "tax": tax ?? "",
            "shipping": shipping ?? "",
            "coupon": coupon ?? "",
            "list": list ?? "",
            "step": step ?? "",
            "option": option ?? "",
            "products": products ?? "",
        ]
    }

    public var id: String?
    public var affiliation: String?
    public var revenue: Double?
    public var tax: Double?
    public var shipping: Double?
    public var coupon: Double?
    public var list: String?
    public var step: String?
    public var option: String?
    public var products: [Product]?

    override init() {
    }

    /// Initialize for testing
    ///
    public init(id: String, affiliation: String, revenue: Double, tax: Double,
                shipping: Double,  coupon: Double,  list: String,  step: String,
                option: String, products: [Product]) {
        self.id = id
        self.affiliation = affiliation
        self.revenue = revenue
        self.tax = tax
        self.shipping = shipping
        self.coupon = coupon
        self.list = list
        self.step = step
        self.option = option
        self.products = products
    }

    /// Initialize this object using JSONObject
    ///
    /// - Parameter json: The JSONObject
    required convenience init?(json: VibesJSONDictionary) {
        self.init()

        guard let id = json["id"] as? String else { return nil }
        self.id = id
        affiliation = json["affiliation"] as? String
        revenue = json["revenue"] as? Double
        tax = json["tax"] as? Double
        shipping = json["shipping"] as? Double
        coupon = json["coupon"] as? Double
        list = json["list"] as? String
        step = json["step"] as? String
        option = json["option"] as? String
        products = json["products"] as? [Product]
        
    }

    /// Initialize this object using Attributes
    ///
    /// - Parameter attributes: - The dictionary with attributes
    public required convenience init?(attributes: [String: Any]) {
        self.init()
        guard let id = attributes["id"] as? String,
            !id.isEmpty else { return nil }

        self.id = id
        affiliation = attributes["affiliation"] as? String
        revenue = attributes["revenue"] as? Double
        tax = attributes["tax"] as? Double
        shipping = attributes["shipping"] as? Double
        coupon = attributes["coupon"] as? Double
        list = attributes["list"] as? String
        step = attributes["step"] as? String
        option = attributes["option"] as? String
        products = attributes["products"] as? [Product]
    }
}

/// Equals Comparison operator for Product
///
/// - Parameters:
///   - lhs: The left hand side Product
///   - rhs: The right hand side Product
/// - Returns: `True` if `lhs` is equal to `rhs`, else returns `False`
public func == (lhs: Purchase, rhs: Purchase) -> Bool {
    return lhs.id == rhs.id
}
