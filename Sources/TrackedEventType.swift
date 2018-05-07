/// An enum to indicate the type of events that should be reported to Vibes.
public enum TrackedEventType: String {
  /// A launch event, tracked when the app is first opened
  case launch

  /// A clickthru event, tracked when the app is opened from a push
  /// notification
  case clickthru

  /// The set of all known events
  static let all: [TrackedEventType] = [.launch, .clickthru]
}
