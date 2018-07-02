import Foundation
import Quick
import Nimble
@testable import VibesPush

class VibesSpec: QuickSpec {
  var delegate: StubVibesAPIDelegate!

  override func spec() {
    var api: StubVibesAPI!
    var vibes: Vibes!
    var storage: StubStorage!
    var apnsToken: Data!

    beforeEach {
      api = StubVibesAPI()
      storage = StubStorage()
      vibes = Vibes(appId: "appId", api: api, storage: storage)

      self.delegate = StubVibesAPIDelegate()
      vibes.set(delegate: self.delegate)
    }

    describe("#pushToken") {
      it("allows setting and getting token from local storage") {
        vibes.pushToken = "token"
        expect(vibes.pushToken).to(equal("token"))
      }
    } // pushToken

    describe("#setPushToken") {
      it("allows setting token from data") {
        let token = "657F777A291848BCE47C68439F21D326999CC0AE41AD0E824069E568BADFE1AB"

        let hexPairs = stride(from: 0, to: token.count, by: 2).map({ (index) -> String in
          let startIndex = token.index(token.startIndex, offsetBy: index)
          let endIndex = token.index(startIndex, offsetBy: 2, limitedBy: token.endIndex) ?? token.endIndex
          return token[startIndex..<endIndex]
        })

        let tokenData = hexPairs.reduce(Data(), { (data, hexPair) -> Data in
          var data = data
          data.append(UInt8(hexPair, radix: 16)!)
          return data
        })
        apnsToken = tokenData
        print(apnsToken)
        vibes.setPushToken(fromData: tokenData)
        expect(vibes.pushToken).to(equal(token))
      }
    } // setPushToken

    describe(".logger") {
      context("logger was supplied") {
        it("returns a logger") {
          let logger = ConsoleLogger()
          Vibes.configure(appId: "id", trackedEventTypes: [], storageType: .USERDEFAULTS, advertisingId: nil, logger: logger, apiUrl: nil)
          expect(Vibes.shared.logger).notTo(beNil())
          expect(Vibes.shared.logger).to(be(logger))
        }
      }
      context("logger was not supplied") {
        it("returns nil") {
          Vibes.configure(appId: "id", trackedEventTypes: [], storageType: .USERDEFAULTS, advertisingId: nil, apiUrl: nil)
          expect(Vibes.shared.logger).to(beNil())
        }
      }
    }

    context("without credentials") {
      describe("#registerDevice") {
        context("with success") {
          it("hits the API and returns a Credential") {
            let cannedCredential = VibesCredential(deviceId: "", authToken: "")
            api.add(result: ResourceResult.success(cannedCredential))

            vibes.registerDevice()

            expect(self.delegate.didRegisterDeviceDeviceId).toEventually(equal(cannedCredential.deviceId))
          }
        } // with success

        context("with failure") {
          it("hits the API and returns an error") {
            let cannedError = ResourceError.noData
            api.add(result: ResourceResult<VibesCredential>.failure(cannedError))

            vibes.registerDevice()

            expect(self.delegate.didRegisterDeviceError).toEventually(matchError(VibesError.self))
          }
        } // with failure
      } // registerDevice

      describe("#unregisterDevice") {
        it("returns an error without hitting the API") {
          vibes.unregisterDevice()
          expect(self.delegate.didUnregisterDeviceError).toEventually(matchError(VibesError.noCredentials))
        }
      } // unregisterDevice

      describe("#updateDevice") {
        it("returns an error without hitting the API") {
          vibes.updateDevice(lat: 48.2, long: 3.333)
          expect(self.delegate.didUpdateDeviceError).toEventually(matchError(VibesError.noCredentials))
        }
      } // updateDevice

      describe("#registerPush") {
        it("returns an error without hitting the API") {
          vibes.setPushToken(fromData: apnsToken)
          vibes.registerPush()
          expect(self.delegate.didRegisterPushError).toEventually(matchError(VibesError.noCredentials))
        }
      } // registerPush

      describe("#unregisterPush") {
        it("returns an error without hitting the API") {
          vibes.setPushToken(fromData: apnsToken)
          vibes.unregisterPush()
          expect(self.delegate.didUnregisterPushError).toEventually(matchError(VibesError.noCredentials))
        }
      } // unregisterPush

      describe("#associatePerson") {
        it("returns an error without hitting the API") {
          vibes.associatePerson(externalPersonId: "external person id")
          expect(self.delegate.didAssociatePersonError).toEventually(matchError(VibesError.noCredentials))
        }
      } // associatePerson
    } // without credentials

    context("with credentials") {
      beforeEach {
        let storedCredential = VibesCredential(deviceId: "id", authToken: "token")
        vibes.credentialManager.currentCredential = storedCredential
      }

      describe("#unregisterDevice") {
        context("with success") {
          it("hits the API and returns nothing") {
            api.add(result: ResourceResult<Void>.success())

            vibes.unregisterDevice()

            expect(self.delegate.didUnregisterDeviceSuccess).toEventually(beTruthy())
          }
        } // with success

        context("with failure") {
          it("hits the API and returns an error") {
            let cannedError: ResourceError = .noData
            api.add(result: ResourceResult<Void>.failure(cannedError))

            vibes.unregisterDevice()

            expect(self.delegate.didUnregisterDeviceError).toEventually(matchError(VibesError.other("no data")))
          }
        } // with failure
      } // unregisterDevice

      describe("#updateDevice") {
        context("with success") {
          it("hits the API and returns nothing") {
            api.add(result: ResourceResult<Void>.success())

            vibes.updateDevice(lat: 48.2, long: 3.333)

            expect(self.delegate.didUpdateDeviceSuccess).toEventually(beTruthy())
          }
        } // with success

        context("with failure") {
          it("hits the API and returns an error") {
            let cannedError: ResourceError = .noData
            api.add(result: ResourceResult<Void>.failure(cannedError))

            vibes.updateDevice(lat: 48.2, long: 3.333)

            expect(self.delegate.didUpdateDeviceError).toEventually(matchError(VibesError.other("no data")))
          }
        } // with failure
      } // updateDevice

      describe("#registerPush") {
        context("without push token") {
          it("returns an error without hitting the API") {
            vibes.registerPush()
            expect(self.delegate.didRegisterPushError).toEventually(matchError(VibesError.noPushToken))
          }
        } // without push token

        context("with success") {
          it("hits the API and returns nothing") {
            vibes.pushToken = "token"
            api.add(result: ResourceResult<Void>.success())

            vibes.registerPush()

            expect(self.delegate.didRegisterPushSuccess).toEventually(beTruthy())
          }
        } // with success

        context("with failure") {
          it("hits the API and returns an error") {
            vibes.pushToken = "token"
            let cannedError: ResourceError = .noData
            api.add(result: ResourceResult<Void>.failure(cannedError))

            vibes.registerPush()

            expect(self.delegate.didRegisterPushError).toEventually(matchError(VibesError.other("no data")))
          }
        } // with failure
      } // registerPush

      describe("#unregisterPush") {
        context("with success") {
          it("hits the API and returns nothing") {
            api.add(result: ResourceResult<Void>.success())
            vibes.setPushToken(fromData: apnsToken)

            vibes.unregisterPush()

            expect(self.delegate.didUnregisterPushSuccess).toEventually(beTruthy())
          }
        } // with success

        context("with failure") {
          it("hits the API and returns an error") {
            let cannedError: ResourceError = .noData
            api.add(result: ResourceResult<Void>.failure(cannedError))
            vibes.setPushToken(fromData: apnsToken)

            vibes.unregisterPush()

            expect(self.delegate.didUnregisterPushError).toEventually(matchError(VibesError.other("no data")))
          }
        } // with failure
      } // unregisterPush

      describe("#associatePerson") {
        context("with success") {
          it("hits the API, returns nothing, and calls delegate") {
            api.add(result: ResourceResult<Void>.success())

            vibes.associatePerson(externalPersonId: "external person id")

            expect(self.delegate.didAssociatePersonSuccess).toEventually(beTruthy())
          }
        } // with success

        context("with failure") {
          it("hits the API, returns nothing, and calls delegate") {
            let cannedError: ResourceError = .noData
            api.add(result: ResourceResult<Void>.failure(cannedError))

            vibes.associatePerson(externalPersonId: "external person id")

            expect(self.delegate.didAssociatePersonError).toEventually(matchError(VibesError.other("no data")))
          }
        } // with success
      } // associatePerson
    } // with credentials
  } // spec
} // class
