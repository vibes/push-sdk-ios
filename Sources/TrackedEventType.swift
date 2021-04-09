/// An enum to indicate the type of events that should be reported to Vibes.
import Foundation

@objc public enum TrackedEventType: Int {
    /// Undefined case, since we parse a string in the convert method
    case undefined

    /// A launch event, tracked when the app is first opened
    case launch

    /// A clickthru event, tracked when the app is opened from a push
    /// notification
    case clickthru

    // A inbox open event, tracked when inbox message is clicked
    case inboxopen

    /// The set of all known events
    public static let all: [TrackedEventType] = [.launch, .clickthru, .inboxopen]

    func name() -> String {
        switch self {
        case .launch: return "launch"
        case .clickthru: return "clickthru"
        case .inboxopen: return "inbox_open"
        case .undefined: return "undefined"
        }
    }

    public static func convert(rawValue: String) -> TrackedEventType {
        switch rawValue {
        case "launch": return .launch
        case "clickthru": return .clickthru
        case "inbox_open": return .inboxopen
        default: return .undefined
        }
    }
}
