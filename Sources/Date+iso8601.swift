import Foundation

public extension Formatter {
    /// A date formatter for generating ISO8601-compatible timestamp strings.
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()

        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"

        return formatter
    }()
}

public extension Date {
    /// An ISO8601-compatible timestamp string for this Date object.
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }

    var iso8601WithUpdatingTimezone: String {
        let formatter = Formatter.iso8601
        formatter.timeZone = TimeZone.autoupdatingCurrent
        return formatter.string(from: self)
    }
}

public extension String {
    var iso8601: Date? {
        return Formatter.iso8601.date(from: self)
    }
}
