import Foundation
/// A closure used as a completion handler for HTTP requests.
typealias HTTPCompletion<T> = (ResourceResult<T>) -> Void

/// A protocol that indicates the required interface for being considered an
/// `HTTPResourceClient`
protocol HTTPResourceClientType {
    func request<A>(resource: HTTPResource<A>,
                    behavior: HTTPBehavior?,
                    completion: HTTPCompletion<A>?)
    func request<A>(resource: HTTPResource<A>,
                    completion: HTTPCompletion<A>?)
}

/// A closure used as a completion handler for URLSessionDataTasks.
typealias DataTaskResult = (Data?, URLResponse?, Error?) -> Void

/// A protocol that indicates the required interface for being considered a
/// `URLSession` for use with an `HTTPResourceClient`.
protocol URLSessionType {
    func dataTask(with request: URLRequest,
                  completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskType
}

extension URLSession: URLSessionType {
    func dataTask(with request: URLRequest,
                  completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskType {
        let task = dataTask(with: request,
                            completionHandler: completionHandler) as URLSessionDataTask
        return task as URLSessionDataTaskType
    }
}

/// A protocol that indicates the required interface for being considered a
/// `URLSessionDataTask` for use with an `HTTPResourceClient`.
protocol URLSessionDataTaskType {
    func resume()
}

extension URLSessionDataTask: URLSessionDataTaskType {}

extension HTTPResourceClientType {
    /// Make an HTTP request for an `HTTPResource`.
    ///
    /// - parameters:
    ///   - resource: The resource to request
    ///   - completion: A handler for when the request fails or succeeds.
    func request<A>(resource: HTTPResource<A>,
                    completion: HTTPCompletion<A>?) {
        request(resource: resource, behavior: nil, completion: completion)
    }
}

/// A network client that knows how to take `HTTPResource` objects, request them
/// via URLSession, and parse them.
class HTTPResourceClient: HTTPResourceClientType {
    /// The base URL to use for this network client, e.g. "http://example.com"
    private let baseURL: URL

    /// A session to use, usually URLSession.shared.
    private let session: URLSessionType

    /// Initialize this object.
    ///
    /// - parameters:
    ///   - baseURL: the base URL to use for this network client, e.g.
    ///   "http://example.com"
    ///   - session: the `URLSessionType` to use for making HTTP requests
    init(baseURL: URL, session: URLSessionType = URLSession.shared) {
        self.baseURL = baseURL
        self.session = session
    }

    /// Make an HTTP request for an `HTTPResource`.
    ///
    /// - parameters:
    ///   - resource: The resource to request
    ///   - behavior: An optional HTTPBehavior to apply to the request
    ///   - completion: A handler for when the request fails or succeeds.
    func request<A>(resource: HTTPResource<A>,
                    behavior: HTTPBehavior?,
                    completion: HTTPCompletion<A>?) {
        var request = resource.toRequest(baseURL: baseURL)
        behavior?.modifyRequest(request: &request)

        let task = session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                self.handleError(error, completion: completion)
                return
            }

            guard let response = response as? HTTPURLResponse else {
                completion?(.failure(.other(error)))
                return
            }

            guard 200 ... 299 ~= response.statusCode else {
                self.handleResponseWithStatusCode(of: response.statusCode,
                                                  data: data,
                                                  completion: completion)
                return
            }

            guard let data = data else {
                completion?(.failure(.noData))
                return
            }

            if let value = resource.parse(data) {
                completion?(.success(value))
            } else {
                completion?(.failure(.couldNotParse(data: data)))
            }
        }

        task.resume()
    }

    /// Handle an error in even being able to make a request.
    ///
    /// - parameters:
    ///   - error: The error
    ///   - completion: A handler for when the request fails or succeeds.
    fileprivate func handleError<A>(_ error: Error?, completion: HTTPCompletion<A>?) {
        if let nserror = error as NSError? {
            switch nserror.code {
            case NSURLErrorTimedOut, NSURLErrorNotConnectedToInternet: completion?(.failure(.unreachable))
            default: completion?(.failure(.other(error)))
            }
        }
    }

    /// Handle an HTTP response status (which may indicate an error or a success).
    ///
    /// - parameters:
    ///   - statusCode: The HTTP response code, e.g. 200 or 502
    ///   - data: The data returned with the response
    ///   - completion: A handler for when the request fails or succeeds.
    fileprivate func handleResponseWithStatusCode<A>(of statusCode: Int,
                                                     data: Data?,
                                                     completion: HTTPCompletion<A>?) {
        let responseText = String(data: data ?? Data(), encoding: .utf8)

        switch statusCode {
        case 401: completion?(.failure(.unauthorized))
        default:
            let error = ResourceError.invalidResponse(statusCode: statusCode, responseText: responseText ?? "")
            completion?(.failure(error))
        }
    }
}

internal extension URLRequest {

    func toString() -> String {
        return """
          \(httpMethod!) \((url?.absoluteString)!),
          \nBody: \(String(describing: httpBody != nil ? String(data: httpBody!,
                                                                  encoding: String.Encoding.utf8)! : "")) \nHeaders: \(allHTTPHeaderFields!)
        """
    }
}

internal extension Int {

    /// Returns `true` if this Int is a status code value to be retried
    func isStatusCodeForRetryableServerError() -> Bool {
        switch self {
        case 408, 429, 500, 502, 503, 504:
            return true
        default:
            return false
        }
    }
}
