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
            Logger.log("No Internet Connection", level: .error)
            throw NetworkError.noInternetConnection
        }
        
        let request = try buildRequest(for: endpoint)
        
        // ⏱️ Start time
        let startTime = Date()
        
        // 🔥 Request Log
        Logger.log("\(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")", level: .request)
        
        if let headers = request.allHTTPHeaderFields {
            Logger.log("Headers: \(headers)", level: .info)
        }
        
        if let body = request.httpBody {
            Logger.prettyJSON(body)
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            let duration = Date().timeIntervalSince(startTime)
            
            // 🔥 Response Log
            if let httpResponse = response as? HTTPURLResponse {
                Logger.log("Status: \(httpResponse.statusCode) (\(String(format: "%.2f", duration))s)", level: .success)
            }
            
            Logger.prettyJSON(data)
            
            return try handleResponse(data, response: response, responseType: responseType)
            
        } catch NetworkError.tokenExpired {
            
            Logger.log("🔄 Token expired. Refreshing...", level: .info)
            
            _ = try await authService.refreshToken()
            
            let retryRequest = try buildRequest(for: endpoint)
            let (data, response) = try await session.data(for: retryRequest)
            
            Logger.log("🔁 Retried Request Success", level: .success)
            Logger.prettyJSON(data)
            
            return try handleResponse(data, response: response, responseType: responseType)
            
        } catch let error as URLError {
            Logger.log("URLError: \(error.localizedDescription)", level: .error)
            throw mapURLError(error)
            
        } catch {
            Logger.log("Unknown Error: \(error.localizedDescription)", level: .error)
            throw NetworkError.unknown(error)
        }
    }
    
}

private extension NetworkService {
    
    func buildRequest(for endpoint: APIEndpointProtocol) throws -> URLRequest {
                
        var components = URLComponents(
            url: endpoint.baseURL.appendingPathComponent(endpoint.path),
            resolvingAgainstBaseURL: true
        )
        
        components?.queryItems = endpoint.queryItems
        
        guard let finalURL = components?.url else {
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
            Logger.log("Invalid Response", level: .error)
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
            
        case 200...299:
            Logger.log("✅ Success Response", level: .success)
            return try decode(data, type: responseType)
            
        case 401:
            Logger.log("❌ 401 Unauthorized", level: .error)
            throw NetworkError.tokenExpired
            
        case 400...499, 500...599:
            let message = try? extractErrorMessage(from: data)
            Logger.log("❌ Server Error: \(message ?? "Unknown")", level: .error)
            throw NetworkError.serverError(
                statusCode: httpResponse.statusCode,
                message: message
            )
            
        default:
            Logger.log("❌ Unexpected Status Code: \(httpResponse.statusCode)", level: .error)
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
