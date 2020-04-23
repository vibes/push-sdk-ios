/// A simple object to encapsulate the notion of an array of Events.
final class EventCollection {
  /// The events in the collection
  var events: [Event] = []

  /// Initialize this object.
  ///
  /// - parameters:
  ///   - events: the initial events to contain
  init(events: [Event] = []) {
    self.events = events
  }
}

// Ideally, instead of `EventCollection` we would use conditional conformance
// to do:
//
//   extension Array: LocalObjectType where Element: LocalObjectType {
//     ...
//   }
//
// but this sort of functionality isn't available yet in Swift.
// See: https://github.com/apple/swift-evolution/blob/master/proposals/0143-conditional-conformances.md

extension EventCollection: LocalObjectType {
  var attributes: [String: Any] {
    return ["object": events.map { $0.attributes }]
  }

  convenience init?(attributes: [String: Any]) {
    self.init()

    guard let eventAttributes = attributes["object"] as? [[String: Any]] else { return nil }
    self.events = eventAttributes.compactMap { Event(attributes: $0) }
  }
}
