//
//  FoundationExtensions.swift
//  VibesPush
//
//  Created by Moin' Victor on 10/08/2021.
//  Copyright © 2021 Vibes. All rights reserved.
//

import Foundation

extension String {
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
}
