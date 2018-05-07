/// A custom error enum that indicates why requesting a resource has failed.
enum ResourceError: Error {
  /// An error indicating that a non-success HTTP status code (i.e. non-200)
  /// was returned.
  case invalidResponse(statusCode: Int, responseText: String)

  /// An error indicating that no data was returned in the HTTP response.
  case noData

  /// An error indicating that data was returned, but could not be parsed into
  /// the desired Type (using the `HTTPResource`'s `parse` property).
  case couldNotParse(data: Data)

  /// A catch-all error, for errors that fall outside the above specifically-
  /// delineated errors.
  case other(Error?)
}

/// A generic result object to created a tagged union of success or failure for
/// requesting an `HTTPResource`.
///
/// The result of successfully parsing an `HTTPResource` is encoded in the `T` 
/// type attached to the `success` case; a `ResourceError` is attached to the
/// `failure` case.
enum ResourceResult<T> {
  /// Used to indicate that an HTTP request was successful and the response was
  /// parsed from `Data` into the Type indicated by `T`.
  case success(T)

  /// Used to indicate that an HTTP request failed; the reason why is attached
  /// as an `HTTPResourceError`.
  case failure(ResourceError)
}
