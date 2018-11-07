/// A protocol for anything that can be stored as an object.
public protocol LocalObjectType {
  /// Attributes that should be used to store this object in local storage.
  var attributes: [String: Any] { get }

  /// Creates an object from a set of previously-stored attributes.
  ///
  /// - parameters:
  ///   - attributes: a dictionary of attributes to use to create this object
  init?(attributes: [String: Any])
}

/// A simple struct for identifying an object that is held in local storage.
public struct LocalObject<T: LocalObjectType> {
  /// The identifier to use to store this object.
  let key: String

  /// Initialize this object
  ///
  /// - paremeters:
  ///   - key: the identifier to use to store this object
  init(_ key: String) {
    self.key = key
  }
}
