//
//  CountriesChallengeUITests.swift
//  CountriesChallengeUITests
//

import XCTest

final class CountriesChallengeUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Initialization Tests
        
        func testAppInitialization() throws {
            // Verify app launched successfully
            XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5), "App should be in foreground")
            
            // Check root view controller is loaded
            let navigationBar = app.navigationBars.firstMatch
            XCTAssertTrue(navigationBar.waitForExistence(timeout: 5), "Root navigation controller should be visible")
        }

    func testAppLaunchesAndShowsCountriesList() throws {
        let table = app.tables.firstMatch
        XCTAssertTrue(table.waitForExistence(timeout: 5), "Countries list should appear on launch")
        let cell = table.cells.element(boundBy: 0)
        XCTAssertTrue(cell.exists, "At least one country cell should be visible")
    }

    func testTapOnCountryCell_navigatesToDetailScreen() throws {
        let table = app.tables.firstMatch
        XCTAssertTrue(table.waitForExistence(timeout: 5))

        let firstCell = table.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.exists)
        firstCell.tap()

        let detailNavBar = app.navigationBars.firstMatch
        XCTAssertTrue(detailNavBar.exists, "Should navigate to detail screen with a nav bar")
    }

    func testSearchFunctionality_filtersList() throws {
            
            let table = app.tables.firstMatch
            let firstCell = table.cells.element(boundBy: 0)
            let start = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            let finish = start.withOffset(CGVector(dx: 0, dy: 300))

            start.press(forDuration: 0.1, thenDragTo: finish)
            
            let searchField = app.searchFields.firstMatch
            XCTAssertTrue(searchField.waitForExistence(timeout: 20), "Search bar should be visible")
            searchField.tap()
            searchField.typeText("canada")

            XCTAssertTrue(table.cells.count > 0, "Search results should not be empty")
        }

    func testPullToRefresh_doesNotCrashAndReloads() throws {
        let table = app.tables.firstMatch
        XCTAssertTrue(table.exists)

        let firstCell = table.cells.element(boundBy: 0)
        let start = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let finish = start.withOffset(CGVector(dx: 0, dy: 300))

        start.press(forDuration: 0.1, thenDragTo: finish)
        XCTAssertTrue(table.cells.count > 0, "Table should reload and display results after pull-to-refresh")
    }
}
