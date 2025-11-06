//
// Copyright 2025 Marco S Hyman
// https://www.snafu.org/
//

import XCTest

@MainActor
final class RideViewsTests: XCTestCase {
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

    func rideDetails() {
        // various elements that should be part of the ride detail view
        XCTAssert(app.buttons["Show Visits"].waitForExistence(timeout: 1))
        XCTAssert(app.maps.element.exists)
        let annotation = app.otherElements["AnnotationContainer"]
        XCTAssert(annotation.exists)
        let marker = annotation.otherElements.element
        XCTAssert(marker.exists)
    }

    func testRideListView() {
        app = XCUIApplication()
        app.launch()

        XCTAssert(app.descendants(matching: .any)
            .matching(identifier: "TabView").element.exists)

        // make sure the Rides tab is selected
        XCTAssert(app.buttons["Rides"].exists)
        app.buttons["Rides"].tap()
        XCTAssert(app.buttons["Rides"].isSelected)
        takeScreenshot(name: "Rides Tab")

        // find the second ride and tap on it.
        // The first ride might be at the very top of the screen and not
        // be tapable.
        let rides = app.collectionViews.element(boundBy: 1)
        XCTAssert(rides.exists)
        let someRide = rides.buttons.element(boundBy: 1)
        XCTAssert(someRide.exists)
        someRide.tap()
        rideDetails()
    }

    func testNextRide() {
        app = XCUIApplication()
        app.launch()

        XCTAssert(app.images["smbc"].exists)
        app.images["smbc"].tap()
        rideDetails()
        takeScreenshot(name: "Ride Detail")
    }

    func testChangeYear() {
        app = XCUIApplication()
        app.launch()

        // make sure the Rides tab is selected
        XCTAssert(app.buttons["Rides"].exists)
        app.buttons["Rides"].tap()
        XCTAssert(app.buttons["Rides"].isSelected)

        // Check the change year button and resulting picker
        XCTAssert(app.buttons["Change year"].exists)
        app.buttons["Change year"].tap()
        let picker = app.pickers["Pick desired year"]
        XCTAssert(picker.exists)

        // pick the previous year
        let today = Date.now
        let thisYear = Calendar.current.component(.year, from: today)
        let thisYearString = thisYear.formatted(.number.grouping(.never))
        let prevYear = thisYear - 1
        let prevYearString = prevYear.formatted(.number.grouping(.never))

        XCTAssert(app.pickerWheels[thisYearString].exists)
        app.pickerWheels.firstMatch.adjust(toPickerWheelValue: prevYearString)

        XCTAssert(app.pickerWheels[prevYearString].exists)
        app.pickerWheels[prevYearString].tap()
        app.buttons["Done"].tap()

        // Verify data for prevYear loaded
        XCTAssert(app.navigationBars["SMBC Rides in \(prevYearString)"].waitForExistence(timeout: 1))

        // rides for the current year should be loaded whenever the home
        // view is selected

        XCTAssert(app.buttons["Home"].exists)
        app.buttons["Home"].tap()
        XCTAssert(app.buttons["Home"].isSelected)
        app.buttons["Rides"].tap()
        XCTAssert(app.buttons["Rides"].isSelected)
        XCTAssert(app.navigationBars["SMBC Rides in \(thisYearString)"].waitForExistence(timeout: 1))
    }
}
