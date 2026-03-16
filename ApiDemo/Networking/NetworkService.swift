import Foundation
protocol NetworkServiceProtocol {
    func request<T: Decodable>(
        _ endpoint: APIEndpointProtocol,
        responseType: T.Type
    ) async throws -> T
}

final class NetworkService: NetworkServiceProtocol {
    
    private let session: URLSession
    private let timeoutInterval: TimeInterval
    private let tokenStorage: TokenStorage
    private let authService: AuthServiceProtocol
    
    init(
        session: URLSession = .shared,
        timeoutInterval: TimeInterval = 30,
        tokenStorage: TokenStorage,
        authService: AuthServiceProtocol
    ) {
        self.session = session
        self.timeoutInterval = timeoutInterval
        self.tokenStorage = tokenStorage
        self.authService = authService
    }
    
    func request<T: Decodable>(
        _ endpoint: APIEndpointProtocol,
        responseType: T.Type
    ) async throws -> T {
        
        guard NetworkMonitor.shared.isConnected else {
            throw NetworkError.noInternetConnection
        }
        let request = try buildRequest(for: endpoint)
        
        do {
            let (data, response) = try await session.data(for: request)
            return try handleResponse(data, response: response, responseType: responseType)
            
        } catch NetworkError.tokenExpired {
            
            // Refresh Token
            _ = try await authService.refreshToken()
            
            // Retry request
            let retryRequest = try buildRequest(for: endpoint)
            let (data, response) = try await session.data(for: retryRequest)
            
            return try handleResponse(data, response: response, responseType: responseType)
            
        } catch let error as URLError {
            throw mapURLError(error)
        } catch {
            throw NetworkError.unknown(error)
        }
    }
    
}

private extension NetworkService {
    
    func buildRequest(for endpoint: APIEndpointProtocol) throws -> URLRequest {
        
        let url = endpoint.baseURL.appendingPathComponent(endpoint.path)
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let finalURL = components.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = endpoint.method.rawValue
        request.timeoutInterval = timeoutInterval
        
        endpoint.headers.forEach {
            request.setValue($1, forHTTPHeaderField: $0)
        }
        
        if let token = tokenStorage.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = endpoint.body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        
        return request
    }
}
private extension NetworkService {
    
    func handleResponse<T: Decodable>(
        _ data: Data,
        response: URLResponse,
        responseType: T.Type
    ) throws -> T {
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
            
        case 200...299:
            return try decode(data, type: responseType)
            
        case 401:
            throw NetworkError.tokenExpired
            
        case 400...499, 500...599:
            let message = try? extractErrorMessage(from: data)
            throw NetworkError.serverError(
                statusCode: httpResponse.statusCode,
                message: message
            )
            
        default:
            throw NetworkError.invalidResponse
        }
    }
}

private extension NetworkService {
    
    func mapURLError(_ error: URLError) -> NetworkError {
        
        switch error.code {
            
        case .timedOut:
            return .requestTimeout
            
        case .notConnectedToInternet,
             .networkConnectionLost:
            return .noInternetConnection
            
        default:
            return .unknown(error)
        }
    }
    func extractErrorMessage(from data: Data) throws -> String? {
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        
        if let message = json["message"] as? String {
            return message
        }
        
        if let error = json["error"] as? String {
            return error
        }
        
        return nil
    }
}



private extension NetworkService {
    
    func decode<T: Decodable>(_ data: Data, type: T.Type) throws -> T {
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
