import Foundation
/// A data structure to hold the `HTTPResource` defintions for the Vibes API.
///
/// A caseless enum is used in order to provide a namespace without allowing the
/// possibility of accidentally instantiating an instance of this Type.
enum APIDefinition {
    /// A resource for registering a device with Vibes.
    ///
    /// - parameters:
    ///   - appId: a unique ID, provided by Vibes, that identifies the account
    ///   - device: a `DeviceType` object with relevant device information to
    ///     record with Vibes
    /// - Returns: The HttpResource
    static func registerDevice(appId: String, device: DeviceType) -> HTTPResource<VibesCredential> {
        return jsonResource(
            path: "/\(appId)/devices",
            method: .POST,
            requestParameters: device.encodeJSON(),
            parse: VibesCredential.init
        )
    }

    /// A resource for updating a device with Vibes. This is used to renew
    /// authentication tokens.
    ///
    /// - parameters:
    ///   - appId: a unique ID, provided by Vibes, that identifies the account
    ///   - deviceId: the vibes device id that uniquely identifies the device to
    ///     unregister
    ///   - device: a `DeviceType` object with relevant device information to
    ///     record with Vibes
    /// - Returns: The HttpResource
    static func updateDevice(appId: String, deviceId: String, device: DeviceType) -> HTTPResource<VibesCredential> {
        return jsonResource(
            path: "/\(appId)/devices/\(deviceId)",
            method: .PUT,
            requestParameters: device.encodeJSON(),
            parse: VibesCredential.init
        )
    }

    /// A resource for obtaining person information at Vibes. This is used to
    /// retrieve person information.
    ///
    /// - parameters:
    ///   - appId: a unique ID, provided by Vibes, that identifies the account
    ///   - deviceId: the vibes device id that uniquely identifies the device to
    ///     unregister
    /// - Returns: The HttpResource
    static func getPerson(appId: String, deviceId: String) -> HTTPResource<Person> {
        return jsonResource(
            path: "/\(appId)/devices/\(deviceId)/person",
            method: .GET,
            requestParameters: VibesJSONArray(),
            parse: Person.init
        )
    }

    /// A resource for updating a device with Vibes. This is used to save
    /// the device location.
    ///
    /// - parameters:
    ///   - appId: a unique ID, provided by Vibes, that identifies the account
    ///   - deviceId: the vibes device id that uniquely identifies the device to
    ///     unregister
    ///   - device: a `DeviceType` object with relevant device information to
    ///     record with Vibes
    /// - Returns: The HttpResource
  static func updateDeviceInfoPut(appId: String, deviceId: String, device: DeviceType) -> HTTPResource<VibesCredential> {
      return jsonResource(
        path: "/\(appId)/devices/\(deviceId)",
        method: .PUT,
        requestParameters: device.encodeJSON(),
        parse: VibesCredential.init
      )
  }

  /// A resource for updating a device with Vibes. This is used to save
  /// the device location.
  ///
  /// - parameters:
  ///   - appId: a unique ID, provided by Vibes, that identifies the account
  ///   - deviceId: the vibes device id that uniquely identifies the device to
  ///     unregister
  ///   - device: a `DeviceType` object with relevant device information to
  ///     record with Vibes
  /// - Returns: The HttpResource
  static func updateDeviceInfoPatch(appId: String, deviceId: String, device: DeviceType) -> HTTPResource<Void> {
    return jsonResource(
      path: "/\(appId)/devices/\(deviceId)",
      method: .PATCH,
      requestParameters: device.encodeJSON(),
      parse: noResult
    )
  }

    /// A resource for associating a device with an external person
    ///
    /// - parameters:
    ///   - appId: a unique ID, provided by Vibes, that identifies the account
    ///   - deviceId: the vibes device id that uniquely identifies the device to associate
    ///   - externalPersonId: a string representation of the person identifier used by third parties,
    ///     stored by Vibes as `external_person_id`
    /// - Returns: The HttpResource
    static func associatePerson(appId: String, deviceId: String, externalPersonId: String) -> HTTPResource<Void> {
        let personData = ["external_person_id": externalPersonId as AnyObject]
        return jsonResource(
            path: "/\(appId)/devices/\(deviceId)/assign",
            method: .POST,
            requestParameters: personData as VibesJSONDictionary,
            parse: noResult
        )
    }

