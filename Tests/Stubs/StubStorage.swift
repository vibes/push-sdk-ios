class StubStorage: LocalStorageType {
  private var memoryStore: [String: Any] = [:]

  init(_ initialContents: [String: Any]? = nil) {
    self.memoryStore = initialContents ?? [:]
  }

  func get<T>(_ item: LocalValue<T>) -> T? {
    return memoryStore[item.key] as? T
  }

  func set<T>(_ value: T?, for item: LocalValue<T>) -> Bool {
    memoryStore[item.key] = value
    return true
  }
}
