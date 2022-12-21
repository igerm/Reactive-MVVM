import APIServiceMock
import APIService
import Combine
import CoreDataService
import XCTest
@testable import MarvelService

final class MarvelServiceLiveTests: XCTestCase {

    var cancellables: Set<AnyCancellable> = []

    override func tearDown() {
        cancellables.removeAll()
    }

    func inMemoryCoreDataService() -> CoreDataService {
        CoreDataService(
            modelName: "Model",
            modelBundle: .marvelServiceBundle,
            inMemoryStore: true
        )
    }

    func testCharacterByID_onEmptyDatabase() throws {

        // dependencies
        let apiService = APIServiceMock()
        let coreDataService = inMemoryCoreDataService()

        // sut
        let sut = MarvelServiceLive(apiService: apiService, coreDataService: coreDataService)

        let valueExpectation = expectation(description: "first value update")
        //let secondValueExpectation = expectation(description: "second value update")

        var observedCharacters = [Character]()
        sut.character(id: 1009268, refreshData: true)
            .sink { completion in
            } receiveValue: { character in
                observedCharacters.append(character)
                valueExpectation.fulfill()
            }
            .store(in: &cancellables)

        // fulfill with mock data
        apiService.dataPublisher.fulfill(.success(Files.characterByIDResponseJson.data))

        wait(for: [valueExpectation], timeout: 1)

        XCTAssertEqual(observedCharacters[0].id, 1009268)
    }

    @available(iOS 15.0, *)
    func testCharacterByID_onNonEmptyDatabase() throws {

        // dependencies
        let apiService = APIServiceMock()
        let coreDataService = inMemoryCoreDataService()

        // prefill coreData
        let response = try JSONDecoder.marvel.decode(Response<CharacterRemote>.self, from: Files.characterByIDResponse2Json.data)
        let char = try XCTUnwrap(response.data.results.first)
        let ctx = coreDataService.newBackgroundContext()
        try ctx.performAndWait {
            _ = try char.update(ctx)
            try ctx.save()
        }

        // sut
        let sut = MarvelServiceLive(apiService: apiService, coreDataService: coreDataService)

        let valueExpectation1 = expectation(description: "first value update")
        let valueExpectation2 = expectation(description: "second value update")

        var observedCharacters = [Character]()
        sut.character(id: 1009268, refreshData: true)
            .sink { completion in
            } receiveValue: { character in
                observedCharacters.append(character)
                switch observedCharacters.count {
                case 1: valueExpectation1.fulfill()
                case 2: valueExpectation2.fulfill()
                default: break
                }
            }
            .store(in: &cancellables)

        wait(for: [valueExpectation1], timeout: 1)

        // fulfill with mock data
        apiService.dataPublisher.fulfill(.success(Files.characterByIDResponseJson.data))

        wait(for: [valueExpectation2], timeout: 1)

        XCTAssertEqual(observedCharacters[0].id, 1009268)
        XCTAssertEqual(observedCharacters[0].name, "Deadpoool")
        XCTAssertEqual(observedCharacters[1].id, 1009268)
        XCTAssertEqual(observedCharacters[1].name, "Deadpool")
    }

    func testSearchCharacters() throws {

        // dependencies
        let apiService = APIServiceMock()
        let coreDataService = inMemoryCoreDataService()

        // sut
        let sut = MarvelServiceLive(apiService: apiService, coreDataService: coreDataService)

        let expectation = expectation(description: "get value")
        expectation.expectedFulfillmentCount = 1

        var characters: [Character]?

        sut.searchCharacters(name: "hulk")
            .sink { completion in
            } receiveValue: { c in
                characters = c
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // fulfill with mock data
        apiService.dataPublisher.fulfill(.success(Files.charactersResponseJson.data))

        wait(for: [expectation], timeout: 2)

        XCTAssert(characters?.first?.name == "Hulk")
    }

    @available(iOS 15.0, *)
    func testFavorites() throws {

        // dependencies
        let apiService = APIServiceMock()
        let coreDataService = inMemoryCoreDataService()

        // sut
        let sut = MarvelServiceLive(apiService: apiService, coreDataService: coreDataService)

        let value0Expectation = expectation(description: "context 0 update")
        let value1Expectation = expectation(description: "context 1 update")
        let value2Expectation = expectation(description: "context 2 update")
        let value3Expectation = expectation(description: "context 3 update")

        var events: [[Character]] = []

        sut.favoriteCharacters()
            .sink { completion in
            } receiveValue: { value in
                switch events.count {
                case 0: value0Expectation.fulfill()
                case 1: value1Expectation.fulfill()
                case 2: value2Expectation.fulfill()
                case 3: value3Expectation.fulfill()
                default: break
                }
                events.append(value)
            }
            .store(in: &cancellables)

        wait(for: [value0Expectation], timeout: 1)

        let context = coreDataService.newBackgroundContext()
        try context.performAndWait {
            let mo = try CharacterRemote(
                id: 10, name: "Hulk", characterDescription: "rawr",
                resourceURI: "a", modified: Date(), urls: [],
                thumbnail: .empty,
                comics: .empty,
                stories: .empty,
                events: .empty,
                series: .empty
            ).update(context) as? CharacterMO
            mo?.isFavorite = true
            try context.save()
        }

        wait(for: [value1Expectation], timeout: 1)

        let context2 = coreDataService.newBackgroundContext()
        try context2.performAndWait {
            let _ = try CharacterRemote(
                id: 10, name: "Hulk", characterDescription: "rawr2",
                resourceURI: "a", modified: Date(), urls: [],
                thumbnail: .empty,
                comics: .empty,
                stories: .empty,
                events: .empty,
                series: .empty
            ).update(context2) as? CharacterMO
            print("context2")
            try context2.save()
        }

        wait(for: [value2Expectation], timeout: 1)

        let context3 = coreDataService.newBackgroundContext()
        try context3.performAndWait {
            let request = CharacterMO.fetchRequest()
            request.predicate = NSPredicate(format: "id == %d", 10)
            if let character = try context3.fetch(request).first {
                context3.delete(character)
            }
            print("context3")
            try context3.save()
        }

        wait(for: [value3Expectation], timeout: 1)

        XCTAssertEqual(events.count, 4)

        XCTAssertTrue(events[0].isEmpty)
        XCTAssertEqual(events[1].first?.characterDescription, "rawr")
        XCTAssertEqual(events[1].first?.isFavorite, true)
        XCTAssertEqual(events[2].first?.characterDescription, "rawr2")
        XCTAssertEqual(events[2].first?.isFavorite, true)
        XCTAssertEqual(events[3], [])
    }

    func testAPIRequest() throws {

        // dependencies
        let apiService = URLSessionAPIService()
        let coreDataService = inMemoryCoreDataService()

        // sut
        let sut = MarvelServiceLive(apiService: apiService, coreDataService: coreDataService)

        let expectation = expectation(description: "value expectation")

        var observedCharacters: [Character]?
        sut.searchCharacters(name: "Hulk")
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    print("Error found: \(error.localizedDescription)")
                    expectation.fulfill()
                }
            } receiveValue: { characters in
                observedCharacters = characters
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 10)

        let character = try XCTUnwrap(observedCharacters)
        XCTAssertEqual(character.first?.name, "Hulk")

    }
}
