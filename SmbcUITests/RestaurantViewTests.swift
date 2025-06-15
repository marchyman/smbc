//
// Copyright 2025 Marco S Hyman
// https://www.snafu.org/
//

import XCTest

@MainActor
final class RestaurantViewTests: XCTestCase {
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

    func testRestaurantViews() {
        app = XCUIApplication()
        app.launch()

        XCTAssert(app.descendants(matching: .any)
            .matching(identifier: "TabView").element.exists)

        // make sure the Restaurants tab is selected
        XCTAssert(app.buttons["Restaurants"].exists)
        app.buttons["Restaurants"].tap()
        XCTAssert(app.buttons["Restaurants"].isSelected)
        takeScreenshot(name: "Restaurants Tab")

        // Nav bar should default to active restaurants
        // verify the app can switch back and forth between active
        // and all restaurants
        XCTAssert(app.navigationBars["Active Restaurants"].exists)
        XCTAssert(app.buttons["Show All"].exists)
        app.buttons["Show All"].tap()
        XCTAssert(app.buttons["Show Active"].exists)
        app.buttons["Show Active"].tap()

        // find the first restaurant and tap on it
        let restaurants = app.collectionViews.element(boundBy: 0)
        XCTAssert(restaurants.exists)
        let someRestaurant = restaurants.buttons.element(boundBy: 0)
        XCTAssert(someRestaurant.exists)
        someRestaurant.tap()
        sleep(1)

        // Verify various elements exist
        XCTAssert(app.buttons["Active Restaurants"].exists)
        XCTAssert(app.buttons["Show Visits"].exists)
        XCTAssert(app.buttons["Change Map Style"].exists)

        // show the visits for this restaurant
        app.buttons["Show Visits"].tap()
        XCTAssert(app.buttons["Done"].exists)
        app.buttons["Done"].tap()

        // return to the list of restaurants
        app.buttons["Active Restaurants"].tap()
    }

    func testRestaurantLookaround() {
        app = XCUIApplication()
        app.launch()

        // make sure the Restaurants tab is selected
        XCTAssert(app.buttons["Restaurants"].exists)
        app.buttons["Restaurants"].tap()
        XCTAssert(app.buttons["Restaurants"].isSelected)

        // find the first restaurant and tap on it
        let restaurants = app.collectionViews.element(boundBy: 0)
        XCTAssert(restaurants.exists)
        let someRestaurant = restaurants.buttons.element(boundBy: 0)
        XCTAssert(someRestaurant.exists)
        someRestaurant.tap()

        // find the annotation container in the map
        XCTAssert(app.maps.element.exists)
        let annotation = app.otherElements["AnnotationContainer"]
        XCTAssert(annotation.exists)
        let marker = annotation.otherElements.element
        XCTAssert(marker.exists)
        marker.tap()
        // The not available warning is always preset, but hidden with
        // opacity 0 when a lookaround scene exists.
        XCTAssert(app.staticTexts["lookaround"].waitForExistence(timeout: 1))
    }
}
