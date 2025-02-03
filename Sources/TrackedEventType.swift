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
    
    // Inbox messages fetched event, tracked when inbox messages are fetched or refetched
    case inboxfetch
    
    // Push receive event, tracked when push message is received in device
    case pushReceive

    /// The set of all known events
    public static let all: [TrackedEventType] = [.launch, .clickthru, .inboxopen, .inboxfetch, .pushReceive]

    func name() -> String {
        switch self {
        case .launch: return "launch"
        case .clickthru: return "clickthru"
        case .inboxopen: return "inbox_open"
        case .inboxfetch: return "inbox_fetch"
        case .pushReceive: return "push_receive"
        case .undefined: return "undefined"
        }
    }

    public static func convert(rawValue: String) -> TrackedEventType {
        switch rawValue {
        case "launch": return .launch
        case "clickthru": return .clickthru
        case "inbox_open": return .inboxopen
        case "inbox_fetch": return .inboxfetch
        case "push_receive": return .pushReceive
        default: return .undefined
        }
    }
}
