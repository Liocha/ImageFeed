import UIKit
import WebKit

protocol ProfileViewPresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }

    func viewDidLoad()
    func didTapLogout()
    func didConfirmLogout()
}

final class ProfilePresenter: ProfileViewPresenterProtocol {

    weak var view: ProfileViewControllerProtocol?
    private var profileImageObserver: NSObjectProtocol?

    func viewDidLoad() {
        updateProfile()
        observeAvatarChanges()
        updateAvatar()
    }

    deinit {
        if let observer = profileImageObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    func didTapLogout() {
        view?.showLogoutConfirmation()
    }

    func didConfirmLogout() {
        ProfileLogoutService.shared.logout()
        view?.switchToSplash()
    }

    private func updateProfile() {
        guard let profile = ProfileService.shared.profile else { return }

        let name = profile.name.isEmpty ? "Имя не указано" : profile.name
        let username =
            profile.loginName.isEmpty
            ? "@неизвестный_пользователь"
            : profile.loginName
        let bio =
            (profile.bio?.isEmpty ?? true)
            ? "Профиль не заполнен"
            : profile.bio!

        view?.updateProfile(name: name, username: username, bio: bio)
    }

    private func updateAvatar() {
        guard
            let avatarString = ProfileImageService.shared.avatarURL,
            let url = URL(string: avatarString)
        else { return }

        view?.updateAvatar(url: url)
    }

    private func observeAvatarChanges() {
        profileImageObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAvatar()
        }
    }
}
