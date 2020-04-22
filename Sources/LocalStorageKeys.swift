/// Type-safe local storage used by Vibes; these static instances encapsulate
/// the key used to store some data in local storage, along with encoding the
/// expected type information that should be returned.
enum LocalStorageKeys {
    /// The current device's push token
    static let pushToken = LocalValue<String>("VIBES_PUSH_TOKEN")

    /// The current Credential
    static let currentCredential = LocalObject<VibesCredential>("VIBES_CURRENT_CREDENTIAL")

    /// The set of all known Credentials
    static let allCredentials = LocalValue<[String: String]>("VIBES_ALL_CREDENTIALS")

    /// All events that have been stored locally
    static let events = LocalObject<EventCollection>("VIBES_EVENTS")
    
    /// The current Vibes Person
    static let currentPerson = LocalObject<Person>("VIBES_CURRENT_PERSON")
}
