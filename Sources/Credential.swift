/// A value object to represent the credentials needed to interact with the
/// Vibes API.
public struct Credential {
  /// A unique identifier for the device, provided by Vibes when registering.
  public let deviceId: String

  /// A unique, transient token for the device. The combination of `deviceId`
  /// and `authToken` is used to authenticate most calls in the `VibesAPI`.
  public let authToken: String
}

extension Credential: JSONDecodable {
  init?(json: JSONDictionary) {
    guard let device = json["device"] as? JSONDictionary,
      let deviceId = device["vibes_device_id"] as? String,
      let authToken = json["auth_token"] as? String else { return nil }

    self.deviceId = deviceId
    self.authToken = authToken
  }
}

extension Credential: Equatable {
  public static func == (lhs: Credential, rhs: Credential) -> Bool {
    return lhs.deviceId == rhs.deviceId && lhs.authToken == rhs.authToken
  }
}

extension Credential: LocalObjectType {
  public var attributes: [String : Any] {
    return ["id": deviceId, "token": authToken]
  }

  public init?(attributes: [String : Any]) {
    guard let id = attributes["id"] as? String,
      let token = attributes["token"] as? String else { return nil }

    self.deviceId = id
    self.authToken = token
  }
}
