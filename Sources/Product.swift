//
//  Product.swift
//  VibesPush
//
//  Created by Moin' Victor on 11/08/2022.
//  Copyright © 2022 Vibes. All rights reserved.
//

import Foundation

@objcMembers
public class Product: NSObject, JSONDecodable, LocalObjectType {
    public var attributes: [String: Any] {
        return [
            "id": id ?? "",
            "price": price ?? "",
            "name": name ?? "",
            "brand": brand ?? "",
            "category": category ?? "",
            "variant": variant ?? "",
            "quantity": quantity ?? "",
            "coupon": coupon ?? "",
            "position": position ?? "",
        ]
    }

    public var id: String?
    public var price: Double?
    public var name: String?
    public var brand: String?
    public var category: String?
    public var variant: String?
    public var quantity: String?
    public var coupon: String?
    public var position: String?

    override init() {
    }

    /// Initialize for testing
    ///
    public init(id: String, price: Double, name: String, brand: String,
         category: String,  variant: String,  quantity: String,  coupon: String,
         position: String) {
        self.id = id
        self.price = price
        self.name = name
        self.brand = brand
        self.category = category
        self.variant = variant
        self.quantity = quantity
        self.coupon = coupon
        self.position = position
    }

    /// Initialize this object using JSONObject
    ///
    /// - Parameter json: The JSONObject
    required convenience init?(json: VibesJSONDictionary) {
        self.init()

        guard let id = json["id"] as? String else { return nil }
        self.id = id
        name = json["name"] as? String
        price = json["price"] as? Double
        brand = json["brand"] as? String
        category = json["category"] as? String
        variant = json["variant"] as? String
        quantity = json["quantity"] as? String
        coupon = json["coupon"] as? String
        position = json["position"] as? String
        
    }

    /// Initialize this object using Attributes
    ///
    /// - Parameter attributes: - The dictionary with attributes
    public required convenience init?(attributes: [String: Any]) {
        self.init()
        guard let id = attributes["id"] as? String,
            !id.isEmpty else { return nil }

        self.id = id
        name = attributes["name"] as? String
        price = attributes["price"] as? Double
        brand = attributes["brand"] as? String
        category = attributes["category"] as? String
        variant = attributes["variant"] as? String
        quantity = attributes["quantity"] as? String
        coupon = attributes["coupon"] as? String
        position = attributes["position"] as? String
    }
}

/// Equals Comparison operator for Product
///
/// - Parameters:
///   - lhs: The left hand side Product
///   - rhs: The right hand side Product
/// - Returns: `True` if `lhs` is equal to `rhs`, else returns `False`
public func == (lhs: Product, rhs: Product) -> Bool {
    return lhs.id == rhs.id
}
