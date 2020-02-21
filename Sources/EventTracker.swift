/// A protocol for Types that wish to track events.
protocol EventTracker: class {
  /// Tracks events.
  ///
  /// - parameters:
  ///   - events: the Events to track, e.g. [.launch]
  ///   - completion: a handler for receiving the result of tracking the events
  ///     (it returns an Array of the events that have been tracked)
  func track(events incomingEvents: [Event], completion: VibesCompletion<[Event]>?)
}

extension EventTracker {
  /// A convenience method for tracking a single event.
  ///
  /// - parameters:
  ///   - event: the Event to track, e.g. .launch
  ///   - completion: a handler for receiving the result of tracking the events
  ///     (it returns an Array of the events that have been tracked)
  func track(event incomingEvent: Event, completion: VibesCompletion<[Event]>?) {
    track(events: [incomingEvent], completion: completion)
  }

  /// A convenience method for tracking events without caring about completion.
  ///
  /// - parameters:
  ///   - events: the Events to track, e.g. [.launch]
  func track(events incomingEvents: [Event]) {
    track(events: incomingEvents, completion: nil)
  }

  /// A convenience method for tracking a single event without caring about
  /// completion.
  ///
  /// - parameters:
  ///   - event: the Event to track, e.g. .launch
  func track(event incomingEvent: Event) {
    track(events: [incomingEvent], completion: nil)
  }
}
