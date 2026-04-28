import Foundation


public enum AppEnvironment {
    case local
    case staging
    case production
    
    var baseURL: URL {
        switch self {
        case .local:
            return URL(string: "http://192.168.1.16:3000/api")!
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
    case checkUsername(userName: String?)
    case signUp(name: String, userName: String, email: String, password: String)
    case login(email: String, password: String)
    case forgotPassword(email: String)
    case resetPassword(token: String, password: String)
    case logout
    case delete
    
    // Post
    case getFeed(cursor: String?, search: String?, limit: Int)
    case getUserPosts(cursor: String?, search: String?, limit: Int, id: String)
    case createPost(title: String, content: String?)
    case postLike(id: String)
    case addComment(postId: String, text: String)
    case addReply(postId: String, parentId: String, text: String)
    case getComment(postId: String, cursor: String?)
    case getRepliesComment(commentId: String, cursor: String?)
    case commentLike(commentId: String)

    // Friends
    case getSuggestUser(cursor: String?, limit: Int)
    case sendFollowRequest(id: String)
    case unfollow(id: String)
    case cancelFollowRequest(id: String)
    case getPendingRequests(cursor: String?, limit: Int)
    case respondPendingRequest(id: String, action: String)
    case searchUser(search: String?, cursor: String?, limit: Int)
    case getUserProfile(id: String, cursor: String?, limit: Int)
    case getFollowers(id: String, search: String?, cursor: String?, limit: Int)
    case getFollowing(id: String, search: String?, cursor: String?, limit: Int)
    case removeFollower(id: String)



    
    
    var baseURL: URL {
        AppEnvironment.local.baseURL
    }
    
    var path: String {
        switch self {
        case.checkUsername:
            return "/users/check-username"
        case .getRefreshToken:
            return "/users/refresh-token"
        case .signUp:
            return "/users/signup"
        case .login:
            return "/users/login"
        case .forgotPassword:
            return "/users/forgot-password"

        case .resetPassword:
            return "/users/reset-password"
        case .delete:
            return "/users/delete"
        case .logout:
            return "/users/logout"
            
           // POST
        case .getFeed:
            return "/posts/feed"
        case .getUserPosts(_,_,_, let id):
            return "posts/user/\(id)"
        case .createPost:
            return "/posts/create-post"
    
        case .postLike(let id):
            return "/likes/\(id)"
        case .addComment:
            return "/comments/add-comment"
        case .addReply:
            return "/comments/add-comment"
        case .getComment(let postId, _):
            return "/comments/\(postId)"
        case .getRepliesComment(let commentId, _):
            return "/comments/\(commentId)/replies"
        case .commentLike(let commentId):
            return "/comments/\(commentId)/like"
           // Friends
            
        case .getSuggestUser:
            return "/users/suggestions"
        case .sendFollowRequest(let id):
            return "/follow/\(id)"
        case .unfollow(id: let id):
            return "/follow/unfollow/\(id)"
        case .cancelFollowRequest(id: let id):
            return "/follow/cancel/\(id)"
        case .getPendingRequests:
            return "/follow/requests"

        case .respondPendingRequest(let id, _):
            return "/follow/respond/\(id)"
        case .searchUser:
            return "/users/search"
            
        case.getUserProfile(let id,_, _):
            return "/users/profile/\(id)"
        case .getFollowers(let id, _, _, _):
            return "/follow/followers/\(id)"
        case .getFollowing(let id, _, _, _):
            return "/follow/following/\(id)"
        case .removeFollower(let id):
            return "/follow/remove-follower/\(id)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getFeed,.getUserPosts,.getComment, .getRepliesComment, .checkUsername, .getSuggestUser, .getPendingRequests, .searchUser, .getUserProfile, .getFollowers, .getFollowing:
            return .get
        case .signUp ,.login,.getRefreshToken, .logout, .createPost,.postLike, .addComment, .addReply, .commentLike, .forgotPassword, .resetPassword, .sendFollowRequest:
            return .post
        case .respondPendingRequest:
            return .put
        case .delete, .unfollow, .cancelFollowRequest, .removeFollower:
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
        case .signUp(let name, let username, let email, let password):
            return ["name": name,"username": username,"email": email, "password": password]
        case .login( let email, let password):
            return ["email": email, "password": password]
            
        case .forgotPassword(let email):
            return ["email": email]
        case .resetPassword(let token, let password):
            return ["token": token, "password": password]
        case .getRefreshToken:
            return [:]
        case .createPost(let title, let content):
            return ["title":title, "content": content ?? ""]
        case .addComment(let postId, let text):
            return ["postId": postId, "text": text]
        case .addReply(let postId,let parentId, let text):
            return ["postId": postId,
                    "text": text,
                    "parentCommentId": parentId
            ]
            
        case .respondPendingRequest(_, let action):
            return ["action": action,
            ]
        default:
            return nil
        }
    }
    var queryItems: [URLQueryItem]? {
        switch self {
        case .checkUsername(let username):
            var items: [URLQueryItem] = []
            if let username = username {
                items.append(URLQueryItem(name: "username", value: username))
            }
            return items
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
        case .getUserPosts(let cursor, let search, let limit, _):
            var items: [URLQueryItem] = []
            if let cursor = cursor {
                items.append(URLQueryItem(name: "cursor", value: cursor))
            }
            if let query = search, !query.isEmpty {
                items.append(URLQueryItem(name: "search", value: search))
            }
            items.append(URLQueryItem(name: "limit", value: "\(limit)"))
            
            return items
        case .getComment(_, let cursor):
            var items: [URLQueryItem] = []
            if let cursor = cursor {
                items.append(URLQueryItem(name: "cursor", value: cursor))
            }
            return items
        case .getRepliesComment(_, let cursor):
            var items: [URLQueryItem] = []
            if let cursor = cursor {
                items.append(URLQueryItem(name: "cursor", value: cursor))
            }
            return items
        case .getSuggestUser(let cursor,let limit):
            var items: [URLQueryItem] = []
            if let cursor = cursor {
                items.append(URLQueryItem(name: "cursor", value: cursor))
            }
            items.append(URLQueryItem(name: "limit", value: "\(limit)"))
            return items
            
            
        case .getPendingRequests(let cursor, let limit):
            var items: [URLQueryItem] = []
            if let cursor = cursor {
                items.append(URLQueryItem(name: "cursor", value: cursor))
            }
            items.append(URLQueryItem(name: "limit", value: "\(limit)"))
            return items
            
        case .searchUser(let search, let cursor, let limit):
            var items: [URLQueryItem] = []
            if let cursor = cursor {
                items.append(URLQueryItem(name: "cursor", value: cursor))
            }
            if let query = search, !query.isEmpty {
                items.append(URLQueryItem(name: "search", value: search))
            }
            items.append(URLQueryItem(name: "limit", value: "\(limit)"))

            
            return items
            
        case .getUserProfile(_, let cursor, let limit):
            var items: [URLQueryItem] = []
            if let cursor = cursor {
                items.append(URLQueryItem(name: "cursor", value: cursor))
            }
            items.append(URLQueryItem(name: "limit", value: "\(limit)"))

            
            return items
        case .getFollowers(_, let search, let cursor, let limit):
            var items: [URLQueryItem] = []
            if let cursor = cursor {
                items.append(URLQueryItem(name: "cursor", value: cursor))
            }
            if let query = search, !query.isEmpty {
                items.append(URLQueryItem(name: "search", value: search))
            }
            items.append(URLQueryItem(name: "limit", value: "\(limit)"))

            
            return items
        case .getFollowing(_, let search, let cursor, let limit):
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
