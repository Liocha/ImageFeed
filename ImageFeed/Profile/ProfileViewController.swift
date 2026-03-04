import Kingfisher
import UIKit

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfileViewPresenterProtocol? { get set }

    func updateProfile(name: String, username: String, bio: String)
    func updateAvatar(url: URL?)
    func showLogoutConfirmation()
    func switchToSplash()
}

final class ProfileViewController: UIViewController &
    ProfileViewControllerProtocol
{

    var presenter: ProfileViewPresenterProtocol?

    // MARK: - UI

    private let nameLabel = UILabel()
    private let usernameLabel = UILabel()
    private let helloWorldLabel = UILabel()
    private let profileImageView = UIImageView()
    private let actionButton = UIButton()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter?.viewDidLoad()
    }
    
    func configure(with presenter: ProfileViewPresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = .ypBlack
        setupProfileImage()
        setupNameLabel()
        setupUsernameLabel()
        setupHelloWorldLabel()
        setupActionButton()
    }

    private func setupProfileImage() {
        profileImageView.image = UIImage(named: "profileImage")
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 35
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileImageView)

        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 20
            ),
            profileImageView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 20
            ),
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
        ])
    }

    private func setupNameLabel() {
        nameLabel.textColor = .ypWhite
        nameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(
                equalTo: profileImageView.leadingAnchor
            ),
            nameLabel.topAnchor.constraint(
                equalTo: profileImageView.bottomAnchor,
                constant: 20
            ),
        ])
    }

    private func setupUsernameLabel() {
        usernameLabel.textColor = .ypGrey
        usernameLabel.font = UIFont.systemFont(ofSize: 13)
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(usernameLabel)

        NSLayoutConstraint.activate([
            usernameLabel.leadingAnchor.constraint(
                equalTo: profileImageView.leadingAnchor
            ),
            usernameLabel.topAnchor.constraint(
                equalTo: nameLabel.bottomAnchor,
                constant: 8
            ),
        ])
    }

    private func setupHelloWorldLabel() {
        helloWorldLabel.textColor = .ypWhite
        helloWorldLabel.font = UIFont.systemFont(ofSize: 13)
        helloWorldLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(helloWorldLabel)

        NSLayoutConstraint.activate([
            helloWorldLabel.leadingAnchor.constraint(
                equalTo: profileImageView.leadingAnchor
            ),
            helloWorldLabel.topAnchor.constraint(
                equalTo: usernameLabel.bottomAnchor,
                constant: 8
            ),
        ])
    }

    private func setupActionButton() {
        if let image = UIImage(systemName: "ipad.and.arrow.forward") {
            actionButton.setImage(image, for: .normal)
        }

        actionButton.tintColor = .ypRed
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.accessibilityIdentifier = "logout button"
        actionButton.addTarget(
            self,
            action: #selector(didTapButton),
            for: .touchUpInside
        )

        view.addSubview(actionButton)

        NSLayoutConstraint.activate([
            actionButton.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -20
            ),
            actionButton.centerYAnchor.constraint(
                equalTo: profileImageView.centerYAnchor
            ),
        ])
    }

    // MARK: - Actions

    @objc private func didTapButton() {
        presenter?.didTapLogout()
    }

    // MARK: - ProfileViewControllerProtocol

    func updateProfile(name: String, username: String, bio: String) {
        nameLabel.text = name
        usernameLabel.text = username
        helloWorldLabel.text = bio
    }

    func updateAvatar(url: URL?) {
        guard let url else { return }

        profileImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "profileImage")
        )
    }

    func showLogoutConfirmation() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Вы уверены, что хотите выйти?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(
            UIAlertAction(title: "Выйти", style: .destructive) {
                [weak self] _ in
                self?.presenter?.didConfirmLogout()
            }
        )

        present(alert, animated: true)
    }

    func switchToSplash() {
        guard let window = UIApplication.shared.windows.first else { return }
        window.rootViewController = SplashViewController()
    }
}
