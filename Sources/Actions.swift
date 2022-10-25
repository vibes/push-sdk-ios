//
//  ProductActions.swift
//  VibesPush
//
//  Created by Moin' Victor on 11/08/2022.
//  Copyright © 2022 Vibes. All rights reserved.
//

import Foundation

public enum ProductAction: String {
    case click
    case detail
    case add
    case remove
    case checkout
    case checkoutOption = "checkout_option"
    case promoClick = "promo_click"
}

public enum PurchaseAction: String {
    case purchase
    case refund
}