    /// A resource for unregistering a device with Vibes.
    ///
    /// - parameters:
    ///   - appId: a unique ID, provided by Vibes, that identifies the account
    ///   - deviceId: the vibes device id that uniquely identifies the device to
    ///     unregister
    /// - Returns: The HttpResource
    static func unregisterDevice(appId: String, deviceId: String) -> HTTPResource<Void> {
        return HTTPResource(
            path: "/\(appId)/devices/\(deviceId)",
            method: .DELETE,
            parse: noResult
        )
    }

    /// A resource for registering this device for push notifications from Vibes.
    ///
    /// - parameters:
    ///   - appId: a unique ID, provided by Vibes, that identifies the account
    ///   - deviceId: the vibes device id that uniquely identifies the device to
    ///     unregister
    ///   - pushToken: a unique token, provided by Apple, that identifies the
    ///     device
    /// - Returns: The HttpResource
    static func registerPush(appId: String, deviceId: String, pushToken: String) -> HTTPResource<Void> {
        let deviceToken = DeviceToken(token: pushToken)
        return jsonResource(
            path: "/\(appId)/devices/\(deviceId)/push_registration",
            method: .POST,
            requestParameters: deviceToken.encodeJSON(),
            parse: noResult
        )
    }

    /// A resource for unregistering this device for push notifications from Vibes.
    ///
    /// - parameters:
    ///   - appId: a unique ID, provided by Vibes, that identifies the account
    ///   - deviceId: the vibes device id that uniquely identifies the device to
    ///     unregister
    /// - Returns: The HttpResource
    static func unregisterPush(appId: String, deviceId: String) -> HTTPResource<Void> {
        return HTTPResource(
            path: "/\(appId)/devices/\(deviceId)/push_registration",
            method: .DELETE,
            parse: noResult
        )
    }

    /// A resource for tracking events with Vibes.
    ///
    /// - parameters:
    ///   - appId: a unique ID, provided by Vibes, that identifies the account
    ///   - deviceId: the vibes device id that uniquely identifies this device
    ///   - events: the events to track
    /// - Returns: The HttpResource
    static func trackEvents(appId: String, deviceId: String, events: [Event]) -> HTTPResource<Void> {
        let params: VibesJSONDictionary = [
            "events": events.map { $0.encodeJSON() } as AnyObject,
        ]

        return jsonResource(
            path: "/\(appId)/devices/\(deviceId)/events",
            method: .POST,
            requestParameters: params,
            headers: ["X-Event-Type": events.first?.type ?? "event"],
            parse: noResult
        )
    }

    /// A resource for retrieving Git Tags
    ///
    /// - Returns: The HttpResource
    static func getGitTags() -> HTTPResource<[GitTag]> {
        var resource: HTTPResource<[GitTag]> = jsonResources(
            path: "/tags",
            method: .GET,
            requestParameters: VibesJSONDictionary(),
            headers: ["Accept": "application/vnd.github.v3+json"],
            parse: fromJSONArray
        )
        resource.baseURL = URL(string: "https://api.github.com/repos/vibes/push-sdk-ios")
        return resource
    }

    /// A resource for retrieving a single  inbox message
    ///
    /// - Parameters:
    ///     - appId: a unique ID, provided by Vibes, that identifies the account
    ///     - personKey: The Alhphanumeric person key
    ///     - messageUID: The Alhphanumeric message UID
    /// - Returns: The HttpResource
  static func getInboxMessage(appId: String, personKey: String, messageUID: String) -> HTTPResource<InboxMessage> {
        return jsonResource(
            path: "/\(appId)/persons/\(personKey)/messages/\(messageUID)",
            method: .GET,
            requestParameters: VibesJSONDictionary(),
            parse: InboxMessage.init
        )
    }

    /// A resource for retrieving inbox messages
    ///
    /// - Parameters:
    ///     - appId: a unique ID, provided by Vibes, that identifies the account
    ///     - personKey: The Alhphanumeric person key
    /// - Returns: The HttpResource
    static func getInboxMessages(appId: String, personKey: String) -> HTTPResource<[InboxMessage]> {
        return jsonResources(
            path: "/\(appId)/persons/\(personKey)/messages",
            method: .GET,
            requestParameters: VibesJSONDictionary(),
            parse: fromJSONArray
        )
    }

