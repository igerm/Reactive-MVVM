import XCTest
@testable import MarvelApp

final class AppModelTests: XCTestCase {

    func testInitialScreen() throws {
        let diContainer = TestDIContainer()
        let sut = AppModel(diContainer: diContainer)

        XCTAssertEqual(sut.tabs.count, 3)
        XCTAssertEqual(sut.tabs[0].id, "characters")
        XCTAssertEqual(sut.tabs[1].id, "events")
        XCTAssertEqual(sut.tabs[2].id, "favorites")
        XCTAssertEqual(sut.selection, 0)
        XCTAssertNil(sut.present)
    }

    func testCharactersListPresentCharacter() throws {
        let diContainer = TestDIContainer()
        let sut = AppModel(diContainer: diContainer)

        guard case .characters(let viewModel) = sut.tabs[0] else {
            XCTFail("Couldnt get characters view model")
            return
        }
        // present a character
        viewModel.showCharacter?(10)

        let presentedScreen = try XCTUnwrap(sut.present)

        guard case .character(let viewModel) = presentedScreen else {
            XCTFail("Couldnt get character view model")
            return
        }

        XCTAssertEqual(viewModel.characterID, 10)
    }

    func testEventsPresentCharacter() throws {
        let diContainer = TestDIContainer()
        let sut = AppModel(diContainer: diContainer)

        guard case .events(let viewModel) = sut.tabs[1] else {
            XCTFail("Couldnt get characters view model")
            return
        }
        // present a character
        viewModel.showCharacter?(10)

        let presentedScreen = try XCTUnwrap(sut.present)

        guard case .character(let viewModel) = presentedScreen else {
            XCTFail("Couldnt get character view model")
            return
        }

        XCTAssertEqual(viewModel.characterID, 10)
    }

    func testFavoritesPresentCharacter() throws {
        let diContainer = TestDIContainer()
        let sut = AppModel(diContainer: diContainer)

        guard case .favorites(let viewModel) = sut.tabs[2] else {
            XCTFail("Couldnt get characters view model")
            return
        }
        // present a character
        viewModel.showCharacter?(10)

        let presentedScreen = try XCTUnwrap(sut.present)

        guard case .character(let viewModel) = presentedScreen else {
            XCTFail("Couldnt get character view model")
            return
        }

        XCTAssertEqual(viewModel.characterID, 10)
    }
}

import APIService
import APIServiceMock
import MarvelService
import MarvelServiceMock

final class TestDIContainer: SwinjectDIContainer {

    override init() {
        super.init()
        register(APIService.self) { container in
            APIServiceMock()
        }
        register(MarvelService.self) { container in
            MarvelServiceMock()
        }
    }
}
