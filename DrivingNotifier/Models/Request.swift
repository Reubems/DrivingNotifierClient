import Foundation

struct Request: Decodable {
    let id: ObjectId?
    let requestorUsername: String?
    let requestorEmail: String?
    let replierEmail: String?
    let state: Int?
}
