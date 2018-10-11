import Foundation

struct User: Decodable {
    let id: ObjectId?
    let fullName: String?
    let email: String?
    let trackingEnabled: Bool?
    let mute: Bool?
    let driving: Bool?
    let lastUpdate: String?
    let contacts: [ObjectId]?
}

struct Session {
    static var email: String?
    static var trackingEnabled: Bool?
    static var mute: Bool?
    static var driving: Bool?
}
