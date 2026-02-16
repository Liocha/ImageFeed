import Foundation

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
}

struct ProfileResult: Codable {
    let username: String
    let firstName: String?
    let lastName: String?
    let bio: String?
}

final class ProfileService {
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared

    static let shared = ProfileService()
    private init() {}

    private(set) var profile: Profile?

    func fetchProfile(
        _ token: String,
        completion: @escaping (Result<Profile, Error>) -> Void
    ) {
        task?.cancel()

        guard let request = makeProfileRequest(token: token) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        let task = urlSession.objectTask(for: request) {
            [weak self] (result: Result<ProfileResult, Error>) in
            
            guard let self = self else { return }
            defer { self.task = nil }

            switch result {
            case .success(let profileResult):
                
                let fullName = [
                    profileResult.firstName,
                    profileResult.lastName
                ]
                .compactMap { $0 }
                .joined(separator: " ")
                
                let profile = Profile(
                    username: profileResult.username,
                    name: fullName,
                    loginName: "@\(profileResult.username)",
                    bio: profileResult.bio
                )

                self.profile = profile
                completion(.success(profile))

            case .failure(let error):
                print("[ProfileService.fetchProfile]: \(error)")
                completion(.failure(error))
            }
        }

        self.task = task
        task.resume()
    }

    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
