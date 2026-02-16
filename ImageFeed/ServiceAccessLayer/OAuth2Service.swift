import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()

    private let urlSession = URLSession.shared

    private var task: URLSessionTask?
    private var lastCode: String?
    private var currentCompletion: ((Result<String, Error>) -> Void)?

    private init() {}

    func fetchAuthToken(
        _ code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)

        guard lastCode != code else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }

        if let task = task {
            currentCompletion?(.failure(AuthServiceError.invalidRequest))
            task.cancel()
        }

        lastCode = code
        currentCompletion = completion

        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(AuthServiceError.invalidRequest))
            lastCode = nil
            currentCompletion = nil
            return
        }

        let task = urlSession.objectTask(for: request) {
            [weak self] (result: Result<OAuthTokenResponseBody, Error>) in

            guard let self = self else { return }

            defer {
                self.task = nil
                self.lastCode = nil
                self.currentCompletion = nil
            }

            switch result {
            case .success(let responseBody):
                self.currentCompletion?(.success(responseBody.accessToken))

            case .failure(let error):
                print("[OAuth2Service.fetchAuthToken]: \(error)")
                self.currentCompletion?(.failure(error))
            }
        }

        self.task = task
        task.resume()
    }

    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard
            var urlComponents = URLComponents(
                string: "https://unsplash.com/oauth/token"
            )
        else {
            assertionFailure("Failed to create URL")
            return nil
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]

        guard let url = urlComponents.url else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}
