import Foundation


public enum Environment {
    case local
    case staging
    case production
    
    var baseURL: URL {
        switch self {
        case .local:
            return URL(string: "https://jsonplaceholder.typicode.com")!
        case .staging:
            return URL(string: "https://jsonplaceholder.typicode.com")!
        case .production:
            return URL(string: "https://jsonplaceholder.typicode.com")!
        }
    }
}

protocol APIEndpointProtocol {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var body: [String: Any]? { get }
}

enum APIEndpoint: APIEndpointProtocol {
    case getRefreshToken
    case getUsers
    case getUser(id: Int)
    case createUser(name: String, email: String)
    case updateUser(id: Int, name: String, email: String)
    case deleteUser(id: Int)
    
    var baseURL: URL {
        Environment.local.baseURL
    }
    
    var path: String {
        switch self {
        case .getRefreshToken:
            return "refreshToken"
        case .getUsers:
            return "/users"
        case .getUser(let id):
            return "/users/\(id)"
        case .createUser:
            return "/users"
        case .updateUser(let id, _, _):
            return "/users/\(id)"
        case .deleteUser(let id):
            return "/users/\(id)"
        
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getUsers, .getUser, .getRefreshToken:
            return .get
        case .createUser:
            return .post
        case .updateUser:
            return .put
        case .deleteUser:
            return .delete
        }
    }
    
    var headers: [String: String] {
        [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
    
    var body: [String: Any]? {
        switch self {
        case .createUser(let name, let email):
            return ["name": name, "email": email]
        case .updateUser(_, let name, let email):
            return ["name": name, "email": email]
        default:
            return nil
        }
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}
