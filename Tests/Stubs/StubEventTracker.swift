class StubEventTracker: EventTracker {
  var events: [Event] = []
  var result: VibesResult<[Event]>?

  init() {
  }

  func setResult(_ result: VibesResult<[Event]>) {
    self.result = result
  }

  func track(events incomingEvents: [Event], completion: VibesCompletion<[Event]>?) {
    self.events.append(contentsOf: incomingEvents)

    if let result = result {
      completion?(result)
    }
  }
}
