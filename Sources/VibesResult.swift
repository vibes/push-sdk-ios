/// A custom error enum that indicates why a Vibes operation has failed.
public enum VibesError: Error {
  /// An error indicating that the request could not be performed because
  /// the device credentials are not available. This may indicate that the call
  /// to `registerDevice` never completed successfully.
  case noCredentials

  /// An error indicating that the request could not be performed because
  /// the device's push token is not available. This may indicate that the call
  /// to `setPushToken` was never made.
  case noPushToken

  /// An error indicating that the request could not be performed because
  /// authorization has failed.
  case authFailed(String)

  /// An error indicating that we have attempted to track an array containing
  /// no events.
  case noEvents

  /// An error indicating that we have attempted to track an array containing
  /// events with multiple types.
  case tooManyEventTypes

  /// A catch-all error, for issues that don't fall into other cases.
  case other(String)

  /// A friendly human-readable description of the error that occurred.
  public var description: String {
    switch self {
    case .noCredentials:
      return "There are no available credentials"
    case .noPushToken:
      return "There is no push token available"
    case .noEvents:
      return "There are no events to track"
    case .tooManyEventTypes:
      return "Too many types of events - can only handle one type at a time"
    case .authFailed(let details):
      return "Authentication failed: \(details)"
    case .other(let details):
      return "Error: \(details)"
    }
  }
}

/// A generic result object to created a tagged union of success or failure for
/// completion a Vibes operation.
public enum VibesResult<T> {
  /// Used to indicate that a Vibes operation was successful
  case success(T)

  /// Used to indicate that the Vibes operation failed; the reason why is
  /// attached as aa `VibesError`
  case failure(VibesError)

  /// Create a VibesResult from a ResourceResult. This keeps our public API
  /// separate from our internal ones.
  ///
  /// - parameters:
  ///   - result: a ResourceResult to convert into a VibesResult
  init(_ result: ResourceResult<T>) {
    switch result {
    case .success(let value):
      self = VibesResult<T>.success(value)
    case .failure(let error):
      switch error {
      case .invalidResponse(let statusCode, let responseText) where statusCode == 401:
        self = VibesResult<T>.failure(.authFailed(responseText))
      case .invalidResponse(let statusCode, let responseText):
        let description = "[HTTP \(statusCode)]: \(responseText)"
        self = VibesResult<T>.failure(.other(description))
      default:
        self = VibesResult<T>.failure(.other("\(error)"))
      }
    }
  }
}
