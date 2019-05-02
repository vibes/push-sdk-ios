class StubVibesAPIDelegate: VibesAPIDelegate {
  var didRegisterDeviceDeviceId: String?
  var didUnregisterDeviceSuccess = false
  var didUpdateDeviceSuccess = false
  var didRegisterPushSuccess = false
  var didUnregisterPushSuccess = false
  var didAssociatePersonSuccess = false

  var didRegisterDeviceError: Error?
  var didUnregisterDeviceError: Error?
  var didUpdateDeviceError: Error?
  var didRegisterPushError: Error?
  var didUnregisterPushError: Error?
  var didAssociatePersonError: Error?

  func didRegisterDevice(deviceId: String?, error: Error?) {
    self.didRegisterDeviceDeviceId = deviceId
    self.didRegisterDeviceError = error
  }

  func didUnregisterDevice(error: Error?) {
    self.didUnregisterDeviceError = error
    self.didUnregisterDeviceSuccess = true
  }

  func didRegisterPush(error: Error?) {
    self.didRegisterPushError = error
    self.didRegisterPushSuccess = true
  }

  func didUnregisterPush(error: Error?) {
    self.didUnregisterPushError = error
    self.didUnregisterPushSuccess = true
  }

  func didUpdateDeviceLocation(error: Error?) {
    self.didUpdateDeviceError = error
    self.didUpdateDeviceSuccess = true
  }

  func didAssociatePerson(error: Error?) {
    self.didAssociatePersonError = error
    self.didAssociatePersonSuccess = true
  }
}
