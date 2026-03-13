# Networking Architecture

## Overview
This networking layer provides a robust, protocol-based architecture for handling API requests with automatic token management, error handling, and request retry logic.

## Key Components

### 1. APIEndpointProtocol & APIEndpoint
- **Protocol-based design** allows for flexible endpoint implementations
- Enum-based endpoints with automatic URL building
- Supports all HTTP methods (GET, POST, PUT, DELETE, PATCH)
- Automatic header and body management

```swift
enum APIEndpoint: APIEndpointProtocol {
    case getUsers
    case getUser(id: Int)
    case createUser(name: String, email: String)
    
    var baseURL: URL { ... }
    var path: String { ... }
    var method: HTTPMethod { ... }
    var headers: [String: String] { ... }
    var body: [String: Any]? { ... }
}
```

### 2. NetworkError
Custom error types with user-friendly descriptions:
- `invalidURL` - URL construction failed
- `invalidResponse` - Invalid server response
- `decodingError` - JSON decoding failed
- `serverError` - HTTP error responses (4xx, 5xx)
- `tokenExpired` - 401 Unauthorized
- `tokenRefreshFailed` - Token refresh failed
- `noInternetConnection` - Network unavailable
- `requestTimeout` - Request exceeded timeout
- `unknown` - Unexpected error

### 3. TokenManager
Handles authentication token lifecycle:
- **getAccessToken()** - Returns valid token or nil if expired
- **refreshToken()** - Async method to refresh expired tokens
- **clearTokens()** - Clears all stored tokens
- **isTokenExpired()** - Checks token expiration status
- **setTokens()** - Stores new tokens with expiration

### 4. NetworkService
Generic networking service with automatic:
- **Token Management** - Automatically adds Bearer token to requests
- **Token Refresh** - Automatically refreshes expired tokens and retries
- **Error Handling** - Maps URLError to NetworkError
- **Timeout Management** - Configurable timeout (default 30s)
- **Response Decoding** - Generic Decodable support

#### Token Refresh Flow
```
Request → 401 Response
    ↓
Detect Token Expired
    ↓
Call tokenManager.refreshToken()
    ↓
Retry Original Request with New Token
    ↓
Return Response or Throw Error
```

### 5. BaseViewModel
Provides common functionality for all ViewModels:
- Loading state management
- Error message handling
- Generic `performRequest()` method

### 6. Usage Example

#### Define Endpoints
```swift
enum APIEndpoint: APIEndpointProtocol {
    case getUsers
    case createUser(name: String, email: String)
    
    var baseURL: URL {
        URL(string: "https://api.example.com")!
    }
    
    var path: String {
        switch self {
        case .getUsers:
            return "/users"
        case .createUser:
            return "/users"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getUsers:
            return .get
        case .createUser:
            return .post
        }
    }
    
    var body: [String: Any]? {
        switch self {
        case .createUser(let name, let email):
            return ["name": name, "email": email]
        default:
            return nil
        }
    }
}
```

#### Create ViewModel
```swift
@MainActor
class UserViewModel: BaseViewModel {
    @Published var users: [User] = []
    
    func fetchUsers() async {
        users = await performRequest(.getUsers, responseType: [User].self) ?? []
    }
    
    func createUser(name: String, email: String) async {
        let newUser = await performRequest(
            .createUser(name: name, email: email),
            responseType: User.self
        )
        if let newUser = newUser {
            users.append(newUser)
        }
    }
}
```

#### Use in View
```swift
struct UsersView: View {
    @StateObject private var viewModel = UserViewModel()
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView()
            } else if let error = viewModel.errorMessage {
                Text("Error: \(error)")
            } else {
                List(viewModel.users) { user in
                    Text(user.name)
                }
            }
        }
        .task {
            await viewModel.fetchUsers()
        }
    }
}
```

## SOLID Principles Applied

### Single Responsibility
- `TokenManager` - Only manages tokens
- `NetworkService` - Only handles HTTP requests
- `APIEndpoint` - Only defines endpoint configuration

### Open/Closed
- Easy to add new endpoints without modifying existing code
- Protocol-based design allows for custom implementations

### Liskov Substitution
- `APIEndpointProtocol` - Any endpoint can be used interchangeably
- `TokenManaging` - Any token manager can be substituted
- `NetworkServiceProtocol` - Easy to mock for testing

### Interface Segregation
- Focused protocols with minimal required methods
- Clients only depend on what they need

### Dependency Injection
- Services are injected, not created internally
- Easy to provide mock implementations for testing

## Features

✅ Generic request handling for any Decodable type
✅ Automatic token refresh on 401 errors
✅ Configurable timeout (default 30 seconds)
✅ Network error mapping (timeout, no internet, etc.)
✅ Automatic error message extraction
✅ Thread-safe token refresh (prevents multiple simultaneous refreshes)
✅ Protocol-based design for flexibility
✅ Easy ViewModel integration
✅ User-friendly error messages with recovery suggestions

## Testing

Mock implementations for testing:

```swift
class MockTokenManager: TokenManaging {
    func getAccessToken() -> String? { "mock-token" }
    func refreshToken() async throws -> String { "new-token" }
    func clearTokens() {}
    func isTokenExpired() -> Bool { false }
}

class MockNetworkService: NetworkServiceProtocol {
    func request<T: Decodable>(_ endpoint: APIEndpointProtocol, responseType: T.Type) async throws -> T {
        // Return mock data
    }
}

// Use in tests
let mockService = MockNetworkService()
let viewModel = UserViewModel(networkService: mockService)
```
