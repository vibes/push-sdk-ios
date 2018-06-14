import Foundation
/// A storage adapter that uses the Keychain as a local storage mechanism.
struct KeychainStorage {
  /// The "service" name to use
  fileprivate let service: String

  /// Initialize this object.
  ///
  /// - parameters:
  ///   - service: the "service" name to use
  init(service: String) {
    self.service = service
  }
}

extension KeychainStorage: LocalStorageType {
  /// Retrieves the value in the keychain for the provided item.
  ///
  /// - parameters:
  ///   - item: the local storage item to retreive
  /// - returns: the previously-stored value, or nil
  func get<T>(_ item: LocalValue<T>) -> T? {
    let attributes = [
      String(kSecClass): kSecClassGenericPassword,
      String(kSecAttrService): service,
      String(kSecMatchLimit): kSecMatchLimitOne,
      String(kSecAttrAccount): item.key,
      String(kSecReturnData): true,
      ] as [String : Any]

    var result: AnyObject?
    let status = SecItemCopyMatching(attributes as CFDictionary, &result)

    guard status == noErr else { return nil }
    guard let data = result as? Data else { return nil }

    return T.unarchive(data: data)
  }

  /// Stores a value in the keychain with the key provided.
  ///
  /// - parameters:
  ///   - value: the value to store
  ///   - item: the local storage item to use for storage
  /// - returns: a boolean indicating whether storing the value was successful
  func set<T>(_ value: T?, for item: LocalValue<T>) -> Bool {
    var attributes = [
      String(kSecClass): kSecClassGenericPassword,
      String(kSecAttrService): service,
      String(kSecAttrAccount): item.key,
    ] as [String : Any]

    if let value = value {
      attributes[String(kSecValueData)] = T.archive(value: value)
      SecItemDelete(attributes as CFDictionary)

      let status = SecItemAdd(attributes as CFDictionary, nil)
      return status == noErr
    } else {
      let status = SecItemDelete(attributes as CFDictionary)
      return status == noErr
    }
  }
}
