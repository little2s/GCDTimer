import XCTest
@testable import GCDTimer

final class GCDTimerTests: XCTestCase {
    func testExample() {
        let expectation = XCTestExpectation()
        let timer = GCDTimer(timeout: 1, repeat: false, queue: .main, completion: {
            XCTAssert(true)
            expectation.fulfill()
        })
        timer.start()
        wait(for: [expectation], timeout: 2)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
