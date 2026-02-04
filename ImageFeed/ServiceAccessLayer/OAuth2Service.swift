import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()

    private init() {}

    func fetchAuthToken(
        _ code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {

        guard let url = URL(string: "https://unsplash.com/oauth/token") else {
            print("Failed to create URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(
            "application/x-www-form-urlencoded",
            forHTTPHeaderField: "Content-Type"
        )

        let parameters = [
            "client_id": Constants.accessKey,
            "client_secret": Constants.secretKey,
            "redirect_uri": Constants.redirectURI,
            "code": code,
            "grant_type": "authorization_code",
        ]

        let bodyString =
            parameters
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")

        request.httpBody = bodyString.data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request) {
            data,
            response,
            error in

            if let error = error {
                print("Network error:", error)
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Failed to cast response to HTTPURLResponse")
                DispatchQueue.main.async {
                    completion(
                        .failure(NSError(domain: "No HTTP response", code: 0))
                    )
                }
                return
            }

            guard 200..<300 ~= httpResponse.statusCode else {
                print("HTTP error:", httpResponse.statusCode)
                DispatchQueue.main.async {
                    completion(
                        .failure(
                            NSError(
                                domain: "HTTP error",
                                code: httpResponse.statusCode
                            )
                        )
                    )
                }
                return
            }

            guard let data = data else {
                print("No data in response")
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "No data", code: 0)))
                }
                return
            }

            do {
                let tokenResponse = try JSONDecoder()
                    .decode(OAuthTokenResponseBody.self, from: data)

                DispatchQueue.main.async {
                    completion(.success(tokenResponse.accessToken))
                }
            } catch {
                print("Decoding error:", error)
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }

        task.resume()
    }

}