    /// A resource for updating inbox messages
    ///
    /// - Parameters:
    ///   - appId: a unique ID, provided by Vibes, that identifies the account
    ///   - personKey: The Alhphanumeric person key
    ///   - messageUID: The Alhphanumeric messge UID
    /// - Returns: The HttpResource
    static func updateMessage(appId: String, personKey: String, messageUID: String, payload: VibesJSONDictionary) -> HTTPResource<InboxMessage> {
        return jsonResource(
            path: "/\(appId)/persons/\(personKey)/messages/\(messageUID)",
            method: .PUT,
            requestParameters: payload,
            parse: InboxMessage.init
        )
    }

  static func fetchVibesAppInfo(appId: String) -> HTTPResource<VibesAppInfo> {
      return jsonResource(
          path: "/\(appId)",
          method: .GET,
          requestParameters: VibesJSONDictionary(),
          parse: VibesAppInfo.init
      )
  }

  /// A resource to triggers silent push migration callback
  ///
  /// - Parameters:
  ///   - appId: a unique ID, provided by Vibes, that identifies the account
  ///   - migrationItemId: The migration item Id
  ///   - vibesDeviceId: Vibes Device Id
  ///
  /// - Returns: The HttpResource
  static func migrationCallback(appId: String, migrationItemId: String, vibesDeviceId: String) -> HTTPResource<Void> {
    let payload: VibesJSONDictionary = [
      "migration_item_id": migrationItemId as AnyObject,
      "vibes_device_id": vibesDeviceId as AnyObject,
    ]
      return jsonResource(
          path: "/\(appId)/migrations/callbacks",
          method: .PUT,
          requestParameters: payload,
          parse: noResult
      )
  }

    /// A generic utility function for creating an `HTTPResource` that expects to
    /// send and receive JSON.
    ///
    /// - parameters:
    ///   - path: the path for this resource, e.g. "/devices"
    ///   - method: the HTTP method for this resource, e.g. .DELETE
    ///   - requestParameters: the JSON object to send with this request
    ///   - headers: an optional list of headers for the resource. `Content-Type`
    ///     and `Accept` headers will automatically be added in.
    ///   - parse: a closure that dictates how to map the received JSON (not Data)
    ///     into an instance of `A`.
    private static func jsonResource<A>(path: String,
                                        method: HTTPMethod,
                                        requestParameters: VibesJSONDictionary = [:],
                                        headers: [String: String] = [:],
                                        parse: @escaping (VibesJSONDictionary) -> A?) -> HTTPResource<A> {
        let parser = JSONParser()
        let jsonBody = parser.encode(requestParameters)

        return commonJsonResource(path: path, method: method, jsonBody: jsonBody, headers: headers, parse: parse)
    }

    /// A generic utility function for creating an `HTTPResource` that expects to
    /// send and receive JSON.
    ///
    /// - parameters:
    ///   - path: the path for this resource, e.g. "/devices"
    ///   - method: the HTTP method for this resource, e.g. .DELETE
    ///   - requestParameters: the JSON object to send with this request
    ///   - headers: an optional list of headers for the resource. `Content-Type`
    ///     and `Accept` headers will automatically be added in.
    ///   - parse: a closure that dictates how to map the received JSON (not Data)
    ///     into an instance of `[A]`.
    private static func jsonResources<A>(path: String,
                                         method: HTTPMethod,
                                         requestParameters: VibesJSONDictionary = [:],
                                         headers: [String: String] = [:],
                                         parse: @escaping (VibesJSONArray) -> [A]) -> HTTPResource<[A]> {
        let parser = JSONParser()
        let jsonBody = parser.encode(requestParameters)

        return commonJsonResources(path: path, method: method, jsonBody: jsonBody, headers: headers, parse: parse)
    }

