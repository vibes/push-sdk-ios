extension Dictionary {
  /// Merges a dictionary into this one.
  ///
  /// - parameters:
  ///   - dictionary: the Dictionary to merge in
  func merged(with dictionary: [Key: Value]) -> [Key: Value] {
    var copy = self
    dictionary.forEach { copy.updateValue($1, forKey: $0) }
    return copy
  }
}
