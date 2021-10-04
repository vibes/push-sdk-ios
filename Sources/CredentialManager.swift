/// Handles storing credentials, keeping track of the current Credential, etc.
class CredentialManager {
  /// An object for storing data in some kind of local storage.
  private let storage: LocalStorageType

  /// The currently-active Credential
  var currentCredential: VibesCredential? {
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
}
