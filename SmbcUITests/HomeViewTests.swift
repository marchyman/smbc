//
// Copyright 2025 Marco S Hyman
// https://www.snafu.org/
//

import XCTest

@MainActor
final class HomeViewTests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation
        // of each test method in the class.

        // In UI tests it is usually best to stop immediately when a
        // failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as
        // interface orientation - required for your tests before they run.
        // The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func takeScreenshot(name: String) {
        let screenshot = app.windows.firstMatch.screenshot()

        let attachment =
            XCTAttachment(uniformTypeIdentifier: "public.png",
                          name: "\(name).png",
                          payload: screenshot.pngRepresentation,
                          userInfo: nil)
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testHomeView() {
        app = XCUIApplication()
        app.launch()

        XCTAssert(app.descendants(matching: .any)
            .matching(identifier: "TabView").element.exists)

        // make sure the home tab is selected
        XCTAssert(app.buttons["Home"].exists)
        app.buttons["Home"].tap()
        XCTAssert(app.buttons["Home"].isSelected)
        takeScreenshot(name: "Home Tab")

        // check the info button
        XCTAssert(app.buttons["info"].exists)
        app.buttons["info"].tap()
        XCTAssert(app.staticTexts["SMBC Information"].exists)
        XCTAssert(app.buttons["gotit"].exists)
        takeScreenshot(name: "SMBC Info")
        app.buttons["gotit"].firstMatch.tap()

        // check the help button
        XCTAssert(app.buttons["help"].exists)
        app.buttons["help"].tap()
        XCTAssert(app.staticTexts["Application Help"].exists)
        XCTAssert(app.buttons["OK"].exists)
        takeScreenshot(name: "SMBC Help")
        app.buttons["OK"].tap()

        // check the hidden log button
        XCTAssert(app.staticTexts["smbc link"].exists)
        app.staticTexts["smbc link"].press(forDuration: 1.0)
        XCTAssert(app.buttons["log dismiss"].exists)
        app.buttons["log dismiss"].tap()

        // check that various items exist
        XCTAssert(app.navigationBars["SMBC"].exists)
        XCTAssert(app.images["smbc"].exists)

        // tapping on the link to the smbc web site, the image to show the
        // next ride, or long pressing the image to force data refresh need
        // to be checked by hand.
    }
}
