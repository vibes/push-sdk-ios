import UIKit

/// A protocol that indicates the required interface for being considered a
/// `Device` in the Vibes system.
protocol DeviceType: JSONEncodable {
  /// The operating system of this device, e.g. iOS
  var systemName: String { get }

  /// The operating system version of this device, e.g. "10.3.1"
  var systemVersion: String { get }

  /// The hardware make of this device, e.g. "Apple"
  var hardwareMake: String { get }

  /// The hardware model of this device, e.g. "iPhone9,1"
  var hardwareModel: String { get }

  /// The locale for this device, e.g. "en_US"
  var localeIdentifier: String { get }

  /// The timezone for this device, e.g. "America/Chicago"
  var timeZoneIdentifier: String { get }

  /// The version of the Vibes SDK installed on this device, e.g. "1.0.1"
  var sdkVersion: String { get }

  /// The version of the app installed on this device, e.g. "2.0.0"
  var appVersion: String { get }
  
  /// A unique advertising identifier for this device, e.g.
  /// "E621E1F8-C36C-495A-93FC-0C247A3E6E5F"
  var advertisingIdentifier: String? { get }
}

/// A simple data object to allow us to send serialized Device information to
/// Vibes.
struct Device {
  
  /// A unique advertising identifier for this device, e.g.
  /// "E621E1F8-C36C-495A-93FC-0C247A3E6E5F"
  let advertisingIdentifier: String?
  
  /// Initialize this object.
  ///
  /// - parameters:
  ///   - advertisingIdentifier: AdSupport.AdvertisingIdentifier, A unique advertising
  ///     identifier for this device
  init(advertisingIdentifier: String?) {
    // check if Ad tracking has been limited by the app's user.
    // https://developer.apple.com/documentation/adsupport/asidentifiermanager
    // Sad day: elvis operator '?:' doesn't work in swift.
    if advertisingIdentifier == "00000000-0000-0000-0000-000000000000" || advertisingIdentifier == "" {
      self.advertisingIdentifier = nil
    } else {
      self.advertisingIdentifier = advertisingIdentifier
    }
  }
}

extension Device: DeviceType {
  
  var systemName: String {
    return "iOS"
  }

  var systemVersion: String {
    return UIDevice.current.systemVersion
  }

  var identifierForVendor: UUID? {
    return UIDevice.current.identifierForVendor
  }

  var localeIdentifier: String {
    return Locale.current.identifier
  }

  var timeZoneIdentifier: String {
    return NSTimeZone.local.identifier
  }

  var hardwareMake: String {
    return "Apple"
  }

  var hardwareModel: String {
    var systemInfo = utsname()
    uname(&systemInfo)

    let modelCode = withUnsafePointer(to: &systemInfo.machine) {
      $0.withMemoryRebound(to: CChar.self, capacity: 1) { ptr in
        String.init(validatingUTF8: ptr)
      }
    }

    return modelCode ?? "Unknown"
  }

  var sdkVersion: String {
    return Vibes.SDK_VERSION
  }

  var appVersion: String {
    return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
  }
}

extension DeviceType {
  func encodeJSON() -> JSONDictionary {
    let dictionary: JSONDictionary = [
      "device": [
        "os": systemName,
        "os_version": systemVersion,
        "sdk_version": sdkVersion,
        "app_version": appVersion,
        "hardware_make": hardwareMake,
        "hardware_model": hardwareModel,
        "advertising_id": advertisingIdentifier as Any,
        "locale": localeIdentifier,
        "timezone": timeZoneIdentifier
      ] as AnyObject,
    ]
    return dictionary
  }
}
