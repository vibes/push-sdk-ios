//
//  Date+logPrefix.swift
//  VibesPush
//
//  Created by Moin' Victor on 25/08/2020.
//  Copyright © 2020 Vibes. All rights reserved.
//

import Foundation

// MARK: - Date + log prefix

extension Date {
    public static var logPrefix: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        let nowString = dateFormatter.string(from: Date())
        return "[\(nowString)]"
    }
}
