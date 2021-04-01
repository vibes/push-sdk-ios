//
//  GitTagSpec.swift
//  VibesPush
//
//  Created by Moin' Victor on 15/09/2020.
//  Copyright © 2020 Vibes. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import VibesPush

class GitTagSpec: QuickSpec {
  override func spec() {
    describe(".decodeJSON") {
      context("with usable JSON dictionary") {
        it("returns a Person") {
          let dictionary: JSONDictionary = [
            "name": "1.0.0" as AnyObject,
          ]
          let actual = GitTag(json: dictionary)
          let expected = GitTag(name: "1.0.0")
          expect(actual?.name == expected.name).to(equal(true))
        }

        context("with unusable JSON dictionary") {
          it("returns nil") {
            let dictionary: JSONDictionary = [:]
            expect(GitTag(json: dictionary)).to(beNil())
          }
        }
      }
    }
  }
}
