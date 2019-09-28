import XCTest
@testable import RxNetworkClient

final class RxNetworkClientTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(RxNetworkClient().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
