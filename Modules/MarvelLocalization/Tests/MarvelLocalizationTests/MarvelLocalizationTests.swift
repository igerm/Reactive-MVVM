import Combine
import XCTest
@testable import MarvelLocalization

final class MarvelLocalizationTests: XCTestCase {
    func test() throws {

        XCTAssertEqual(L10n.Characters.title, "Characters")
        XCTAssertEqual(L10n.Characters.Cell.StoriesLabel.count(0), "0 stories")
        XCTAssertEqual(L10n.Characters.Cell.StoriesLabel.count(1), "1 story")
        XCTAssertEqual(L10n.Characters.Cell.StoriesLabel.count(2), "2 stories")
    }
}
