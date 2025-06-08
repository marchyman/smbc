//
// Copyright 2025 Marco S Hyman
// https://www.snafu.org/
//

import XCTest

@MainActor
final class ContentViewTests: XCTestCase {
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

    func testTabs() {
        app = XCUIApplication()
        app.launch()
        takeScreenshot(name: "Initial Launch")

        XCTAssert(app.descendants(matching: .any)
            .matching(identifier: "TabView").element.exists)

        let tabs = [ "Home", "Restaurants", "Rides", "Gallery" ]
        for tab in tabs {
            XCTAssert(app.buttons[tab].exists)
        }
    }

    func testReloadError() {
        app = XCUIApplication()
        app.launchEnvironment = ["RELOADERRORTEST": "1"]
        app.launch()

        let alert = app.alerts["Reload Error"]
        XCTAssert(alert.exists)
        let ok = alert.buttons["OK"]
        XCTAssert(ok.exists)
        ok.tap()
        XCTAssert(!alert.exists)
    }

    func testNextRide() {
        app = XCUIApplication()
        app.launchEnvironment = ["NEXTRIDETEST": "1"]
        app.launch()

        let selected = app.buttons["Rides"]
        XCTAssert(selected.isSelected)
    }
}
