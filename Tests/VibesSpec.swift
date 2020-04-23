import Foundation
import Nimble
import Quick
@testable import VibesPush

class VibesSpec: QuickSpec {
    var delegate: StubVibesAPIDelegate!

    override func spec() {
        var api: StubVibesAPI!
        var vibes: Vibes!
        var apnsToken: Data!
        let token = "657F777A291848BCE47C68439F21D326999CC0AE41AD0E824069E568BADFE1AB"

        beforeEach {
            let hexPairs = stride(from: 0, to: token.count, by: 2).map({ (index) -> String in
                let startIndex = token.index(token.startIndex, offsetBy: index)
                let endIndex = token.index(startIndex, offsetBy: 2, limitedBy: token.endIndex) ?? token.endIndex
                return String(token[startIndex ..< endIndex])
            })

            apnsToken = hexPairs.reduce(Data(), { (data, hexPair) -> Data in
                var data = data
                data.append(UInt8(hexPair, radix: 16)!)
                return data
            })

            api = StubVibesAPI()
            vibes = StubVibesWithMockStorage(appId: "appId",
                                             configuration: VibesConfiguration())
            vibes.api = api
            self.delegate = StubVibesAPIDelegate()
            vibes.set(delegate: self.delegate)
        }

        describe("SDK_VERSION") {
            it("finds the correct bundle and returns the version number") {
                expect(Vibes.SDK_VERSION).to(match("\\d+\\.\\d+\\.\\d+"))
            }
        }

        describe("#pushToken") {
            it("allows setting and getting token from local storage") {
                vibes.pushToken = "token"
                expect(vibes.pushToken).to(equal("token"))
            }
        } // pushToken

        describe("#setPushToken") {
            it("allows setting token from data") {
                vibes.setPushToken(fromData: apnsToken)
                expect(vibes.pushToken).to(equal(token))
            }
        } // setPushToken

        describe(".logger") {
            context("logger was supplied") {
                it("returns a logger") {
                    let logger = ConsoleLogger()
                    let configuration = VibesConfiguration(logger: logger)
                    let instance = Vibes(appId: "id",
                                         configuration: configuration)
                    expect(instance.configuration.logger).notTo(beNil())
                    expect(instance.configuration.logger).to(be(logger))
                }
            }

            context("logger was not supplied") {
                it("returns nil") {
                    let configuration = VibesConfiguration()
                    let instance = Vibes(appId: "id",
                                         configuration: configuration)
                    expect(instance.configuration.logger).to(beNil())
                }
            }
        }
        
        describe("#handleDuplicateLaunchEventsBySecond") {
            var existingEvents = [Event]()
            it("removes any duplicate launch events") {
                let newEvent = Event(eventType: .launch, properties: ["new": "event"])
                let result = vibes.handleDuplicateLaunchEventsBySecond(events: [newEvent, newEvent], existing: existingEvents)
                expect(result).to(equal([newEvent]))
            }
            it("does not remove other events on same timestamp") {
                let newEvent = Event(eventType: .launch, properties: ["new": "event"])
                let clickthruEvent = Event(eventType: .clickthru, properties: ["another": "event"])
                let result = vibes.handleDuplicateLaunchEventsBySecond(events: [newEvent, clickthruEvent], existing: existingEvents)
                expect(result).to(equal([newEvent, clickthruEvent]))
            }
            it("does not remove launch events if more than a second apart") {
                let newEvent = Event(eventType: .launch, properties: ["new": "event"])
                let anotherEvent = Event(eventType: .launch, properties: ["another": "event"], timestamp: newEvent.timestamp.adding(seconds: 2))
                let result = vibes.handleDuplicateLaunchEventsBySecond(events: [newEvent, newEvent, anotherEvent], existing: existingEvents)
                expect(result).to(equal([newEvent, anotherEvent]))
            }
            it("will ignore new launch event if we have existing launch event within the second") {
                let existingEvent = Event(eventType: .launch, properties: ["another": "event"])
                let newEvent = Event(eventType: .launch, properties: ["new": "event"])
                let clickthruEvent = Event(eventType: .clickthru, properties: ["another": "event"])
                existingEvents.append(existingEvent)
                let result = vibes.handleDuplicateLaunchEventsBySecond(events: [newEvent, clickthruEvent], existing: existingEvents)
                expect(result).to(equal([clickthruEvent])) // only the clickthru event will sail through
            }
            it("will not ignore new launch event if we have existing launch event several seconds apart") {
                let existingEvent = Event(eventType: .launch, properties: ["another": "event"])
                let newEvent = Event(eventType: .launch, properties: ["new": "event"], timestamp: existingEvent.timestamp.adding(seconds: 5)) // making the newEvent 5 seconds later
                existingEvents.append(existingEvent)
                let result = vibes.handleDuplicateLaunchEventsBySecond(events: [newEvent], existing: existingEvents)
                expect(result).to(equal([newEvent]))
            }
        } // handleDuplicateLaunchEventsBySecond

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

            describe("#getPerson") {
                it("returns an error without hitting the API") {
                    var personResult: Person?
                    var errorResult: Error?
                    vibes.setPushToken(fromData: apnsToken)
                    vibes.getPerson { person, error in
                        personResult = person
                        errorResult = error
                    }
                    expect(errorResult).toEventually(matchError(VibesError.noCredentials))
                    expect(personResult).toEventually(beNil())
                }
            } // getPerson

            describe("#fetchInboxMessages") {
                it("returns an error without hitting the API") {
                    var msgsResult = [InboxMessage]()
                    var errorResult: Error?
                    vibes.fetchInboxMessages { messages, error in
                        msgsResult = messages
                        errorResult = error
                    }
                    expect(msgsResult.isEmpty).toEventually(beTruthy())
                    expect(errorResult).toEventually(matchError(VibesError.noCredentials))
                }
            } // fetchInboxMessages

            describe("#fetchInboxMessage") {
                it("returns an error without hitting the API") {
                    // save person in storsge
                    let person = Person(externalPersonId: "ext_person_id", mdn: "mdn", personKey: "person_key")
                    vibes.storage.set(person, for: LocalStorageKeys.currentPerson)
                    var msgsResult: InboxMessage?
                    var errorResult: Error?
                    let messageUID = "msgID"
                    vibes.fetchInboxMessage(messageUID: messageUID) { message, error in
                        msgsResult = message
                        errorResult = error
                    }
                    expect(msgsResult).toEventually(beNil())
                    expect(errorResult).toEventually(matchError(VibesError.noCredentials))
                }
            } // fetchInboxMessage

            describe("#markInboxMessageAsRead") {
                it("returns an error without hitting the API") {
                    // save person in storsge
                    let person = Person(externalPersonId: "ext_person_id", mdn: "mdn", personKey: "person_key")
                    vibes.storage.set(person, for: LocalStorageKeys.currentPerson)
                    var msgsResult: InboxMessage?
                    var errorResult: Error?
                    let messageUID = "msgID"
                    vibes.markInboxMessageAsRead(messageUID: messageUID) { message, error in
                        msgsResult = message
                        errorResult = error
                    }
                    expect(msgsResult).toEventually(beNil())
                    expect(errorResult).toEventually(matchError(VibesError.noCredentials))
                }
            } // markInboxMessageAsRead

            describe("#expireInboxMessage") {
                it("returns an error without hitting the API") {
                    // save person in storsge
                    let person = Person(externalPersonId: "ext_person_id", mdn: "mdn", personKey: "person_key")
                    vibes.storage.set(person, for: LocalStorageKeys.currentPerson)

                    var msgsResult: InboxMessage?
                    var errorResult: Error?
                    let messageUID = "msgID"
                    vibes.expireInboxMessage(messageUID: messageUID) { message, error in
                        msgsResult = message
                        errorResult = error
                    }
                    expect(msgsResult).toEventually(beNil())
                    expect(errorResult).toEventually(matchError(VibesError.noCredentials))
                }
            } // expireInboxMessage
        } // without credentials

