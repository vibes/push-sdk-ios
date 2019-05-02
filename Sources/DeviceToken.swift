/// A small data object to hold a push token received from Apple. This provides
/// a convenient place to add our JSON encoding code.
struct DeviceToken {
  let token: String
}

extension DeviceToken: JSONEncodable {
  func encodeJSON() -> VibesJSONDictionary {
    return [
      "device": [
        "push_token": token,
      ] as AnyObject,
    ]
  }
}
