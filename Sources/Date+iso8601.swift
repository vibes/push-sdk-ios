import Foundation

extension Formatter {
  /// A date formatter for generating ISO8601-compatible timestamp strings.
  static let iso8601: DateFormatter = {
    let formatter = DateFormatter()

    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"

    return formatter
  }()
}

extension Date {
  /// An ISO8601-compatible timestamp string for this Date object.
  var iso8601: String {
    return Formatter.iso8601.string(from: self)
  }
}
