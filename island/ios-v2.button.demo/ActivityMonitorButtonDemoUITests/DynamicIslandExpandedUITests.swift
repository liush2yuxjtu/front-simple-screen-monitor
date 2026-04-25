import XCTest

final class DynamicIslandExpandedUITests: XCTestCase {
    func testExpandedDynamicIslandShowsDecisionButtons() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--recording-demo"]
        app.launch()
        sleep(2)

        XCUIDevice.shared.press(.home)
        sleep(1)

        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let island = springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.045))
        island.press(forDuration: 1.5)
        sleep(2)

        let allowExists = springboard.buttons["ALLOW"].exists || springboard.staticTexts["ALLOW"].exists
        let blockExists = springboard.buttons["BLOCK"].exists || springboard.staticTexts["BLOCK"].exists
        XCTAssertTrue(allowExists, "Expanded Dynamic Island should expose ALLOW")
        XCTAssertTrue(blockExists, "Expanded Dynamic Island should expose BLOCK")
    }
}
