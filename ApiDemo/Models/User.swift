import Foundation

struct User: Codable, Identifiable {
    let id: Int
    let name: String
    let email: String
    let phone: String?
    let website: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, email, phone, website
    }
}
