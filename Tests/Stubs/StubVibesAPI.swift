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

  func clearResponse() {
    self.results.removeAll()
  }
  
  func request<A>(resource: HTTPResource<A>, completion: APICompletion<A>?) {
    request(authToken: "", resource: resource, completion: completion)
  }

  func request<A>(authToken: String?, resource: HTTPResource<A>, completion: APICompletion<A>?) {
    var res: Any?
    if (!results.isEmpty) {
      res = self.results[0]
    }
    guard let result = self.results.remove(at: 0) as? ResourceResult<A> else {
      fatalError("Could not convert result:\(String(describing: res)) to type: \(A.self)")
    }
    retry += 1
    completion?(result)
  }
}
