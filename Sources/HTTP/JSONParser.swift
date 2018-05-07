/// A Type for a JSON dictionary (object)
typealias JSONDictionary = [String: AnyObject]

/// A Type for a JSON array
typealias JSONArray = [JSONDictionary]

/// A protocol that can be adopted to say that a Type can be encoded into JSON.
protocol JSONEncodable {
  /// Encodes this Type into a JSONDictionary.
  func encodeJSON() -> JSONDictionary
}

/// A protocol that can be adopted to say that a Type can be decoded from JSON.
protocol JSONDecodable {
  /// A convenience initializer for decoding a JSONDictionary into this Type.
  ///
  /// - parameters:
  ///   - dict: the JSONDictionary to encode into data
  init?(json: JSONDictionary)
}

/// Allows the ability to decode/encode `Data` to/from a `JSONDictionary`.
struct JSONParser {
  /// Decodes data into a JSONDictionary.
  ///
  /// - parameters:
  ///   - data: the data to decode
  func decode(data: Data) -> JSONDictionary? {
    // Treat an existing but blank data as an empty JSON object
    guard data.count > 0 else { return [:] }

    // swiftlint:disable:next force_cast
    return try? JSONSerialization.jsonObject(with: data) as! JSONDictionary
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
  func encode(_ dict: JSONDictionary) -> Data? {
    guard dict.count > 0 else { return nil }
    guard JSONSerialization.isValidJSONObject(dict) else { return nil }
    return try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
  }

  /// Encodes a JSONArray to data.
  ///
  /// - parameters:
  ///   - array: the JSONArray to encode into data
  func encode(_ array: JSONArray) -> Data? {
    guard JSONSerialization.isValidJSONObject(array) else { return nil }
    return try? JSONSerialization.data(withJSONObject: array, options: .prettyPrinted)
  }
}
