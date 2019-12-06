import Foundation
import Quick
import Nimble
@testable import VibesPush

class PersonSpec: QuickSpec {
  override func spec() {
    describe(".decodeJSON") {
      context("with usable JSON dictionary") {
        it("returns a Person") {
          let dictionary: JSONDictionary = [
            "person_key": "personKey" as AnyObject,
            "external_person_id": "external_person_id" as AnyObject,
            "mobile_phone": [
              "mdn": "mdn",
              ] as AnyObject,
          ]
          let actual = Person(json: dictionary)
          let expected = Person(externalPersonId: "external_person_id", mdn: "mdn", personKey: "personKey")
          expect(actual?.personKey == expected.personKey).to(equal(true))
          expect(actual?.externalPersonId == expected.externalPersonId).to(equal(true))
          expect(actual?.mdn == expected.mdn).to(equal(true))
        }

        context("with unusable JSON dictionary") {
          it("returns nil") {
            let dictionary: JSONDictionary = [:]
            expect(Person(json: dictionary)).to(beNil())
          }
        }
      }
    }
  }
}
