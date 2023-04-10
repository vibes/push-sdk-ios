import Foundation
import Nimble
import Quick
@testable import VibesPush

class APIDefinitionSpec: QuickSpec {
    override func spec() {
        let parser = JSONParser()

        describe("#registerDevice") {
            it("creates a resource") {
                let device = StubDevice()
                let resource = APIDefinition.registerDevice(appId: "app-ID", device: device)
                expect(resource.path).to(equal("/app-ID/devices"))
                expect(resource.method.rawValue).to(equal("POST"))
                expect(((resource.requestBody?.asDict())!) == (parser.encode(device)?.asDict())!).to(equal(true))
            }
        }

        describe("#getPerson") {
            it("creates a resource") {
                let deviceId = "test"
                let resource = APIDefinition.getPerson(appId: "app-ID", deviceId: deviceId)
                expect(resource.path).to(equal("/app-ID/devices/test/person"))
                expect(resource.method.rawValue).to(equal("GET"))
            }
        }

        describe("#updateDeviceInfoPut") {
            it("creates a resource") {
                let device = StubDevice()
                let resource = APIDefinition.updateDeviceInfoPut(appId: "app-ID", deviceId: "device-id", device: device)
                expect(resource.path).to(equal("/app-ID/devices/device-id"))
                expect(resource.method.rawValue).to(equal("PUT"))
                expect(((resource.requestBody?.asDict())!) == (parser.encode(device)?.asDict())!).to(equal(true))
            }
        }
        
        describe("#updateDeviceInfoPatch") {
            it("creates a resource") {
                let device = StubDevice()
                let resource = APIDefinition.updateDeviceInfoPatch(appId: "app-ID", deviceId: "device-id", device: device)
                expect(resource.path).to(equal("/app-ID/devices/device-id"))
                expect(resource.method.rawValue).to(equal("PATCH"))
                expect(((resource.requestBody?.asDict())!) == (parser.encode(device)?.asDict())!).to(equal(true))
            }
        }

        describe("#associatePerson") {
            it("creates an HTTPResource for associating devices") {
                let resource = APIDefinition.associatePerson(appId: "app-ID", deviceId: "device-id", externalPersonId: "external-person-id")
                expect(resource.path).to(equal("/app-ID/devices/device-id/assign"))
                expect(resource.method.rawValue).to(equal("POST"))
                expect(resource.requestBody).to(equal(parser.encode(["external_person_id": "external-person-id"] as VibesJSONDictionary)))
            }
        }

        describe("unregisterDevice") {
            it("creates a resource") {
                let resource = APIDefinition.unregisterDevice(appId: "app-ID", deviceId: "device-id")
                expect(resource.path).to(equal("/app-ID/devices/device-id"))
                expect(resource.method.rawValue).to(equal("DELETE"))
                expect(resource.requestBody).to(beNil())
            }
        }

        describe("registerPush") {
            it("creates a resource") {
                let deviceToken = DeviceToken(token: "a-token")
                let resource = APIDefinition.registerPush(
                    appId: "app-ID",
                    deviceId: "device-id",
                    pushToken: deviceToken.token
                )
                expect(resource.path).to(equal("/app-ID/devices/device-id/push_registration"))
                expect(resource.method.rawValue).to(equal("POST"))
                expect(resource.requestBody).to(equal(parser.encode(deviceToken)))
            }
        }

        describe("unregisterPush") {
            it("creates a resource") {
                let resource = APIDefinition.unregisterPush(appId: "app-ID", deviceId: "device-id")
                expect(resource.path).to(equal("/app-ID/devices/device-id/push_registration"))
                expect(resource.method.rawValue).to(equal("DELETE"))
                expect(resource.requestBody).to(beNil())
            }
        }

        describe("trackEvents") {
            it("creates a resource") {
                let event = Event(eventType: .launch, properties: [:])
                let resource = APIDefinition.trackEvents(appId: "app-ID", deviceId: "device-id", events: [event])

                expect(resource.path).to(equal("/app-ID/devices/device-id/events"))
                expect(resource.method.rawValue).to(equal("POST"))
                expect(resource.headers["X-Event-Type"]).to(equal("launch"))
            }
        }

        describe("#getInboxMessages") {
            it("creates a resource") {
                let personKey = "test"
                let resource = APIDefinition.getInboxMessages(appId: "app-ID", personKey: personKey)
                expect(resource.path).to(equal("/app-ID/persons/test/messages"))
                expect(resource.method.rawValue).to(equal("GET"))
            }
        }

        describe("#updateMessage") {
            it("creates a resource") {
                let appId = "testAppId"
                let personKey = "test"
                let messageUID = "testMessageUID"
                let resource = APIDefinition.updateMessage(appId: appId, personKey: personKey, messageUID: messageUID, payload: ["some_bool": true as AnyObject, "some_string": "value" as AnyObject])
                expect(resource.path).to(equal("/testAppId/persons/test/messages/testMessageUID"))
                expect(resource.requestBody?.asDict() ?? [:] == ["some_bool": true, "some_string": "value"]).to(equal(true))
                expect(resource.method.rawValue).to(equal("PUT"))
            }
        }

        describe("#getInboxMessage") {
            it("creates a resource") {
                let appId = "testAppId"
                let personKey = "test"
                let messageUID = "testMessageUID"
                let resource = APIDefinition.getInboxMessage(appId: appId, personKey: personKey, messageUID: messageUID)
                expect(resource.path).to(equal("/testAppId/persons/test/messages/testMessageUID"))
                expect(resource.method.rawValue).to(equal("GET"))
            }
        }

        describe("#migrationCallback") {
            it("creates an HTTPResource for migration callback") {
                let resource = APIDefinition.migrationCallback(appId: "app-ID", migrationItemId: "migration-Item-ID", vibesDeviceId: "Vibes-Device-ID")
                expect(resource.path).to(equal("/app-ID/migrations/callbacks"))
                expect(resource.method.rawValue).to(equal("PUT"))
                if let dict = resource.requestBody?.toString().toJSON() as? VibesJSONDictionary {
                    expect(dict["migration_item_id"] as? String).to(equal("migration-Item-ID"))
                    expect(dict["vibes_device_id"] as? String).to(equal("Vibes-Device-ID"))
                }

            }
        }
        
        describe("#trackProductAction") {
            it("creates a resource") {
                let id = "product-id"
                let activityUID = "my-activity-uid"
                let product = Product(id: id, price: 20.0, name: "test-product", brand: "test brand", category: "test", variant: "", quantity: "", coupon: "", position:"")
                let trackingData = [
                    "person_key":  "person-1",
                    "company_key": "sjksi229"
                ] as VibesJSONDictionary
                Vibes.configure(appId: "app-id")
                let resource = APIDefinition.trackProductAction(action: .click, product: product, data: trackingData, activityUid: activityUID)
                expect(resource.method.rawValue).to(equal("GET"))
            }
        }
        
        describe("#trackPurchaseAction") {
            it("creates a resource") {
                let id = "purchase-id"
                let activityUID = "my-activity-uid"
                //(id: id, price: 20.0, name: "test-product", brand: "test brand", category: "test", variant: "", quantity: "", coupon: "", position:"")
                let purchase = Purchase(id: id,
                                        affiliation: "test-affiliation",
                                        revenue: 1.0,
                                        tax: 2.0,
                                        shipping: 4.0,
                                        coupon: 3.0,
                                        list: "Test-list",
                                        step: "test-step",
                                        option: "test-option",
                                        products: [])
                let trackingData = [
                    "person_key":  "person-1",
                    "company_key": "sjksi229"
                ] as VibesJSONDictionary
                Vibes.configure(appId: "app-id")
                let resource = APIDefinition.trackPurchaseAction(action: .purchase,
                                                                 purchase: purchase,
                                                                 data: trackingData,
                                                                 activityUid: activityUID)
                expect(resource.method.rawValue).to(equal("GET"))
            }
        }
    }
}
