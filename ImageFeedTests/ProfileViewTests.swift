import Foundation
import Testing
import XCTest

@testable import ImageFeed

final class ProfileViewTests: XCTestCase {

    func testProfileViewControllerCallsPresenterViewDidLoad() {
        // given
        let viewController = ProfileViewController()
        let presenterSpy = ProfilePresenterSpy()
        viewController.presenter = presenterSpy
        presenterSpy.view = viewController

        // when
        _ = viewController.view

        // then
        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }
    
    func testDidTapLogoutShowsConfirmation() {
        // given
        let viewSpy = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        presenter.view = viewSpy

        // when
        presenter.didTapLogout()

        // then
        XCTAssertTrue(viewSpy.showLogoutConfirmationCalled)
    }
    
    func testDidConfirmLogoutSwitchesToSplash() {
        // given
        let viewSpy = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        presenter.view = viewSpy

        // when
        presenter.didConfirmLogout()

        // then
        XCTAssertTrue(viewSpy.switchToSplashCalled)
    }

}

final class ProfilePresenterSpy: ProfileViewPresenterProtocol {

    var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled = false
    var didTapLogoutCalled = false
    var didConfirmLogoutCalled = false

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func didTapLogout() {
        didTapLogoutCalled = true
    }

    func didConfirmLogout() {
        didConfirmLogoutCalled = true
    }
}

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {

    var presenter: ProfileViewPresenterProtocol?

    var updateProfileCalled = false
    var updateAvatarCalled = false
    var showLogoutConfirmationCalled = false
    var switchToSplashCalled = false

    func updateProfile(name: String, username: String, bio: String) {
        updateProfileCalled = true
    }

    func updateAvatar(url: URL?) {
        updateAvatarCalled = true
    }

    func showLogoutConfirmation() {
        showLogoutConfirmationCalled = true
    }

    func switchToSplash() {
        switchToSplashCalled = true
    }
}
