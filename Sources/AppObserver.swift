import UIKit

extension String {
    func toDictionary() -> [String: Any]? {
        if let data = data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                Vibes.shared.configuration.logger?.log(error: error)
            }
        }
        return nil
    }
}

/// Observes app lifecycle events and tracks events.
class AppObserver: NSObject {
    /// A list of the events that should be tracked
    private let trackedEventTypes: [TrackedEventType]

    /// The event tracker that should be used to track events (usally a Vibes
    /// instance)
    weak var eventTracker: EventTracker?

    /// The user info and date of the last notification that was received.[
    var lastNotification: (userInfo: [AnyHashable: Any], timestamp: Date)? {
        didSet  {
            if let userInfo = lastNotification?.userInfo, shouldTrackPushReceive() {
                trackPushReceive(with: userInfo)
            }
        }
    }

    /// The threshold of time between receiving a notification and the app
    /// becoming active that we should consider a "clickthru"
    private let clickthruThreshold: TimeInterval // seconds

    /// Initialize this object.
    ///
    /// - parameters:
    ///   - trackedEventTypes: the type of events that should be tracked
    ///     (default: all)
    ///   - clickthruThreshold - the threshold of time between receiving a
    ///     notification and the app becoming active that we should consider
    ///     a "clickthru" (default: 1 second)
    init(trackedEventTypes: [TrackedEventType] = TrackedEventType.all, clickthruThreshold: TimeInterval = 1) {
        self.clickthruThreshold = clickthruThreshold
        self.trackedEventTypes = trackedEventTypes

        super.init()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    /// Run on deallocation.
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// Tracks when the application became active. If there's a push
    /// notification, this fires after it is received by the AppDelegate.
    ///
    /// - parameters:
    ///   - the notification fired by iOS
    @objc func applicationDidBecomeActive(_ notification: Notification) {
        if trackedEventTypes.contains(.launch) {
            trackLaunch()
        }

        if let (userInfo, _) = lastNotification, shouldTrackClickThru() {
            trackClickthru(with: userInfo)
        }
        lastNotification = nil
    }

    /// Determines if a clickthru should be tracked, based on the user vibes configuration
    private func shouldTrackClickThru() -> Bool {
        return trackedEventTypes.contains(.clickthru)
    }

    /// Determines if a .pushReceive should be tracked, based on the user vibes configuration
    private func shouldTrackPushReceive() -> Bool {
        return trackedEventTypes.contains(.pushReceive)
    }

    /// Tracks a launch event.
    private func trackLaunch() {
        let event = Event(eventType: .launch, properties: [:])
        eventTracker?.track(event: event)
    }

    func eventProps(with userInfo: [AnyHashable: Any]) ->  [AnyHashable: Any] {
        var properties: [AnyHashable: Any] = [:]

        if let messageUniqueId = userInfo["message_uid"] as? String {
            properties["message_uid"] = messageUniqueId
        }

        if let clientAppData = userInfo["client_app_data"] as? [AnyHashable: Any] {
            if let activityType = clientAppData["activity_type"] as? String {
                properties["activity_type"] = activityType
            }

            if let activityUid = clientAppData["activity_uid"] as? String {
                properties["activity_uid"] = activityUid
            }
        }
        
        return properties

    }
    
    /// Tracks a clickthru event.
    ///
    /// - parameters:
    ///   - userInfo: the details from the push notification to track
    private func trackClickthru(with userInfo: [AnyHashable: Any]) {
        var properties: [AnyHashable: Any] = eventProps(with: userInfo)
        let event = Event(eventType: .clickthru, properties: properties)
        eventTracker?.track(event: event)
    }

    /// Tracks a push_receive event.
    ///
    /// - parameters:
    ///   - userInfo: the details from the push notification to track
    private func trackPushReceive(with userInfo: [AnyHashable: Any]) {
        var properties: [AnyHashable: Any] = eventProps(with: userInfo)
        let event = Event(eventType: .pushReceive, properties: properties)
        eventTracker?.track(event: event)
    }
}
