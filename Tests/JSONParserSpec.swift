import Foundation
import Quick
import Nimble
@testable import VibesPush

/// A Type for a JSON dictionary (object)
typealias JSONDictionary = [String: AnyObject]

/// A Type for a JSON array
typealias JSONArray = [JSONDictionary]

class JSONParserSpec: QuickSpec {
  override func spec() {
    describe("#decode") {
      it("returns a dictionary with valid JSON") {
        // swiftlint:disable:next line_length
        let jsonString = "{ \"device\": { \"vibes_device_id\": \"MOCK_4e77c2de-ba8a-4ab4-9102-f54fd5b4a671\" }, \"auth_token\": \"mock_auth_token_12469494\" }"

        let data = jsonString.data(using: .utf8)!

        let jsonParser = JSONParser()
        let jsonDictionary = jsonParser.decode(data: data)!
        expect(jsonDictionary["auth_token"] as? String).to(equal("mock_auth_token_12469494"))

        let device = jsonDictionary["device"] as! JSONDictionary
        expect(device["vibes_device_id"] as? String).to(equal("MOCK_4e77c2de-ba8a-4ab4-9102-f54fd5b4a671"))
      }

      it("returns nil with invalid JSON") {
        // swiftlint:disable:next line_length
        let jsonString = "{ \"device\": { \"vibes_device_id\": \"MOCK_4e77c2de-ba8a-4ab4-9102-f54fd5b4a671\" }, \"auth_token\": \"mock_auth_token_12469494\"" // missing closing }

        let data = jsonString.data(using: .utf8)!

        let jsonParser = JSONParser()
        expect(jsonParser.decode(data: data)).to(beNil())
      }
    }

    describe("#encode") {
      it("returns data when encoding succeeds") {
        let dictionary: JSONDictionary = ["auth_token": "mock_auth_token_12469494" as AnyObject]

        let jsonParser = JSONParser()
        let data = jsonParser.encode(dictionary)
        expect(data).toNot(beNil())
      }

      it("returns nil when encoding fails") {
        let dictionary: JSONDictionary = ["auth_token": Data() as AnyObject]

        let jsonParser = JSONParser()
        let data = jsonParser.encode(dictionary)
        expect(data).to(beNil())
      }

      it("allows encoding an array") {
        let array: JSONArray = [["auth_token": "mock_auth_token_12469494" as AnyObject]]

        let jsonParser = JSONParser()
        let data = jsonParser.encode(array)
        expect(data).toNot(beNil())

        if let data = data, let string = String(data: data, encoding: .utf8) {
          expect(string).to(beginWith("["))
        } else {
          fail("Could not create JSON string from data")
        }
      }
    }
  }
}
