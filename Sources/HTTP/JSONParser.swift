import Foundation

/// A Type for a JSON dictionary (object)
public typealias VibesJSONDictionary = [String: AnyObject]

/// A Type for a JSON array
typealias VibesJSONArray = [VibesJSONDictionary]

/// A protocol that can be adopted to say that a Type can be encoded into JSON.
protocol JSONEncodable {
  /// Encodes this Type into a JSONDictionary.
  func encodeJSON() -> VibesJSONDictionary
}

/// A protocol that can be adopted to say that a Type can be decoded from JSON.
protocol JSONDecodable {
  /// A convenience initializer for decoding a JSONDictionary into this Type.
  ///
  /// - parameters:
  ///   - json: the JSONDictionary to encode into data
  init?(json: VibesJSONDictionary)
}

/// Allows the ability to decode/encode `Data` to/from a `JSONDictionary`.
struct JSONParser {
  /// Decodes data into a JSONDictionary.
  ///
  /// - parameters:
  ///   - data: the data to decode
  func decode(data: Data) -> VibesJSONDictionary? {
    // Treat an existing but blank data as an empty JSON object
    guard data.count > 0 else { return [:] }

    // swiftlint:disable:next force_cast
    return try? JSONSerialization.jsonObject(with: data) as! VibesJSONDictionary
  }

  /// Decodes data into a JSONArray.
  ///
  /// - parameters:
  ///   - data: the data to decode
  func decodeJSONArray(data: Data) -> VibesJSONArray? {
    // Treat an existing but blank data as an empty JSON object
    guard data.count > 0 else { return [] }

    guard let arrayJson = ((try? JSONSerialization.jsonObject(with: data) as? VibesJSONArray) as VibesJSONArray??)
      else {
        return nil
      }

    return arrayJson
  }

  /// Encodes a JSONEncodable to data.
  ///
  /// - parameters:
  ///   - object: a JSONEncodable object to encode into data
  func encode(_ object: JSONEncodable) -> Data? {
    let dict = object.encodeJSON()
    return encode(dict)
  }

  /// Encodes an array of JSONEncodable objects to data.
  ///
  /// - parameters:
  ///   - objects: an array of JSONEncodable object to encode into data
  func encode(_ objects: [JSONEncodable]) -> Data? {
    let array = objects.map { $0.encodeJSON() }
    return encode(array)
  }

  /// Encodes a JSONDictionary to data.
  ///
  /// - parameters:
  ///   - dict: the JSONDictionary to encode into data
  func encode(_ dict: VibesJSONDictionary) -> Data? {
    guard dict.count > 0 else { return nil }
    guard JSONSerialization.isValidJSONObject(dict) else { return nil }
    return try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
  }

  /// Encodes a JSONArray to data.
  ///
  /// - parameters:
  ///   - array: the JSONArray to encode into data
  func encode(_ array: VibesJSONArray) -> Data? {
    guard JSONSerialization.isValidJSONObject(array) else { return nil }
    return try? JSONSerialization.data(withJSONObject: array, options: .prettyPrinted)
  }
}
