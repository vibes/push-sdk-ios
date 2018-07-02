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

    /// The set of all known events
    static let all: [TrackedEventType] = [.launch, .clickthru]

    func name() -> String {
        switch self {
        case .launch: return "launch"
        case .clickthru: return "clickthru"
        case .undefined: return "undefined"
        }
    }

    public static func convert(rawValue: String) -> TrackedEventType {
        switch rawValue {
        case "launch": return .launch
        case "clickthru": return .clickthru
        default: return .undefined
        }
    }
}
