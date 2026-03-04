//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Aleksey on 12.04.2025.
//

import XCTest

final class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAuth() throws {
        app.buttons["Authenticate"].tap()

        let webView = app.webViews["UnsplashWebView"]

        XCTAssertTrue(webView.waitForExistence(timeout: 5))

        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 10))

        loginTextField.tap()
        loginTextField.typeText("<Ваш e-mail>")
        app.buttons["Next"].tap()

        let passwordTextField = webView.descendants(matching: .secureTextField)
            .element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))

        passwordTextField.tap()
        passwordTextField.typeText("<Ваш пароль>")
        webView.swipeUp()

        webView.buttons["Login"].tap()

        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)

        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }

    func testFeed() throws {
        let table = app.tables.firstMatch
        XCTAssertTrue(table.waitForExistence(timeout: 5))
        table.swipeUp()
        
        // ищем кнопку лайка

        let likeButton = table.buttons["likeButton"].firstMatch
        XCTAssertTrue(likeButton.waitForExistence(timeout: 5))
        likeButton.tap()
        likeButton.tap()

        // открыть картинку
        table.cells.firstMatch.tap()

        let image = app.scrollViews.images.firstMatch
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)

        app.buttons["navBack"].tap()
    }

    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()

        XCTAssertTrue(app.staticTexts["Petrovich Petrovich"].exists)
        XCTAssertTrue(app.staticTexts["@liocha_"].exists)

        app.buttons["logout button"].tap()

        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Выйти"]
            .tap()
    }
    
}
