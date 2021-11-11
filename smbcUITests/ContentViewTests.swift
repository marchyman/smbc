//
//  smbcUITests.swift
//  smbcUITests
//
//  Created by Marco S Hyman on 6/22/19.
//  Copyright © 2019 Marco S Hyman. All rights reserved.
//

import XCTest

class ContentViewTests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    /// Test that all the elements that make up the content view exist
    ///
    func testContentViewElements() {
        let homePageButton =
            app.buttons["Sunday Morning Breakfast Club\nBreakfast and beyond since 1949"]
        XCTAssert(homePageButton.exists)

        let infoButton = app.navigationBars["SMBC"].buttons["Info"]
        XCTAssert(infoButton.exists)

        let restaurantsButton = app.buttons["Restaurants"]
        XCTAssert(restaurantsButton.exists)

        let ridesButton = app.buttons["Rides"]
        XCTAssert(ridesButton.exists)

        let smbcImage = app.images["smbc"]
        XCTAssert(smbcImage.exists)
    }

    func testInfoButton() {
        let infoButton = app.navigationBars["SMBC"].buttons["Info"]
        infoButton.tap()
        XCTAssert(app.staticTexts["SMBC Information"].exists)
        let gotIt = app.buttons["Got It!"]
        XCTAssert(gotIt.exists)
        gotIt.tap()
    }

    func testRestaurantsButton() {
        let restaurantsButton = app.buttons["Restaurants"]
        restaurantsButton.tap()
        if app.buttons["Show All"].exists {
            XCTAssert(app.staticTexts["Active Restaurants"].exists)
            app.buttons["Show All"].tap()
            XCTAssert(app.staticTexts["All Restaurants"].exists)
        } else {
            XCTAssert(app.staticTexts["All Restaurants"].exists)
            app.buttons["Show Active"].tap()
            XCTAssert(app.staticTexts["Active Restaurants"].exists)
        }
        let backButton = app.buttons["SMBC"]
        XCTAssert(backButton.exists)
        backButton.tap()
        XCTAssert(restaurantsButton.exists)
    }

    func testRidesButton() {
        let ridesButton = app.buttons["Rides"]
        ridesButton.tap()
        XCTAssert(app.buttons["Change year"].exists)
        XCTAssert(app.buttons["Show next ride"].exists)
        let backButton = app.buttons["SMBC"]
        XCTAssert(backButton.exists)
        backButton.tap()
        XCTAssert(ridesButton.exists)
    }

    func testSmbcImage() {
        let smbcImage = app.images["smbc"]

        // first check for a tap on the image
        smbcImage.tap()
        XCTAssert(app.buttons["Show Visits"].exists)
        XCTAssert(app.buttons["Next ride"].exists)
        let backButton = app.buttons["SMBC"]
        XCTAssert(backButton.exists)
        backButton.tap()
        XCTAssert(smbcImage.exists)

        // now check for a long press on the image
        smbcImage.press(forDuration: 3.0)
        XCTAssert(app.staticTexts["Data refresh"].exists)
        let ok = app.buttons["OK"]
        XCTAssert(ok.exists)
        ok.tap()
        XCTAssertFalse(ok.exists)
        XCTAssert(smbcImage.exists)
    }

}
