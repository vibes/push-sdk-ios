extension HTTPURLResponse {
  public var responseCodeDescription: String {
    let status = HTTPURLResponse.localizedString(forStatusCode: statusCode).capitalized
    return "[HTTP/1.1 \(statusCode) \(status)]"
  }
  
  public var headersDescription: String {
    var output = ""
    for (key, value) in allHeaderFields {
      output.append("\(key): \(value)")
    }
    return output
  }
}

