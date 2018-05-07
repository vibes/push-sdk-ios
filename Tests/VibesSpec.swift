import Foundation
import Quick
import Nimble
@testable import VibesPush

class VibesSpec: QuickSpec {
  override func spec() {
    var api: StubVibesAPI!
    var vibes: Vibes!
    var storage: StubStorage!

    beforeEach {
      api = StubVibesAPI()
      storage = StubStorage()
      Vibes.configure(appId: "TEST_APP_KEY")
      vibes = Vibes(appId: "appId", api: api, storage: storage)
    }

    describe("#pushToken") {
      it("allows setting and getting token from local storage") {
        vibes.pushToken = "token"
        expect(vibes.pushToken).to(equal("token"))
      }
    }

    describe("#setPushToken") {
      it("allows setting token from data") {
        let token = "657F777A291848BCE47C68439F21D326999CC0AE41AD0E824069E568BADFE1AB"

        let hexPairs = stride(from: 0, to: token.characters.count, by: 2).map({ (index) -> String in
          let startIndex = token.index(token.startIndex, offsetBy: index)
          let endIndex = token.index(startIndex, offsetBy: 2, limitedBy: token.endIndex) ?? token.endIndex
          return token[startIndex..<endIndex]
        })

        let tokenData = hexPairs.reduce(Data(), { (data, hexPair) -> Data in
          var data = data
          data.append(UInt8(hexPair, radix: 16)!)
          return data
        })

        vibes.setPushToken(fromData: tokenData)
        expect(vibes.pushToken).to(equal(token))
      }
    }

    context("without credentials") {
      var expected: Error?

      describe("#registerDevice") {
        context("with success") {
          it("hits the API and returns a Credential") {
            let cannedCredential = Credential(deviceId: "", authToken: "")
            api.add(result: ResourceResult.success(cannedCredential))

            var expected: Credential?
            vibes.registerDevice { result in
              if case let .success(value) = result {
                expected = value
              }
            }
            expect(expected).toEventually(equal(cannedCredential))
          }

          context("with failure") {
            it("hits the API and returns an error") {
              let cannedError: ResourceError = .noData
              api.add(result: ResourceResult<Credential>.failure(cannedError))

              vibes.registerDevice { result in
                if case let .failure(value) = result {
                  expected = value
                }
              }
              expect(expected).to(matchError(VibesError.self))
            }
          }
        }
      }

      describe("#unregisterDevice") {
        context("without credential") {
          it("returns an error without hitting the API") {
            vibes.unregisterDevice { result in
              if case let .failure(value) = result {
                expected = value
              }
            }
            expect(expected).to(matchError(VibesError.noCredentials))
          }
        }
      }

      describe("#updateDevice") {
        it("returns an error without hitting the API") {
          vibes.updateDevice { result in
            if case let .failure(value) = result {
              expected = value
            }
          }
          expect(expected).to(matchError(VibesError.noCredentials))
        }
      }

      describe("#registerPush") {
        it("returns an error without hitting the API") {
          vibes.registerPush { result in
            if case let .failure(value) = result {
              expected = value
            }
          }
          expect(expected).to(matchError(VibesError.noCredentials))
        }
      }

      describe("#unregisterPush") {
        it("returns an error without hitting the API") {
          vibes.unregisterPush { result in
            if case let .failure(value) = result {
              expected = value
            }
          }
          expect(expected).to(matchError(VibesError.noCredentials))
        }
      }
    }

    context("with credentials") {
      beforeEach {
        let storedCredential = Credential(deviceId: "id", authToken: "token")
        vibes.credentialManager.currentCredential = storedCredential
      }

      describe("#unregisterDevice") {
        context("with success") {
          it("hits the API and returns nothing") {
            api.add(result: ResourceResult<Void>.success())

            var called: Bool = false
            vibes.unregisterDevice { result in
              if case .success = result {
                called = true
              }
            }
            expect(called).toEventually(beTruthy())
          }
        }

        context("with failure") {
          it("hits the API and returns an error") {
            let cannedError: ResourceError = .noData
            api.add(result: ResourceResult<Void>.failure(cannedError))

            var expected: Error?
            vibes.unregisterDevice { result in
              if case let .failure(value) = result {
                expected = value
              }
            }
            expect(expected).to(matchError(VibesError.other("no data")))
          }
        }
      }

      describe("#updateDevice") {
        context("with success") {
          it("hits the API and returns successfully") {
            let cannedCredential = Credential(deviceId: "", authToken: "")
            api.add(result: ResourceResult.success(cannedCredential))

            var expected: Credential?
            vibes.updateDevice { result in
              if case let .success(value) = result {
                expected = value
              }
            }

            expect(expected).toEventually(equal(cannedCredential))
          }
        }

        context("with failure") {
          it("hits the API and returns an error") {
            let cannedError: ResourceError = .noData
            api.add(result: ResourceResult<Credential>.failure(cannedError))
            var expected: Error?
            vibes.credentialManager.currentCredential = nil
            vibes.registerDevice { result in
              if case let .failure(value) = result {
                expected = value
              }
            }
            expect(expected).to(matchError(VibesError.other("no data")))
          }
        }
      }

      describe("#registerPush") {
        context("without push token") {
          it("returns an error without hitting the API") {
            var expected: Error?
            vibes.registerPush { result in
              if case let .failure(value) = result {
                expected = value
              }
            }
            expect(expected).to(matchError(VibesError.noPushToken))
          }
        }

        context("with success") {
          it("hits the API and returns nothing") {
            vibes.pushToken = "token"
            api.add(result: ResourceResult<Void>.success())

            var called: Bool = false
            vibes.registerPush { result in
              if case .success = result {
                called = true
              }
            }
            expect(called).toEventually(beTruthy())
          }
        }

        context("with failure") {
          it("hits the API and returns an error") {
            vibes.pushToken = "token"
            let cannedError: ResourceError = .noData
            api.add(result: ResourceResult<Void>.failure(cannedError))

            var expected: Error?
            vibes.registerPush { result in
              if case let .failure(value) = result {
                expected = value
              }
            }
            expect(expected).to(matchError(VibesError.other("no data")))
          }
        }
      }

      describe("#unregisterPush") {
        context("with success") {
          it("hits the API and returns nothing") {
            api.add(result: ResourceResult<Void>.success())

            var called: Bool = false
            vibes.unregisterPush { result in
              if case .success = result {
                called = true
              }
            }
            expect(called).toEventually(beTruthy())
          }
        }

        context("with failure") {
          it("hits the API and returns an error") {
            let cannedError: ResourceError = .noData
            api.add(result: ResourceResult<Void>.failure(cannedError))

            var expected: Error?
            vibes.unregisterPush { result in
              if case let .failure(value) = result {
                expected = value
              }
            }
            expect(expected).to(matchError(VibesError.other("no data")))
          }
        }
      }
    }
  }
}
