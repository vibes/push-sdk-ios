class StubVibesAPI: VibesAPIType {
  var results: [Any]
  var retry = 0

  init() {
    self.results = []
  }

  init(result: Any) {
    self.results = [result]
  }

  init(results: [Any]) {
    self.results = results
  }

  func add(result: Any) {
    self.results.append(result)
  }

  func request<A>(resource: HTTPResource<A>, completion: APICompletion<A>?) {
    request(authToken: "", resource: resource, completion: completion)
  }

  func request<A>(authToken: String?, resource: HTTPResource<A>, completion: APICompletion<A>?) {
    guard let result = self.results.remove(at: 0) as? ResourceResult<A> else {
      fatalError("Could not convert result to type: \(A.self)")
    }
    retry += 1
    completion?(result)
  }
}
