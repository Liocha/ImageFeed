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

        guard segue.identifier == showWebViewSegueIdentifier else {
            super.prepare(for: segue, sender: sender)
            return
        }

        guard
            let webViewViewController = segue.destination
                as? WebViewViewController
        else {
            assertionFailure(
                "Failed to prepare for \(showWebViewSegueIdentifier)"
            )
            return
        }

        webViewViewController.delegate = self

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
        oauth2Service.fetchAuthToken(code) { result in
            switch result {
            case .success(let token):
                let storage = OAuth2TokenStorage()
                storage.token = token
                self.delegate?.didAuthenticate(self)

            case .failure(let error):
                print("OAuth error:", error)
            }
        }
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
