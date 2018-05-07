class StubHTTPResourceClient: HTTPResourceClientType {
  let result: Any
  var behaviorUsed: HTTPBehavior?

  init(result: Any) {
    self.result = result
  }

  func request<A>(resource: HTTPResource<A>, behavior: HTTPBehavior?, completion: HTTPCompletion<A>?) {
    guard let result = self.result as? ResourceResult<A> else {
      fatalError("Could not convert \(self.result) to type: \(A.self)")
    }
    self.behaviorUsed = behavior

    completion?(result)
  }
}
