import Foundation

extension URLRequest {
  /// Represents an HTTP request as a copy-and-pasteable string that can be used with cURL.
  public var urlDescription: String {
    if let url = url?.absoluteString {
      return url
    }
    return "[-]"
  }
  
  public var methodDescription: String {
    if let method = httpMethod, method != "GET" && method != "HEAD" {
      return method
    }
    return "[-]"
  }
  
  public var headerFieldsDescription: String {
    var result = ""
    if let headers = allHTTPHeaderFields {
      for (key, value) in headers {
        result.append("[\(key) : '\(value)']")
      }
      return result
    }
    return "[-]"
  }
  
  public var bodyDescription: String {
    if let body = httpBodyStream?.readToString() {
      return body
    }
    return "[-]"
  }
}

