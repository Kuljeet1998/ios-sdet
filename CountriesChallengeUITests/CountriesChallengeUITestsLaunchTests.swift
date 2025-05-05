//
//  CountriesChallengeUITestsLaunchTests.swift
//  CountriesChallengeUITests
//

import XCTest

final class CountriesChallengeUITestsLaunchTests: XCTestCase {
    
    // Properties for test data
    let validUsername = "testuser"
    let validPassword = "password123"
    let invalidUsername = "wronguser"
    let invalidPassword = "wrongpass"
    
    /// This ensures the test runs for each UI configuration (e.g., light/dark mode, different locales)
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }
    
    override func setUpWithError() throws {
        // Stop immediately when a failure occurs
        continueAfterFailure = false
    }
    
    /// Tests that the app launches and captures a screenshot of the launch screen
    func testLaunchAndCaptureScreenshot() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Capture screenshot of the launch screen
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    /// Tests the login functionality with valid credentials
}
