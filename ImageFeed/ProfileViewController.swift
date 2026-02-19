import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {

    private let nameLabel = UILabel()
    private let usernameLabel = UILabel()
    private let helloWorldLabel = UILabel()
    private let profileImageView = UIImageView()
    private let actionButton = UIButton()

    private var profileImageServiceObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        if let profile = ProfileService.shared.profile {
            updateProfileDetails(profile: profile)
        }

        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.updateAvatar()
            }

        updateAvatar()
    }

    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
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
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Вы уверены, что хотите выйти?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Выйти", style: .destructive) { [weak self] _ in
            self?.logout()
        })

        present(alert, animated: true)
    }
    
    private func logout() {
        ProfileLogoutService.shared.logout()

        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }

        let splashVC = SplashViewController()
        window.rootViewController = splashVC
    }

    // MARK: - Data Update

    private func updateProfileDetails(profile: Profile) {
        nameLabel.text =
            profile.name.isEmpty
            ? "Имя не указано"
            : profile.name

        usernameLabel.text =
            profile.loginName.isEmpty
            ? "@неизвестный_пользователь"
            : profile.loginName

        helloWorldLabel.text =
            (profile.bio?.isEmpty ?? true)
            ? "Профиль не заполнен"
            : profile.bio
    }

    private func updateAvatar() {
        guard
            let avatarString = ProfileImageService.shared.avatarURL,
            let url = URL(string: avatarString)
        else { return }
        
        profileImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "profileImage"),
            options: [
                .transition(.fade(0.2)),
                .cacheOriginalImage
            ]
        )
    }
}
