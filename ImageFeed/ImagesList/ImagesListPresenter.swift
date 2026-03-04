import UIKit
import WebKit

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }

    func viewDidLoad()
    func numberOfRows() -> Int
    func photo(at indexPath: IndexPath) -> Photo
    func didSelectRow(at indexPath: IndexPath)
    func willDisplayCell(at indexPath: IndexPath)
    func didTapLike(at indexPath: IndexPath)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {

    weak var view: ImagesListViewControllerProtocol?
    private let service: ImagesListService
    private var photos: [Photo] = []
    private var observer: NSObjectProtocol?

    init(service: ImagesListService = .shared) {
        self.service = service
    }

    func viewDidLoad() {
        photos = service.photos
        view?.reloadData()
        
        observeChanges()
        service.fetchPhotosNextPage()
    }

    deinit {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    private func observeChanges() {
        observer = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: service,
            queue: .main
        ) { [weak self] _ in
            self?.handleUpdate()
        }
    }

    private func handleUpdate() {
        let oldCount = photos.count
        let newPhotos = service.photos
        let newCount = newPhotos.count

        photos = newPhotos

        guard oldCount != newCount else { return }

        let indexPaths = (oldCount..<newCount).map {
            IndexPath(row: $0, section: 0)
        }

        view?.insertRows(at: indexPaths)
    }

    func numberOfRows() -> Int {
        photos.count
    }

    func photo(at indexPath: IndexPath) -> Photo {
        photos[indexPath.row]
    }

    func didSelectRow(at indexPath: IndexPath) {
        // View выполнит segue
    }

    func willDisplayCell(at indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            service.fetchPhotosNextPage()
        }
    }

    func didTapLike(at indexPath: IndexPath) {
        let photo = photos[indexPath.row]

        service.changeLike(
            photoId: photo.id,
            isLike: !photo.isLiked
        ) { [weak self] result in

            guard let self else { return }

            switch result {
            case .success:
                self.photos = self.service.photos
                self.view?.updateLike(at: indexPath)

            case .failure(let error):
                self.view?.showError(message: error.localizedDescription)
            }
        }
    }
}
