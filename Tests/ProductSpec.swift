//
//  ProductSpec.swift
//  VibesPush
//
//  Created by Moin' Victor on 15/08/2022.
//  Copyright © 2022 Vibes. All rights reserved.
//

import Foundation
import Nimble
import Quick
@testable import VibesPush

class ProductSpec: QuickSpec {
    override func spec() {
        describe(".decodeJSON") {
            context("with usable JSON dictionary") {
                it("returns a Person") {
                    let dictionary: JSONDictionary = [
                        "id": "product-id" as AnyObject,
                        "price": "20.0" as AnyObject,
                        "name": "test" as AnyObject,
                        "brand": "brand" as AnyObject,
                        "category": "category-1" as AnyObject,
                        "variant": "variant-1" as AnyObject,
                        "quantity": "" as AnyObject,
                        "coupon": "" as AnyObject,
                        "position": ""as AnyObject,
                    ]
                    let actual = Product(json: dictionary)
                    let expected = Product(id: "product-id", price: 20.0, name: "test", brand: "brand", category: "category-1", variant: "variant-1", quantity: "", coupon: "", position: "")
                    expect(actual?.id == expected.id).to(equal(true))
                    expect(actual?.category == expected.category).to(equal(true))
                }

                context("with unusable JSON dictionary") {
                    it("returns nil") {
                        let dictionary: JSONDictionary = [:]
                        expect(Product(json: dictionary)).to(beNil())
                    }
                }
            }
        }
    }
}
