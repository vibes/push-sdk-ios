import Foundation
/// A behavior for adding the necessary authentication token for requests to the
/// Vibes API.
struct AuthTokenBehavior: HTTPBehavior {
  /// An authentication token to send in an request header.
  let token: String?

  /// Modifies the request by adding an `Authorization` header.
  ///
  /// - parameters:
  ///   - request: the request to modify
  func modifyRequest(request: inout URLRequest) {
    if let token = self.token {
        request.setValue("MobileAppToken \(token)", forHTTPHeaderField: "Authorization")
    }
  }
}
