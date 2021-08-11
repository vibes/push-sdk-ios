import Foundation

struct StubURLSessionDataTask: URLSessionDataTaskType {
  func resume() {}
}

struct StubURLSession: URLSessionType {
  let data: Data?
  let response: URLResponse?
  let error: Error?

  init(data: Data?, response: URLResponse?, error: Error?) {
    self.data = data
    self.response = response
    self.error = error
  }

  func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskType {
    completionHandler(self.data, self.response, self.error)
    return StubURLSessionDataTask()
  }
}
