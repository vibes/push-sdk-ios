/// Handles storing credentials, keeping track of the current Credential, etc.
class CredentialManager {
  /// An object for storing data in some kind of local storage.
  private let storage: LocalStorageType

  /// The currently-active Credential
  var currentCredential: Credential? {
    get {
      return storage.get(LocalStorageKeys.currentCredential)
    }

    set {
      storage.set(newValue, for: LocalStorageKeys.currentCredential)
    }
  }

  /// Initialize this object.
  ///
  /// - parameters:
  ///   - storage: an object that allows storing data locally
  init(storage: LocalStorageType) {
    self.storage = storage
  }

  /// Add a credential to storage.
  ///
  /// - parameters:
  ///   - credential: a Credential to store
  func addCredential(_ credential: Credential) {
    var allCredentials = storage.get(LocalStorageKeys.allCredentials) ?? [:]
    allCredentials[credential.deviceId] = credential.authToken

    storage.set(allCredentials, for: LocalStorageKeys.allCredentials)
  }

  /// Removes a credential from storage.
  ///
  /// - parameters:
  ///   - credential: a Credential to remove
  func removeCredential(_ credential: Credential) {
    var allCredentials = storage.get(LocalStorageKeys.allCredentials) ?? [:]
    allCredentials.removeValue(forKey: credential.deviceId)

    storage.set(allCredentials, for: LocalStorageKeys.allCredentials)
  }
}