    /// A generic utility function for creating an `HTTPResource` that expects to
    /// send and receive JSON.
    ///
    /// - parameters:
    ///   - path: the path for this resource, e.g. "/devices"
    ///   - method: the HTTP method for this resource, e.g. .DELETE
    ///   - requestParameters: the JSON array to send with this request
    ///   - headers: an optional list of headers for the resource. `Content-Type`
    ///     and `Accept` headers will automatically be added in.
    ///   - parse: a closure that dictates how to map the received JSON (not Data)
    ///     into an instance of `A`.
    private static func jsonResource<A>(path: String,
                                        method: HTTPMethod,
                                        requestParameters: VibesJSONArray = [],
                                        headers: [String: String] = [:],
                                        parse: @escaping (VibesJSONDictionary) -> A?) -> HTTPResource<A> {
        let parser = JSONParser()
        let jsonBody = parser.encode(requestParameters)
        return commonJsonResource(path: path, method: method, jsonBody: jsonBody, headers: headers, parse: parse)
    }

    /// A generic helper for creating an `HTTPResource` that expects to send and
    /// receive JSON.
    ///
    /// - parameters:
    ///   - path: the path for this resource, e.g. "/devices"
    ///   - method: the HTTP method for this resource, e.g. .DELETE
    ///   - jsonBody: JSON, encoded as Data
    ///   - headers: an optional list of headers for the resource. `Content-Type`
    ///     and `Accept` headers will automatically be added in.
    ///   - parse: a closure that dictates how to map the received JSON (not Data)
    ///     into an instance of `A`.
    private static func commonJsonResource<A>(path: String,
                                              method: HTTPMethod,
                                              jsonBody: Data?,
                                              headers: [String: String] = [:],
                                              parse: @escaping (VibesJSONDictionary) -> A?) -> HTTPResource<A> {
        let parser = JSONParser()

        // Creates a function that parses `Data` into a `JSONDictionary`, and then
        // passes that dictionary on to the custom `parse` function to create an
        // instance of our `A` type
        let parseWrapper: (Data) -> A? = { data in
            guard let dict = parser.decode(data: data) else { return nil }
            return parse(dict)
        }

        let headers = headers.merged(with: ["Content-Type": "application/json", "Accept": "application/json"])

        return HTTPResource(path: path, method: method, requestBody: jsonBody, headers: headers, parse: parseWrapper)
    }

    /// A generic helper for creating an `HTTPResource` that expects to send and
    /// receive JSON.
    ///
    /// - parameters:
    ///   - path: the path for this resource, e.g. "/devices"
    ///   - method: the HTTP method for this resource, e.g. .DELETE
    ///   - jsonBody: JSON, encoded as Data
    ///   - headers: an optional list of headers for the resource. `Content-Type`
    ///     and `Accept` headers will automatically be added in.
    ///   - parse: a closure that dictates how to map the received JSON (not Data)
    ///     into an instance of `[A]`.
    private static func commonJsonResources<A>(path: String,
                                               method: HTTPMethod,
                                               jsonBody: Data?,
                                               headers: [String: String] = [:],
                                               parse: @escaping (VibesJSONArray) -> [A]) -> HTTPResource<[A]> {
        let parser = JSONParser()

        // Creates a function that parses `Data` into a `JSONArray`, and then
        // passes that dictionary on to the custom `parse` function to create an
        // instance of our `[A]` type
        let parseWrapper: (Data) -> [A]? = { data in
            guard let array = parser.decodeJSONArray(data: data) else { return nil }
            return parse(array)
        }

        let headers = headers.merged(with: ["Content-Type": "application/json", "Accept": "application/json"])

        return HTTPResource(path: path, method: method, requestBody: jsonBody, headers: headers, parse: parseWrapper)
    }

    /// A helper function for when there is no expected response data.
    private static func noResult(data: Data) {
        return
    }

    /// A helper function for when there is no expected response JSON.
    private static func noResult(json: VibesJSONDictionary) {
        return
    }

    /// A convenience initializer for decoding a JSONArray into their Array Types.
    ///
    /// - parameters:
    ///   - jsonArray: the JSON Array to encode into data
    private static func fromJSONArray<T: JSONDecodable>(jsonArray: VibesJSONArray) -> [T] {
        var result: [T] = [T]()
        for json in jsonArray {
            if let object = T(json: json) {
                result.append(object)
            }
        }
        return result
    }
}
