import Combine
import XCTest
@testable import MarvelApp
import MarvelService
import MarvelServiceMock

final class CharactersViewModelTests: XCTestCase {

    func testInitialLoad() throws {
        let mock = MarvelServiceMock()
        let sut = CharactersViewModel(marvelService: mock)

        sut.onAppear()

        XCTAssertEqual(sut.title, "Characters")
        XCTAssertEqual(sut.sections.count, 1)
        XCTAssertEqual(sut.sections.first?.rowViewModels.count, 0)
        XCTAssertNil(sut.dialogViewModel)
        XCTAssertEqual(sut.isLoading, true)
        XCTAssertEqual(sut.sortBySelection, CharactersSortBy.name)
        XCTAssertEqual(sut.sortBy, [CharactersSortBy.name, CharactersSortBy.recent])

        mock.searchCharactersByNameSubject.value = testCharacters

        wait()

        XCTAssertEqual(sut.isLoading, false)
        XCTAssertEqual(sut.sections.count, 1)
        XCTAssertEqual(sut.sections.first?.rowViewModels.count, 2)
    }

    func testLoadFailure() throws {
        let mock = MarvelServiceMock()
        let sut = CharactersViewModel(marvelService: mock)

        enum TestError: Error { case someError }

        sut.onAppear()
        mock.searchCharactersByNameSubject.send(completion: .failure(TestError.someError))

        wait()

        XCTAssertNotNil(sut.dialogViewModel)
        XCTAssertEqual(sut.sections.count, 1)
        XCTAssertEqual(sut.sections.first?.rowViewModels.count, 0)
        XCTAssertEqual(sut.isLoading, false)
    }

    func testTappingRow() throws {
        let mock = MarvelServiceMock()
        mock.searchCharactersByNameSubject.value = testCharacters
        let sut = CharactersViewModel(marvelService: mock)

        var characterIDToShowEvents = [Int64]()
        sut.showCharacter = { id in
            characterIDToShowEvents.append(id)
        }

        sut.onAppear()

        wait()

        XCTAssertEqual(sut.sections.count, 1)
        XCTAssertEqual(sut.sections.first?.rowViewModels.count, 2)
        let firstRow = try XCTUnwrap(sut.sections.first?.rowViewModels.first)

        sut.didSelect(firstRow)

        XCTAssertEqual(characterIDToShowEvents.count, 1)
        XCTAssertEqual(characterIDToShowEvents.first, 1) // id 1, because it's sorted by name
    }

    func testSortingByName() throws {
        let mock = MarvelServiceMock()
        mock.searchCharactersByNameSubject.value = testCharacters
        let sut = CharactersViewModel(marvelService: mock)
        sut.onAppear()
        sut.sortBySelection = .name
        wait()
        XCTAssertEqual(sut.sections.count, 1)
        XCTAssertEqual(sut.sections.first?.rowViewModels.count, 2)
        XCTAssertEqual(sut.sections.first?.rowViewModels[0].characterID, 1)
        XCTAssertEqual(sut.sections.first?.rowViewModels[1].characterID, 0)
    }

    func testSortingByModified() throws {
        let mock = MarvelServiceMock()
        mock.searchCharactersByNameSubject.value = testCharacters
        let sut = CharactersViewModel(marvelService: mock)
        sut.onAppear()
        sut.sortBySelection = .recent
        wait()
        XCTAssertEqual(sut.sections.count, 1)
        XCTAssertEqual(sut.sections.first?.rowViewModels.count, 2)
        XCTAssertEqual(sut.sections.first?.rowViewModels[0].characterID, 0)
        XCTAssertEqual(sut.sections.first?.rowViewModels[1].characterID, 1)
    }

    var testCharacters: [Character] {
        [
            Character(
                id: 0,
                name: "Zero",
                characterDescription: "Zero character",
                modified: Date.init(timeIntervalSince1970: 0),
                stories: .init(available: 2, returned: 2, collectionURI: "", items: []),
                events: .init(available: 2, returned: 2, collectionURI: "", items: []),
                thumbnail: .empty,
                isFavorite: false
            ),
            Character(
                id: 1,
                name: "Prime",
                characterDescription: "First character",
                modified: Date.init(timeIntervalSince1970: -1),
                stories: .init(available: 1, returned: 1, collectionURI: "", items: []),
                events: .init(available: 1, returned: 1, collectionURI: "", items: []),
                thumbnail: .empty,
                isFavorite: true
            )
        ]
    }
}

extension XCTestCase {

    func wait(seconds: TimeInterval = 0.001) {
        let expectation = XCTestExpectation(description: "Wait")

        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: seconds + 1.0)
    }

    func awaitPublisher<T: Publisher>(
        _ publisher: T,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> T.Output {
        // This time, we use Swift's Result type to keep track
        // of the result of our Combine pipeline:
        var result: Result<T.Output, Error>?
        let expectation = self.expectation(description: "Awaiting publisher")

        let cancellable = publisher.sink(
            receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    result = .failure(error)
                case .finished:
                    break
                }

                expectation.fulfill()
            },
            receiveValue: { value in
                result = .success(value)
            }
        )

        // Just like before, we await the expectation that we
        // created at the top of our test, and once done, we
        // also cancel our cancellable to avoid getting any
        // unused variable warnings:
        waitForExpectations(timeout: timeout)
        cancellable.cancel()

        // Here we pass the original file and line number that
        // our utility was called at, to tell XCTest to report
        // any encountered errors at that original call site:
        let unwrappedResult = try XCTUnwrap(
            result,
            "Awaited publisher did not produce any output",
            file: file,
            line: line
        )

        return try unwrappedResult.get()
    }
}
