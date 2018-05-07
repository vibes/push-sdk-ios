/// An object to take care of persisting incoming events when they are received
/// and removing them once they have been successfully sent to Vibes.
class PersistentEventStorage {
  /// A serial dispatch queue for changing local storage
  private let internalQueue: DispatchQueue

  /// The local storage mechanism we are using for storing events
  private let storage: LocalStorageType

  /// A property for the events currently stored locally.
  var storedEvents: [Event] {
    get {
      return storage.get(LocalStorageKeys.events)?.events ?? []
    }
    set(newEvents) {
      storage.set(EventCollection(events: newEvents), for: LocalStorageKeys.events)
    }
  }

  /// Initialize this object.
  ///
  /// - parameters:
  ///   - storage: a local storage mechanism for storing events
  init(storage: LocalStorageType) {
    self.storage = storage
    self.internalQueue = DispatchQueue(label: "Vibes")
  }

  /// A convenience typelias for the completion of sending events to be tracked
  /// over the API.
  typealias TrackCompletion = (VibesResult<Void>) -> Void

  /// A wrapper around sending events to Vibes; this is what handles
  /// persisting/removing events from local storage.
  ///
  /// - parameters:
  ///   - events: an Array of events to track.
  ///   - callback: a callback for when events have been tracked via the API.
  ///     It receives the events to store (which may be a superset of the
  ///     events passed in) and a completion to call with the result of sending
  ///     the events over the API.
  func tracking(events incomingEvents: [Event], callback: ([Event], @escaping TrackCompletion) -> Void) {
    guard let event = incomingEvents.first else {
      return
    }

    persistEvents(incomingEvents)

    let outgoingEvents = storedEvents.filter { $0.type == event.type }
    callback(outgoingEvents, { result in
      switch result {
      case .success:
        self.removeEvents(outgoingEvents)
      default:
        break
      }
    })
  }

  /// Persist events in local storage.
  ///
  /// - parameters:
  ///   - events: an Array of events to persist.
  private func persistEvents(_ events: [Event]) {
    internalQueue.sync {
      storedEvents.append(contentsOf: events)
    }
  }

  /// Removes events from local storage.
  ///
  /// - parameters:
  ///   - events: an Array of events to remove.
  private func removeEvents(_ events: [Event]) {
    internalQueue.sync {
      storedEvents = storedEvents.filter { !events.contains($0) }
    }
  }
}
