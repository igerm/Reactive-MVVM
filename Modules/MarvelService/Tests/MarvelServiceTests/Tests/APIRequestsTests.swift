import XCTest
@testable import MarvelService

final class APIRequestsTests: XCTestCase {

    func testMD5Hash() throws {

        let date = Date(timeIntervalSinceReferenceDate: 0)
        let hash = MarvelAPIRequests.hash(ts: "\(date)", apiKey: "normalApiKey", privateKey: "privateApiKey")

        XCTAssertEqual(hash, "88de002e6e827f908ca8fcf0f3807f9b")
    }
}
