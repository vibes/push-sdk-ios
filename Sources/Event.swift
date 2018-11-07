import Foundation

/// A data object to represent an Event to send to Vibes.
struct Event {
  /// The type of the event
  fileprivate let eventType: TrackedEventType

  /// Event unique id (string representation)
  let uuid: String

  /// The time the Event occurred
  let timestamp: Date

  /// A set of arbitrary key/values to send along with the event
  let properties: [AnyHashable: Any]

  /// A convenience property for retrieving the type of the event as a String.
  var type: String {
    return eventType.name()
  }

  /// Initialize this object.
  ///
  /// - parameters:
  ///   - eventType: the type of the event
  ///   - properties: a set of arbitrary key/values to send along with the event
  ///   - timestamp: the time the Event occurred
  init(eventType: TrackedEventType, properties: [AnyHashable: Any], timestamp: Date = Date()) {
    self.uuid = UUID().uuidString
    self.eventType = eventType
    self.properties = properties
    self.timestamp = timestamp
  }
}

extension Event: Equatable {
  static func == (lhs: Event, rhs: Event) -> Bool {
    return lhs.uuid == rhs.uuid &&
        lhs.type == rhs.type &&
        lhs.timestamp == rhs.timestamp
  }
}

extension Event: JSONEncodable {
  func encodeJSON() -> VibesJSONDictionary {
    return [
      "uuid": uuid,
      "type": type,
      "timestamp": timestamp.iso8601,
      "attributes": properties,
    ] as VibesJSONDictionary
  }
}

extension Event: LocalObjectType {
  var attributes: [String: Any] {
    return [
      "uuid": uuid,
      "type": type,
      "timestamp": timestamp,
      "properties": properties,
    ]
  }

  init?(attributes: [String: Any]) {
    guard let uuid = attributes["uuid"] as? String,
        let timestamp = attributes["timestamp"] as? Date,
        let properties = attributes["properties"] as? [AnyHashable: Any],
        let type = attributes["type"] as? String else {
            return nil
    }

    self.uuid = uuid
    self.properties = properties
    self.timestamp = timestamp
    self.eventType = TrackedEventType.convert(rawValue: type)
  }
}
