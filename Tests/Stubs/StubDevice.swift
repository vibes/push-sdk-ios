struct StubDevice: DeviceType {
  var pushToken: String? = "push-token"

  var systemName = "iOS"
  var systemVersion = "10.2"

  var hardwareMake: String = "Apple"
  var hardwareModel: String = "x86_64"

  var localeIdentifier = "en_US"
  var timeZoneIdentifier = "America/Chicago"

  var advertisingIdentifier: String? = "E621E1F8-C36C-495A-93FC-0C247A3E6E5F"

  var sdkVersion: String = "1.0.0"

  var appVersion: String = "2.0.0"

  var location: (lat: Double, long: Double)? = (41.8781, -87.6298)
}
