/// A protocol for anything that can be stored as a value. This protocol 
/// inherits default implementations, so new values can be added just be 
/// adopting the bare protocol, e.g. `extension Date: LocalValueType {}`
import Foundation

public protocol VibesLocalValueType {
  /// Archives this value to Data that can be stored.
  ///
  /// - paremeters:
  ///   - value: an instance of self, e.g. String
  /// - returns: the encoded value, as data
  static func archive(value: Self) -> Data

  /// Unarchives this value from Data
  ///
  /// - paremeters:
  ///   - data: the data to convert into a value
  /// - returns: the value that was decoded
  static func unarchive(data: Data) -> Self?
}

extension VibesLocalValueType {
  public static func archive(value: Self) -> Data {
    return NSKeyedArchiver.archivedData(withRootObject: value)
  }

  public static func unarchive(data: Data) -> Self? {
    let object = NSKeyedUnarchiver.unarchiveObject(with: data)
    return object as? Self
  }
}

extension String: VibesLocalValueType {
    public static func archive(value: String) -> Data {
        return NSKeyedArchiver.archivedData(withRootObject: value)
    }
    
    public static func unarchive(data: Data) -> String? {
        let object = NSKeyedUnarchiver.unarchiveObject(with: data)
        return object as? String
    }
}

extension Dictionary: VibesLocalValueType {
    public static func archive(value: Dictionary) -> Data {
        return NSKeyedArchiver.archivedData(withRootObject: value)
    }
    
    public static func unarchive(data: Data) -> Dictionary? {
        let object = NSKeyedUnarchiver.unarchiveObject(with: data)
        return object as? Dictionary
    }
}

/// A simple struct for identifying a value that is held in local storage.
public struct LocalValue<T: VibesLocalValueType> {
  /// The identifier to use to store this value.
  let key: String

  /// Initialize this object.
  ///
  /// - paremeters:
  ///   - key: the identifier to use to store this value.
  init(_ key: String) {
    self.key = key
  }
}
