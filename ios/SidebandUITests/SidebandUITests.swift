import XCTest
final class SidebandUITests: XCTestCase {
    func testDemoLaunchAndEvidence() throws {
        let app = XCUIApplication(); app.launch()
        XCTAssertTrue(app.buttons["Start listening"].waitForExistence(timeout: 10))
        app.buttons["Start listening"].tap()
        XCTAssertTrue(app.buttons["Stop listening"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Demo running. These signals are simulated."].exists)
        let shot = XCTAttachment(screenshot: app.screenshot()); shot.name = "Sideband iPhone demo"; shot.lifetime = .keepAlways; add(shot)
        app.buttons["Stop listening"].tap()
        XCTAssertTrue(app.buttons["Start listening"].exists)
    }
}