        context("with credentials") {
            beforeEach {
                let storedCredential = VibesCredential(deviceId: "id", authToken: "token")
                vibes.credentialManager.currentCredential = storedCredential
            }

            describe("#unregisterDevice") {
                context("with success") {
                    it("hits the API and returns nothing") {
                        api.add(result: ResourceResult<Void>.success(()))

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
                        api.add(result: ResourceResult<Void>.success(()))

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
                        api.add(result: ResourceResult<Void>.success(()))

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
                        api.add(result: ResourceResult<Void>.success(()))
                        vibes.pushToken = token

                        vibes.unregisterPush()

                        expect(self.delegate.didUnregisterPushSuccess).toEventually(beTruthy())
                    }
                } // with success

                context("with failure") {
                    it("hits the API and returns an error") {
                        let cannedError: ResourceError = .noData
                        api.add(result: ResourceResult<Void>.failure(cannedError))
                        vibes.pushToken = token

                        vibes.unregisterPush()

                        expect(self.delegate.didUnregisterPushError).toEventually(matchError(VibesError.other("no data")))
                    }
                } // with failure
            } // unregisterPush

            describe("#associatePerson") {
                context("with success") {
                    it("hits the API, returns nothing, and calls delegate") {
                        api.add(result: ResourceResult<Void>.success(()))

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

            describe("#getPerson") {
                context("with success") {
                    it("hits the API and returns person object") {
                        vibes.pushToken = token
                        let expectedPerson = Person(externalPersonId: "ext_person_id", mdn: "mdn", personKey: "person_key")
                        api.add(result: ResourceResult<Person>.success(expectedPerson))
                        var personResult: Person?
                        var errorResult: Error?
                        vibes.getPerson { person, error in
                            personResult = person
                            errorResult = error
                        }
                        expect(expectedPerson.personKey == personResult?.personKey).toEventually(beTruthy())
                        expect(errorResult).toEventually(beNil())
                    }
                } // with success

                context("with failure") {
                    it("hits the API and returns an error") {
                        vibes.pushToken = token
                        let cannedError: ResourceError = .noData
                        api.add(result: ResourceResult<Person>.failure(cannedError))
                        var personResult: Person?
                        var errorResult: Error?
                        vibes.getPerson { person, error in
                            personResult = person
                            errorResult = error
                        }
                        expect(personResult).toEventually(beNil())
                        expect(errorResult).toEventually(matchError(VibesError.other("no data")))
                    }
                } // with failure
            } // getPerson

            describe("#fetchInboxMessages") {
                context("with success") {
                    it("hits the API and returns InboxMessages array") {
                        vibes.pushToken = token
                        // add success result for get person
                        let expectedPerson = Person(externalPersonId: "ext_person_id", mdn: "mdn", personKey: "person_key")
                        api.add(result: ResourceResult<Person>.success(expectedPerson))
                        // add success result for get messages
                        var messages = [InboxMessage]()
                        messages.append(InboxMessage(messageUID: "msgID", subject: "subject", content: "content", detail: "url", read: false))
                        api.add(result: ResourceResult<[InboxMessage]>.success(messages))

                        var msgsResult = [InboxMessage]()
                        var errorResult: Error?
                        vibes.fetchInboxMessages { messages, error in
                            msgsResult = messages
                            errorResult = error
                        }
                        expect(msgsResult.count).toEventually(equal(1))
                        expect(errorResult).toEventually(beNil())
                    }
                } // with success

                context("with failure") {
                    it("hits the API and returns an error") {
                        vibes.pushToken = token
                        // add success result for get person
                        let expectedPerson = Person(externalPersonId: "ext_person_id", mdn: "mdn", personKey: "person_key")
                        api.add(result: ResourceResult<Person>.success(expectedPerson))
                        // add error result for get messages
                        let cannedError: ResourceError = .noData
                        api.add(result: ResourceResult<[InboxMessage]>.failure(cannedError))
                        var msgsResult = [InboxMessage]()
                        var errorResult: Error?
                        vibes.fetchInboxMessages { messages, error in
                            msgsResult = messages
                            errorResult = error
                        }
                        expect(msgsResult.isEmpty).toEventually(beTruthy())
                        expect(errorResult).toEventually(matchError(VibesError.other("no data")))
                    }
                } // with failure
            } // fetchInboxMessages

            describe("#fetchInboxMessage") {
                context("with success") {
                    it("hits the API and returns InboxMessage") {
                        vibes.pushToken = token
                        // save person in storage

                        let person = Person(externalPersonId: "ext_person_id", mdn: "mdn", personKey: "person_key")
                        vibes.storage.set(person, for: LocalStorageKeys.currentPerson)

                        let originalMessage = InboxMessage(messageUID: "msgID", subject: "subject", content: "content", detail: "url", read: true)
                        api.add(result: ResourceResult<InboxMessage>.success(originalMessage))

                        var editedMessage: InboxMessage?
                        var editError: Error?

                        vibes.fetchInboxMessage(messageUID: "msgID") { message, error in
                            editedMessage = message
                            editError = error
                        }
                        expect(editedMessage).toEventually(equal(originalMessage))
                        expect(editError).toEventually(beNil())
                    }
                } // with success

                context("without saved person") {
                    it("retrieves person before hitting the api") {
                        vibes.pushToken = token

                        // add success result for get person
                        let expectedPerson = Person(externalPersonId: "ext_person_id", mdn: "mdn", personKey: "person_key")
                        api.add(result: ResourceResult<Person>.success(expectedPerson))

                         // add success result for get message details
                        let originalMessage = InboxMessage(messageUID: "msgID", subject: "subject", content: "content", detail: "url", read: true)
                        api.add(result: ResourceResult<InboxMessage>.success(originalMessage))

                        var editMsgsResult: InboxMessage?
                        var editErrorResult: Error?

                        vibes.fetchInboxMessage(messageUID: "msgId") { message, error in
                            editMsgsResult = message
                            editErrorResult = error
                        }

                        expect(editMsgsResult).toEventually(equal(originalMessage))
                        expect(editErrorResult).toEventually(beNil())
                    }
                } // without saved person

                context("with failure") {
                    it("hits the API and returns an error") {
                        vibes.pushToken = token
                        // save person in storage
                        let person = Person(externalPersonId: "ext_person_id", mdn: "mdn", personKey: "person_key")
                        vibes.storage.set(person, for: LocalStorageKeys.currentPerson)

                        // add error result for get messages
                        let cannedError: ResourceError = .noData
                        api.add(result: ResourceResult<InboxMessage>.failure(cannedError))

                        var editMsgsResult: InboxMessage?
                        var editErrorResult: Error?

                        vibes.fetchInboxMessage(messageUID: "msgId") { message, error in
                            editMsgsResult = message
                            editErrorResult = error
                        }
                        expect(editMsgsResult).toEventually(beNil())
                        expect(editErrorResult).toEventually(matchError(VibesError.other("no data")))
                    }
                } // with failure
            } // fetchInboxMessage

            describe("#updateInboxMessage") {
                context("with success") {
                    it("hits the API and returns InboxMessage") {
                        vibes.pushToken = token
                        // save person in storage

                        let person = Person(externalPersonId: "ext_person_id", mdn: "mdn", personKey: "person_key")
                        vibes.storage.set(person, for: LocalStorageKeys.currentPerson)

                        let originalMessage = InboxMessage(messageUID: "msgID", subject: "subject", content: "content", detail: "url", read: true)
                        api.add(result: ResourceResult<InboxMessage>.success(originalMessage))

                        var editedMessage: InboxMessage?
                        var editError: Error?
                        let payload: VibesJSONDictionary = ["read": true as AnyObject]

                        vibes.updateInboxMessage(messageUID: "msgID", payload: payload, callback: { message, error in
                            editedMessage = message
                            editError = error
                        })
                        expect(editedMessage).toEventually(equal(originalMessage))
                        expect(editError).toEventually(beNil())
                    }
                } // with success

                context("without saved person") {
                    it("retrieves person before  hitting the api") {
                        vibes.pushToken = token

                        // add success result for get person
                        let expectedPerson = Person(externalPersonId: "ext_person_id", mdn: "mdn", personKey: "person_key")
                        api.add(result: ResourceResult<Person>.success(expectedPerson))

                         // add success result for update message
                        let originalMessage = InboxMessage(messageUID: "msgID", subject: "subject", content: "content", detail: "url", read: true)
                        api.add(result: ResourceResult<InboxMessage>.success(originalMessage))

                        var editMsgsResult: InboxMessage?
                        var editErrorResult: Error?
                        let payload: VibesJSONDictionary = ["read": true as AnyObject]
                      
                        vibes.updateInboxMessage(messageUID: "msgId", payload: payload, callback: { message, error in
                            editMsgsResult = message
                            editErrorResult = error
                        })

                        expect(editMsgsResult).toEventually(equal(originalMessage))
                        expect(editErrorResult).toEventually(beNil())
                    }
                } // without saved person

                context("with failure") {
                    it("hits the API and returns an error") {
                        vibes.pushToken = token
                        // save person in storage
                        let person = Person(externalPersonId: "ext_person_id", mdn: "mdn", personKey: "person_key")
                        vibes.storage.set(person, for: LocalStorageKeys.currentPerson)

                        // add error result for get messages
                        let cannedError: ResourceError = .noData
                        api.add(result: ResourceResult<InboxMessage>.failure(cannedError))

                        var editMsgsResult: InboxMessage?
                        var editErrorResult: Error?
                        let payload: VibesJSONDictionary = ["read": true as AnyObject]
                        vibes.updateInboxMessage(messageUID: "msgId", payload: payload, callback: { message, error in
                            editMsgsResult = message
                            editErrorResult = error
                        })
                        expect(editMsgsResult).toEventually(beNil())
                        expect(editErrorResult).toEventually(matchError(VibesError.other("no data")))
                    }
                } // with failure
            } // updateInboxMessage

            describe("#markInboxMessageAsRead") {
                context("with success") {
                    it("hits the API and returns InboxMessage") {
                        vibes.pushToken = token
                        // add success result for get person
                        let person = Person(externalPersonId: "ext_person_id", mdn: "mdn", personKey: "person_key")
                        vibes.storage.set(person, for: LocalStorageKeys.currentPerson)

                        let originalMessage = InboxMessage(messageUID: "msgID", subject: "subject", content: "content", detail: "url", read: true)
                        api.add(result: ResourceResult<InboxMessage>.success(originalMessage))

                        var editedMessage: InboxMessage?
                        var editError: Error?
                        vibes.markInboxMessageAsRead(messageUID: "msgID") { message, error in
                            editedMessage = message
                            editError = error
                        }
                      
                        expect(editedMessage).toEventually(equal(originalMessage))
                        expect(editError).toEventually(beNil())
                    }
                } // with success

                context("with failure") {
                    it("hits the API and returns an error") {
                        vibes.pushToken = token
                        // save person in storage
                        let person = Person(externalPersonId: "ext_person_id", mdn: "mdn", personKey: "person_key")
                        vibes.storage.set(person, for: LocalStorageKeys.currentPerson)

                        // add error result for get messages
                        let cannedError: ResourceError = .noData
                        api.add(result: ResourceResult<InboxMessage>.failure(cannedError))

                        var editMsgsResult: InboxMessage?
                        var editErrorResult: Error?

                        vibes.markInboxMessageAsRead(messageUID: "msgId") { message, error in
                            editMsgsResult = message
                            editErrorResult = error
                        }
                        expect(editMsgsResult).toEventually(beNil())
                        expect(editErrorResult).toEventually(matchError(VibesError.other("no data")))
                    }
                } // with failure

                context("without saved person") {
                    it("returns an error without hitting the api") {
                        vibes.pushToken = token

                        // add success result for get person
                        let expectedPerson = Person(externalPersonId: "ext_person_id", mdn: "mdn", personKey: "person_key")
                        api.add(result: ResourceResult<Person>.success(expectedPerson))

                        // add success result for mark message as read
                        let originalMessage = InboxMessage(messageUID: "msgID", subject: "subject", content: "content", detail: "url", read: true)
                        api.add(result: ResourceResult<InboxMessage>.success(originalMessage))

                        var editMsgsResult: InboxMessage?
                        var editErrorResult: Error?
                        vibes.markInboxMessageAsRead(messageUID: "msgId") { message, error in
                            editMsgsResult = message
                            editErrorResult = error
                        }
                      
                        expect(editMsgsResult).toEventually(equal(originalMessage))
                        expect(editErrorResult).toEventually(beNil())
                    }
                } // without saved person
            } // markInboxMessageAsRead

            describe("#expireInboxMessage") {
                context("with success") {
                    it("hits the API and returns InboxMessage") {
                        vibes.pushToken = token
                        // add success result for get person
                        let person = Person(externalPersonId: "ext_person_id", mdn: "mdn", personKey: "person_key")
                        vibes.storage.set(person, for: LocalStorageKeys.currentPerson)

                        let originalMessage = InboxMessage(messageUID: "msgID", subject: "subject", content: "content", detail: "url", read: true)
                        api.add(result: ResourceResult<InboxMessage>.success(originalMessage))

                        var editedMessage: InboxMessage?
                        var editError: Error?
                        vibes.expireInboxMessage(messageUID: "msgID", date: Date()) { message, error in
                            editedMessage = message
                            editError = error
                        }
                        expect(editedMessage).toEventually(equal(originalMessage))
                        expect(editError).toEventually(beNil())
                    }
                } // with success

                context("with failure") {
                    it("hits the API and returns an error") {
                        vibes.pushToken = token
                        // save person in storage
                        let person = Person(externalPersonId: "ext_person_id", mdn: "mdn", personKey: "person_key")
                        vibes.storage.set(person, for: LocalStorageKeys.currentPerson)

                        // add error result for get messages
                        let cannedError: ResourceError = .noData
                        api.add(result: ResourceResult<InboxMessage>.failure(cannedError))

                        var editMsgsResult: InboxMessage?
                        var editErrorResult: Error?
                        vibes.expireInboxMessage(messageUID: "msgId") { message, error in
                            editMsgsResult = message
                            editErrorResult = error
                        }
                        expect(editMsgsResult).toEventually(beNil())
                        expect(editErrorResult).toEventually(matchError(VibesError.other("no data")))
                    }
                } // with failure

                context("without saved person") {
                    it("retrieves person before hitting the api") {
                        vibes.pushToken = token

                        // add success result for get person
                        let expectedPerson = Person(externalPersonId: "ext_person_id", mdn: "mdn", personKey: "person_key")
                        api.add(result: ResourceResult<Person>.success(expectedPerson))

                         // add success result for expire message
                        let originalMessage = InboxMessage(messageUID: "msgID", subject: "subject", content: "content", detail: "url", read: true)
                        api.add(result: ResourceResult<InboxMessage>.success(originalMessage))

                        var editMsgsResult: InboxMessage?
                        var editErrorResult: Error?
                        vibes.expireInboxMessage(messageUID: "msgId") { message, error in
                            editMsgsResult = message
                            editErrorResult = error
                        }

                        expect(editMsgsResult).toEventually(equal(originalMessage))
                        expect(editErrorResult).toEventually(beNil())
                    }
                } // without saved person
            } // expireInboxMessage
        } // with credentials
    } // spec
} // class

extension Date {
    func adding(seconds: Int) -> Date {
        return Calendar.current.date(byAdding: .second, value: seconds, to: self)!
    }
}
