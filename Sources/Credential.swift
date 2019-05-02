/// A value object to represent the credentials needed to interact with the
/// Vibes API.
public struct VibesCredential {
  /// A unique identifier for the device, provided by Vibes when registering.
  public let deviceId: String

  /// A unique, transient token for the device. The combination of `deviceId`
  /// and `authToken` is used to authenticate most calls in the `VibesAPI`.
  public let authToken: String
}

extension VibesCredential: JSONDecodable {
  init?(json: VibesJSONDictionary) {
    guard let device = json["device"] as? VibesJSONDictionary,
      let deviceId = device["vibes_device_id"] as? String,
      let authToken = json["auth_token"] as? String else { return nil }

    self.deviceId = deviceId
    self.authToken = authToken
  }
}

extension VibesCredential: Equatable {
  public static func == (lhs: VibesCredential, rhs: VibesCredential) -> Bool {
    return lhs.deviceId == rhs.deviceId && lhs.authToken == rhs.authToken
  }
}

extension VibesCredential: LocalObjectType {
  public var attributes: [String: Any] {
    return ["id": deviceId, "token": authToken]
  }

  public init?(attributes: [String: Any]) {
    guard let id = attributes["id"] as? String,
      let token = attributes["token"] as? String else { return nil }

    self.deviceId = id
    self.authToken = token
  }
}
