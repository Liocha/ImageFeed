import Foundation

enum AuthServiceError: Error {
    case invalidRequest
    case invalidResponse
    case httpStatusCode(Int)
}
