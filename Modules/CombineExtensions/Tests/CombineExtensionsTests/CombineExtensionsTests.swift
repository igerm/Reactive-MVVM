import Combine
import XCTest
@testable import CombineExtensions

final class CombineServiceExtensionsTests: XCTestCase {
    func testErasingJustAsFuture() throws {

        let valueExpectation = expectation(description: "wait value")
        var observedValue: Int?
        let _ = Just(6)
            .eraseToFuture()
            .sink { value in
                observedValue = value
                valueExpectation.fulfill()
            }

        wait(for: [valueExpectation], timeout: 0.1)
        XCTAssertEqual(observedValue, 6)
    }
}
