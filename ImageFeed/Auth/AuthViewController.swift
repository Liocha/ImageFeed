import ProgressHUD
import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {

    weak var delegate: AuthViewControllerDelegate?

    private let showWebViewSegueIdentifier = "ShowWebView"
    private let oauth2Service = OAuth2Service.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == showWebViewSegueIdentifier {

            guard
                let webViewViewController = segue.destination
                    as? WebViewViewController
            else {
                assertionFailure("Failed to prepare for \(showWebViewSegueIdentifier)")
                return
            }

            let authHelper = AuthHelper()
            let webViewPresenter = WebViewPresenter(authHelper: authHelper)

            webViewViewController.presenter = webViewPresenter
            webViewPresenter.view = webViewViewController

            webViewViewController.delegate = self

        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(
            named: "nav_back_button"
        )
        navigationController?.navigationBar.backIndicatorTransitionMaskImage =
            UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: nil,
            action: nil
        )
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "ypBlack")
    }

}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(
        _ vc: WebViewViewController,
        didAuthenticateWithCode code: String
    ) {

        // Скрываем WebViewViewController
        vc.dismiss(animated: true)

        // Показываем индикатор загрузки
        UIBlockingProgressHUD.show()

        oauth2Service.fetchAuthToken(code) { result in

            // Скрываем индикатор загрузки
            UIBlockingProgressHUD.dismiss()

            switch result {
            case .success(let token):
                let storage = OAuth2TokenStorage.shared
                storage.token = token
                self.delegate?.didAuthenticate(self)

            case .failure(let error):
                print("OAuth error:", error)
                DispatchQueue.main.async {
                    self.showAuthErrorAlert()
                }
            }
        }
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}

extension AuthViewController {
    func showAuthErrorAlert() {
        let alertController = UIAlertController(
            title: "Что-то пошло не так",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "Ок", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
