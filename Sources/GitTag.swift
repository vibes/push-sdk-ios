//
//  GitTag.swift
//  VibesPush
//
//  Created by Moin' Victor on 15/09/2020.
//  Copyright © 2020 Vibes. All rights reserved.
//

import Foundation

/// A small data object to hold a Git Tag
public struct GitTag {
    let name: String
}

extension GitTag: JSONEncodable, JSONDecodable {
    init?(json: VibesJSONDictionary) {
        guard let name = json["name"] as? String else { return nil }
        self.name = name
    }

    func encodeJSON() -> VibesJSONDictionary {
        return [
            "name": name as AnyObject,
        ]
    }
}
