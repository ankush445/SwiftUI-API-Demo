import Foundation


public enum AppEnvironment {
    case local
    case staging
    case production
    
    var baseURL: URL {
        switch self {
        case .local:
            return URL(string: "http://localhost:3000/api")!
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
    var queryItems: [URLQueryItem]? { get }
}

enum APIEndpoint: APIEndpointProtocol {
    
    // Auth
    case getRefreshToken
    case signUp(name: String, email: String, password: String)
    case login(email: String, password: String)
    case logout
    case delete
    
    // Post
    case getFeed(cursor: String?, search: String?, limit: Int)
    case createPost(title: String, content: String?)
    case postLike(id: String)
    case addComment(postId: String, text: String)
    case getComment(postId: String)


    
    
    var baseURL: URL {
        AppEnvironment.local.baseURL
    }
    
    var path: String {
        switch self {
        case .getRefreshToken:
            return "/users/refresh-token"
        case .signUp:
            return "/users/signup"
        case .login:
            return "/users/login"
        case .delete:
            return "/users/delete"
        case .logout:
            return "/users/logout"
            
           // POST
        case .getFeed:
            return "/posts/feed"
        case .createPost:
            return "/posts/create-post"
    
        case .postLike(let id):
            return "/likes/\(id)"
        case .addComment:
            return "/comments/add-comment"
        case .getComment(let postId):
            return "/comments/\(postId)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getFeed,.getComment:
            return .get
        case .signUp ,.login,.getRefreshToken, .logout, .createPost,.postLike, .addComment:
            return .post
        case .delete:
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
        case .signUp(let name, let email, let password):
            return ["name": name, "email": email, "password": password]
        case .login( let email, let password):
            return ["email": email, "password": password]
        case .getRefreshToken:
            return [:]
        case .createPost(let title, let content):
            return ["title":title, "content": content ?? ""]
        case .addComment(let postId, let text):
            return ["postId": postId, "text": text]
        default:
            return nil
        }
    }
    var queryItems: [URLQueryItem]? {
        switch self {
        case .getFeed(let cursor, let search, let limit):
            var items: [URLQueryItem] = []
            if let cursor = cursor {
                items.append(URLQueryItem(name: "cursor", value: cursor))
            }
            if let query = search, !query.isEmpty {
                items.append(URLQueryItem(name: "search", value: search))
            }
            items.append(URLQueryItem(name: "limit", value: "\(limit)"))

            
            return items
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
