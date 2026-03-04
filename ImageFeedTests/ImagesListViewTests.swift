import Foundation
import Testing
import XCTest

@testable import ImageFeed

final class ImagesListViewTests: XCTestCase {

    func testViewDidLoadUpdatesView() {
        let viewSpy = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenter()

        presenter.view = viewSpy

        presenter.viewDidLoad()

        XCTAssertTrue(viewSpy.insertRowsCalled || viewSpy.reloadDataCalled)
    }
}

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {

    var presenter: ImagesListPresenterProtocol?

    var reloadDataCalled = false
    var insertRowsCalled = false
    var updateLikeCalled = false
    var showErrorCalled = false

    func reloadData() {
        reloadDataCalled = true
    }

    func insertRows(at indexPaths: [IndexPath]) {
        insertRowsCalled = true
    }

    func showError(message: String) {
        showErrorCalled = true
    }

    func updateLike(at indexPath: IndexPath) {
        updateLikeCalled = true
    }
}
