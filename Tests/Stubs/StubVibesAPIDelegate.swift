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
        didRegisterDeviceDeviceId = deviceId
        didRegisterDeviceError = error
    }

    func didUnregisterDevice(error: Error?) {
        didUnregisterDeviceError = error
        didUnregisterDeviceSuccess = true
    }

    func didRegisterPush(error: Error?) {
        didRegisterPushError = error
        didRegisterPushSuccess = true
    }

    func didUnregisterPush(error: Error?) {
        didUnregisterPushError = error
        didUnregisterPushSuccess = true
    }

    func didUpdateDevice(error: Error?) {
        didUpdateDeviceError = error
        didUpdateDeviceSuccess = true
    }

    func didAssociatePerson(error: Error?) {
        didAssociatePersonError = error
        didAssociatePersonSuccess = true
    }
}
