import Foundation
import Quick
import Nimble
@testable import VibesPush

class AppObserverSpec: QuickSpec {
  override func spec() {
    describe("application launch") {
      let observer: AppObserver = AppObserver()
      var eventTracker: StubEventTracker!

      beforeEach {
        eventTracker = StubEventTracker()
        observer.eventTracker = eventTracker
      }

      context("not from remote notification") {
        it("tracks only a launch") {
          observer.applicationDidFinishLaunching(Notification(name: .UIApplicationDidFinishLaunching))

          let event = eventTracker.events.first
          expect(event?.type).to(equal("launch"))
        }
      }

      context("from remote notification") {
        it("tracks a launch and a clickthru") {
          let userInfo = [
            UIApplicationLaunchOptionsKey.remoteNotification: [
              "client_app_data": [
                "client_message_uid": "id-1234",
              ],
            ],
          ]
          let notification = Notification(name: .UIApplicationDidFinishLaunching, object: nil, userInfo: userInfo)
          observer.applicationDidFinishLaunching(notification)

          let launchEvent = eventTracker.events.first
          expect(launchEvent?.type).to(equal("launch"))

          let clickthruEvent = eventTracker.events.last
          expect(clickthruEvent?.type).to(equal("clickthru"))
          expect(clickthruEvent?.properties["client_message_uid"] as? String).to(equal("id-1234"))
        }
      }
    }

    describe("#applicationWillEnterForeground") {
      let observer: AppObserver = AppObserver()
      var eventTracker: StubEventTracker!

      beforeEach {
        eventTracker = StubEventTracker()
        observer.eventTracker = eventTracker
      }

      it("clears the last stored notification and timestamp") {
        observer.lastNotification = (userInfo: [:], timestamp: Date())
        observer.applicationWillEnterForeground(Notification(name: .UIApplicationWillEnterForeground))
        expect(observer.lastNotification).to(beNil())
      }

      it("tracks a launch") {
        observer.applicationWillEnterForeground(Notification(name: .UIApplicationWillEnterForeground))

        let event = eventTracker.events.first
        expect(event?.type).to(equal("launch"))
      }
    }

    describe("#applicationDidBecomeActive") {
      let observer: AppObserver = AppObserver()
      var eventTracker: StubEventTracker!

      beforeEach {
        eventTracker = StubEventTracker()
        observer.eventTracker = eventTracker
      }

      context("with no last notification") {
        it("doesn't track anything") {
          observer.applicationDidBecomeActive(Notification(name: .UIApplicationDidBecomeActive))
          expect(eventTracker.events).to(beEmpty())
        }
      }

      context("with recent last notification") {
        it("tracks a clickthru") {
          observer.lastNotification = (userInfo: ["client_app_data": ["client_message_uid": "id-1234"]], timestamp: Date())

          observer.applicationDidBecomeActive(Notification(name: .UIApplicationDidBecomeActive))

          let event = eventTracker.events.first
          expect(event?.type).to(equal("clickthru"))
          expect(event?.properties["client_message_uid"] as? String).to(equal("id-1234"))
        }
      }

      context("with old last notification") {
        it("doesn't track anything") {
          observer.lastNotification = (userInfo: [:], timestamp: Date(timeIntervalSince1970: 0))

          observer.applicationDidBecomeActive(Notification(name: .UIApplicationDidBecomeActive))

          expect(eventTracker.events).to(beEmpty())
        }
      }
    }
  }
}
