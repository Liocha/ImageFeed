import Foundation

struct ProfileImage: Codable {
    let small: String
    let medium: String
    let large: String

    private enum CodingKeys: String, CodingKey {
        case small
        case medium
        case large
    }
}

struct UserResult: Codable {
    let profileImage: ProfileImage

    private enum CodingKeys: String, CodingKey {
        case profileImage
    }
}

final class ProfileImageService {

    static let didChangeNotification =
        Notification.Name("ProfileImageProviderDidChange")

    static let shared = ProfileImageService()
    private init() {}

    private let urlSession = URLSession.shared
    private var task: URLSessionTask?

    private(set) var avatarURL: String?

    func fetchProfileImageURL(
        username: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        task?.cancel()

        guard let token = OAuth2TokenStorage.shared.token else {
            let error = URLError(.userAuthenticationRequired)
            print("[ProfileImageService.fetchProfileImageURL]: \(error)")
            completion(.failure(error))
            return
        }

        guard
            let request = makeProfileImageRequest(
                username: username,
                token: token
            )
        else {
            let error = URLError(.badURL)
            print("[ProfileImageService.fetchProfileImageURL]: \(error)")
            completion(.failure(error))
            return
        }

        let task = urlSession.objectTask(for: request) {
            [weak self] (result: Result<UserResult, Error>) in

            guard let self = self else { return }
            defer { self.task = nil }

            switch result {

            case .success(let userResult):
                let url = userResult.profileImage.small
                self.avatarURL = url

                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": url]
                )

                completion(.success(url))

            case .failure(let error):
                print("[ProfileImageService.fetchProfileImageURL]: \(error)")
                completion(.failure(error))
            }
        }

        self.task = task
        task.resume()
    }

    private func makeProfileImageRequest(
        username: String,
        token: String
    ) -> URLRequest? {

        guard
            let url = URL(
                string: "https://api.unsplash.com/users/\(username)"
            )
        else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func reset() {
        avatarURL = nil
    }
}
