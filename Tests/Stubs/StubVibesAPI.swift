class StubVibesAPI: VibesAPIType {
    var results: [Any]
    var retry = 0

    init() {
        results = []
    }

    init(result: Any) {
        results = [result]
    }

    init(results: [Any]) {
        self.results = results
    }
  
  func detail(result: Any) {
      results.append(result)
  }

    func add(result: Any) {
        results.append(result)
    }

    func clearResponse() {
        results.removeAll()
    }

    func request<A>(resource: HTTPResource<A>, completion: APICompletion<A>?) {
        request(authToken: "", resource: resource, completion: completion)
    }

    func request<A>(authToken: String?, resource: HTTPResource<A>, completion: APICompletion<A>?) {
        var res: Any?
        if !results.isEmpty {
            res = results[0]
        }
        guard let result = results.remove(at: 0) as? ResourceResult<A> else {
            fatalError("Could not convert result:\(String(describing: res)) to type: \(A.self)")
        }
        retry += 1
        completion?(result)
    }
}
