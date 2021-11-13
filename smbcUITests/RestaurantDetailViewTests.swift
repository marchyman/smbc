//
//  RestaurantDetailViewTests.swift
//  smbcUITests
//
//  Created by Marco S Hyman on 11/12/21.
//  Copyright © 2021 Marco S Hyman. All rights reserved.
//

import XCTest

class RestaurantDetailViewTests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        let smbcImage = app.images["smbc"]
        XCTAssert(smbcImage.exists)
        smbcImage.tap()

        // If the test is run after the last ride of the year tapping on the image
        // will bring up the ride list instead of the next ride.  Check for that
        // here.
        XCTAssertFalse(app.buttons["Change year"].exists)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // test that some of the expected user interface elements exist on the screen
    // The nav bar butters were tested as part of  ContentViewTests
    //
    func testUIElements() throws {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

}
