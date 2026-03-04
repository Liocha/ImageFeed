import UIKit

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {

    static let reuseIdentifier = "ImagesListCell"

    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!

    weak var delegate: ImagesListCellDelegate?

    override func prepareForReuse() {
        super.prepareForReuse()
        likeButton.accessibilityIdentifier = "likeButton"
        likeButton.accessibilityLabel = "likeButton"

        cellImage.kf.cancelDownloadTask()
        cellImage.image = nil
    }

    func setIsLiked(_ isLiked: Bool) {
        let imageName = isLiked ? "FavoritesActive" : "FavoritesNoActive"
        likeButton.setImage(UIImage(named: imageName), for: .normal)
    }
    @IBAction func likeButtonClicked(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
}
