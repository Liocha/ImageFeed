import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
    case decodingError(Error)
}

extension URLSession {

    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {

        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = {
            result in
            DispatchQueue.main.async {
                completion(result)
            }
        }

        let task = dataTask(with: request) { data, response, error in

            if let error = error {
                print(
                    "[URLSession.data]: urlRequestError - \(error.localizedDescription)"
                )
                fulfillCompletionOnTheMainThread(
                    .failure(NetworkError.urlRequestError(error))
                )
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("[URLSession.data]: urlSessionError - invalid response")
                fulfillCompletionOnTheMainThread(
                    .failure(NetworkError.urlSessionError)
                )
                return
            }

            guard 200..<300 ~= httpResponse.statusCode else {
                print(
                    "[URLSession.data]: httpStatusCode - \(httpResponse.statusCode)"
                )
                fulfillCompletionOnTheMainThread(
                    .failure(
                        NetworkError.httpStatusCode(httpResponse.statusCode)
                    )
                )
                return
            }

            guard let data = data else {
                print("[URLSession.data]: urlSessionError - data is nil")
                fulfillCompletionOnTheMainThread(
                    .failure(NetworkError.urlSessionError)
                )
                return
            }

            fulfillCompletionOnTheMainThread(.success(data))
        }

        return task
    }
}

extension URLSession {

    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let task = data(for: request) { result in

            switch result {

            case .success(let data):

                if let jsonString = String(data: data, encoding: .utf8) {
                    print("[objectTask]: Received JSON - \(jsonString)")
                }

                do {
                    let decodedObject = try decoder.decode(T.self, from: data)
                    completion(.success(decodedObject))

                } catch {
                    print(
                        "[objectTask]: DecodingError - \(error.localizedDescription), Data: \(String(data: data, encoding: .utf8) ?? "")"
                    )

                    completion(
                        .failure(NetworkError.decodingError(error))
                    )
                }

            case .failure(let error):
                print(
                    "[objectTask]: NetworkError - \(error.localizedDescription)"
                )
                completion(.failure(error))
            }
        }

        return task
    }
}
