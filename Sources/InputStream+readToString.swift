import Foundation

extension InputStream {
  /// Read input stream to a String
  func readToString() -> String? {
    var data = Data()
    self.open()
    
    let bufferSize = 1024
    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
    while self.hasBytesAvailable {
      let read = self.read(buffer, maxLength: bufferSize)
      data.append(buffer, count: read)
    }
    buffer.deallocate(capacity: bufferSize)
    self.close()
    return String(data: data, encoding: String.Encoding.utf8)
  }
}
