import UIKit

final class ImagesListService {

    static let shared = ImagesListService()

    static let didChangeNotification =
        Notification.Name(rawValue: "ImagesListServiceDidChange")

    private(set) var photos: [Photo] = []

    private var lastLoadedPage: Int?
    private var isLoading = false
    private let perPage = 10

    private let isoFormatter = ISO8601DateFormatter()

    private init() {}
    
    func reset() {
        photos = []
        lastLoadedPage = nil
    }
}

extension ImagesListService {

    func fetchPhotosNextPage() {

        guard !isLoading else { return }

        isLoading = true

        let nextPage = (lastLoadedPage ?? 0) + 1

        let request = makePhotosRequest(page: nextPage, perPage: perPage)

        let task = URLSession.shared.dataTask(with: request) {
            [weak self] data, response, error in

            guard let self = self else { return }

            defer { self.isLoading = false }

            if let error = error {
                print("[ImagesListService.fetchPhotosNextPage]: network error \(error.localizedDescription) page=\(nextPage)")
                return
            }

            guard let data = data else { return }

            do {
                let decoder = JSONDecoder()
                let photoResults = try decoder.decode(
                    [PhotoResult].self,
                    from: data
                )

                let newPhotos = photoResults.map(self.convert)

                DispatchQueue.main.async {

                    self.photos.append(contentsOf: newPhotos)

                    self.lastLoadedPage = nextPage

                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                }

            } catch {
                print("ImagesListService decoding error:", error)
            }
        }

        task.resume()
    }
}

extension ImagesListService {

    fileprivate func convert(_ result: PhotoResult) -> Photo {

        let createdDate: Date?

        if let createdAt = result.createdAt {
            createdDate = isoFormatter.date(from: createdAt)
        } else {
            createdDate = nil
        }

        return Photo(
            id: result.id,
            size: CGSize(width: result.width, height: result.height),
            createdAt: createdDate,
            welcomeDescription: result.description,
            thumbImageURL: result.urls.thumb,
            largeImageURL: result.urls.full,
            isLiked: result.likedByUser
        )
    }
}

extension ImagesListService {

    fileprivate func makePhotosRequest(page: Int, perPage: Int) -> URLRequest {

        var components = URLComponents(
            string: "https://api.unsplash.com/photos"
        )!

        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)"),
        ]

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"

        request.setValue(
            "Client-ID \(Constants.accessKey)",
            forHTTPHeaderField: "Authorization"
        )

        return request
    }
}

extension ImagesListService {

    func changeLike(
        photoId: String,
        isLike: Bool,
        _ completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let urlString = "https://api.unsplash.com/photos/\(photoId)/like"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Client-ID \(Constants.accessKey)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                print("[ImagesListService.changeLike]: network error \(error.localizedDescription) photoId=\(photoId) isLike=\(isLike)")
                completion(.failure(error))
                return
            }

            DispatchQueue.main.async {
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let oldPhoto = self.photos[index]
                    let newPhoto = Photo(
                        id: oldPhoto.id,
                        size: oldPhoto.size,
                        createdAt: oldPhoto.createdAt,
                        welcomeDescription: oldPhoto.welcomeDescription,
                        thumbImageURL: oldPhoto.thumbImageURL,
                        largeImageURL: oldPhoto.largeImageURL,
                        isLiked: !oldPhoto.isLiked
                    )
                    self.photos[index] = newPhoto

                }
                completion(.success(()))
            }
        }

        task.resume()
    }
}

