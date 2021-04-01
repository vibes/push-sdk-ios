import Foundation
/// A protocol to allow a network client to add behavior around requesting an
/// HTTP resource.
///
/// This protocol may house more methods in the future, to allow for further
/// customization of request-handling in a network client (e.g. for before/after
/// callbacks to support an observer pattern).
protocol HTTPBehavior {
  /// Allows for the modification of a request object prior to it being sent.
  ///
  /// - parameters:
  ///   - request: the request you would like to modify
  func modifyRequest(request: inout URLRequest)
}

// We extend HTTPBehavior with a default no-op for its protocol methods.
extension HTTPBehavior {
  func modifyRequest(request: inout URLRequest) {}
}
