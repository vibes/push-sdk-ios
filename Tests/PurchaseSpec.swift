//
//  PurchaseSpec.swift
//  VibesPush
//
//  Created by Clement  Wekesa on 19/08/2022.
//  Copyright © 2022 Vibes. All rights reserved.
//

import Foundation
import Nimble
import Quick
@testable import VibesPush

class PurchaseSpec: QuickSpec {
    override func spec() {
        describe(".decodeJSON") {
            context("with usable JSON dictionary") {
                it("returns a Purchase") {
                    let dictionary: JSONDictionary = [
                        "id": "purchase-id" as AnyObject,
                        "affiliation": "affiliation" as AnyObject,
                        "revenue": "2.0" as AnyObject,
                        "tax": "3.0" as AnyObject,
                        "shipping": "1.0" as AnyObject,
                        "coupon": "1.0" as AnyObject,
                        "list": "" as AnyObject,
                        "step": "" as AnyObject,
                        "option": "" as AnyObject,
                        "products": [] as AnyObject,
                    ]
                    let actual = Purchase(json: dictionary)
                    let expected = Purchase(id: "purchase-id", affiliation: "affiliation", revenue: 2.0, tax: 3.0, shipping: 1.0, coupon: 1.0, list: "", step: "", option: "", products: [])
                    expect(actual?.id == expected.id).to(equal(true))
                    expect(actual?.affiliation == expected.affiliation).to(equal(true))
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
