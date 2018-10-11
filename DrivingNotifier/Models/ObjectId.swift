import Foundation

struct ObjectId: Decodable {
    let timestamp: Int?
    let machine: Int?
    let pid: Int?
    let increment: Int?
    let creationTime: String?
}
