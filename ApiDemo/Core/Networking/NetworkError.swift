import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError(Error)
    case serverError(statusCode: Int, message: String?)
    case tokenExpired
    case tokenRefreshFailed
    case noRefreshToken
    case noInternetConnection
    case requestTimeout
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid."
        case .invalidResponse:
            return "The server response was invalid."
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let statusCode, let message):
            return "Server error (\(statusCode)): \(message ?? "Unknown error")"
        case .tokenExpired:
            return "Your session has expired. Please log in again."
        case .tokenRefreshFailed:
            return "Failed to refresh authentication token."
        case .noRefreshToken:
            return "Access Token Empty"
        case .noInternetConnection:
            return "No internet connection available."
        case .requestTimeout:
            return "The request timed out. Please try again."
        case .unknown(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .tokenExpired, .tokenRefreshFailed:
            return "Please log in again."
        case .noInternetConnection:
            return "Check your internet connection and try again."
        case .requestTimeout:
            return "Try again with a slower connection or check the server status."
        default:
            return "Please try again later."
        }
    }
}
