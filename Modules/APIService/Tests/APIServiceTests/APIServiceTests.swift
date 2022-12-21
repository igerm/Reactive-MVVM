import Combine
import XCTest
@testable import APIService

final class URLSessionAPIServiceTests: XCTestCase {

    var cancellable: AnyCancellable?

    func testExample() throws {
        let sut = URLSessionAPIService()

        let getDataExpectation = expectation(description: "Get data")
        let completeExpectation = expectation(description: "Complete")

        cancellable = sut
            .dataPublisher(for: .init(method: .get, baseURL: "https://www.google.com", path: ""))
            .sink { completion in
                completeExpectation.fulfill()
            } receiveValue: { _ in
                getDataExpectation.fulfill()
            }

        wait(for: [getDataExpectation, completeExpectation], timeout: 10)

        cancellable = nil
    }
}
