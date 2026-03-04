import UIKit

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }

    func reloadData()
    func insertRows(at indexPaths: [IndexPath])
    func showError(message: String)
    func updateLike(at indexPath: IndexPath)
}

class ImagesListViewController: UIViewController {
    @IBOutlet weak private var tableView: UITableView!
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var photos: [Photo] = []
    var presenter: ImagesListPresenterProtocol?

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self

        tableView.contentInset = UIEdgeInsets(
            top: 12,
            left: 0,
            bottom: 12,
            right: 0
        )

        presenter?.viewDidLoad()

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination
                    as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            let photo = presenter?.photo(at: indexPath)
            viewController.imageURL = photo?.largeImageURL
            //            viewController.imageURL = photos[indexPath.row].largeImageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    @objc private func didSelectLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter?.didTapLike(at: indexPath)
    }

}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        return presenter?.numberOfRows() ?? 0
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ImagesListCell.reuseIdentifier,
                for: indexPath
            ) as? ImagesListCell
        else {
            return UITableViewCell()
        }

        guard let photo = presenter?.photo(at: indexPath) else {
            return cell
        }
        configCell(for: cell, with: photo, at: indexPath)

        cell.delegate = self
        return cell
    }
}

extension ImagesListViewController {

    func configCell(
        for cell: ImagesListCell,
        with photo: Photo,
        at indexPath: IndexPath
    ) {

        cell.cellImage.kf.indicatorType = .activity

        cell.cellImage.kf.setImage(
            with: URL(string: photo.thumbImageURL),
            placeholder: UIImage(named: "Stub")
        ) { [weak self] _ in
            guard let self else { return }

            self.tableView.performBatchUpdates {
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }

        if let date = photo.createdAt {
            cell.dateLabel.text = dateFormatter.string(from: date)
        } else {
            cell.dateLabel.text = ""
        }

        let likeImage =
            photo.isLiked
            ? UIImage(named: "FavoritesActive")
            : UIImage(named: "FavoritesNoActive")

        cell.likeButton.setImage(likeImage, for: .normal)
    }
}

extension ImagesListViewController: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {

        presenter?.didSelectRow(at: indexPath)

        performSegue(
            withIdentifier: showSingleImageSegueIdentifier,
            sender: indexPath
        )
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 300
    }

    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {

        presenter?.willDisplayCell(at: indexPath)
    }
}

extension ImagesListViewController: ImagesListCellDelegate {

    func imageListCellDidTapLike(_ cell: ImagesListCell) {

        guard let indexPath = tableView.indexPath(for: cell) else { return }

        presenter?.didTapLike(at: indexPath)
    }
}

extension ImagesListViewController: ImagesListViewControllerProtocol {

    func reloadData() {
        tableView.reloadData()
    }

    func insertRows(at indexPaths: [IndexPath]) {
        tableView.insertRows(at: indexPaths, with: .automatic)
    }

    func showError(message: String) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))

        present(alert, animated: true)
    }

    func updateLike(at indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
