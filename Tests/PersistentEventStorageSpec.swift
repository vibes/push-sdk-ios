import Foundation
import Nimble
import Quick
@testable import VibesPush

class PersistentEventStorageSpec: QuickSpec {
    override func spec() {
        describe("#tracking") {
            let storage = StubStorage()
            let eventStorage = PersistentEventStorage(storage: storage)
            let newEvent = Event(eventType: .launch, properties: ["new": "event"])

            context("with empty storage") {
                context("when successful") {
                    it("tracks the event and removes it from local storage") {
                        eventStorage.tracking(events: [newEvent]) { _, completion in
                            completion(VibesResult<Void>.success(()))
                        }

                        expect(eventStorage.storedEvents).toEventually(beEmpty())
                    }

                    it("tracks the event after removing any duplicate") {
                        eventStorage.tracking(events: [newEvent, newEvent]) { outgoing, completion in
                            expect(outgoing).toEventually(equal([newEvent])) // this is to check duplicates were removed
                            completion(VibesResult<Void>.success(()))
                        }

                        expect(eventStorage.storedEvents).toEventually(beEmpty())
                    }
                }

                context("on failure") {
                    it("tracks the event and leaves the event in local storage") {
                        eventStorage.tracking(events: [newEvent]) { _, completion in
                            completion(VibesResult<Void>.failure(.other("fail")))
                        }

                        expect(eventStorage.storedEvents).toEventually(equal([newEvent]))
                    }
                }
            }

            context("with other items in storage") {
                let existingLaunchEvent = Event(eventType: .launch, properties: ["existing": "launch"])
                let existingClickthruEvent = Event(eventType: .clickthru, properties: ["existing": "clickthru"])

                beforeEach {
                    eventStorage.storedEvents = [existingLaunchEvent, existingClickthruEvent]
                }

                context("when successful") {
                    it("removes all the events of its type from local storage") {
                        eventStorage.tracking(events: [newEvent]) { _, completion in
                            completion(VibesResult<Void>.success(()))
                        }

                        expect(eventStorage.storedEvents).toEventually(equal([existingClickthruEvent]))
                    }
                }

                context("on failure") {
                    it("leaves all the events in local storage") {
                        eventStorage.tracking(events: [newEvent]) { _, completion in
                            completion(VibesResult<Void>.failure(.other("fail")))
                        }

                        let expectedEvents = [existingLaunchEvent, existingClickthruEvent, newEvent]
                        expect(eventStorage.storedEvents).toEventually(equal(expectedEvents))
                    }
                }
            }
        }
    }
}
