/// A protocol that defines an adapter for allowing the storage of  values in 
/// some sort of local storage mechanism (e.g. UserDefaults, Keychain, etc.).
///
/// Adopters of this protocol get the ability to get and set custom objects as 
/// well.
public protocol LocalStorageType {
  /// Retrieves the value for the given item.
  ///
  /// - parameters:
  ///   - item: a local value that identifies this item
  /// - returns: an instance of T, if it was found; nil otherwise
  func get<T>(_ item: LocalValue<T>) -> T?

  /// Stores a value for the item provided.
  ///
  /// - parameters:
  ///   - value: the value to store at the given key
  ///   - item: a local value to identify this item
  /// - returns: true if storing was successful; nil otherwise
  @discardableResult
  func set<T>(_ value: T?, for item: LocalValue<T>) -> Bool
}

extension LocalStorageType {
  /// Retrieves the object stored for the given item.
  ///
  /// - parameters:
  ///   - item: the local storage item to retreive
  /// - returns: the previously-stored object, or nil
  func get<T>(_ item: LocalObject<T>) -> T? {
    let localValue = LocalValue<[String: Any]>(item.key)
    guard let attributes = get(localValue) else { return nil }
    return T.init(attributes: attributes)
  }

  /// Stores an object for the item provided.
  ///
  /// - parameters:
  ///   - value: the object to store
  ///   - item: the local storage item to use for storage
  /// - returns: a boolean indicating whether storing the object was successful
  @discardableResult
  func set<T>(_ value: T?, for item: LocalObject<T>) -> Bool {
    let localValue = LocalValue<[String: Any]>(item.key)
    return set(value?.attributes, for: localValue)
  }
}
