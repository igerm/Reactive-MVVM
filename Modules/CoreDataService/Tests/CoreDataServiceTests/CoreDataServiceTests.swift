import Combine
import CoreData
import XCTest
@testable import CoreDataService

@available(macOS 12.0, *)
final class CoreDataServiceTests: XCTestCase {

    var cancellables: Set<AnyCancellable> = []

    override func tearDown() {
        cancellables.removeAll()
    }

    func testObserving_adding() throws {

        let coreDataService = CoreDataService(modelName: "TestModel", modelBundle: .module, inMemoryStore: true)

        var observedEntities: [[TestEntity]] = []

        let expectation = expectation(description: "get values")
        expectation.expectedFulfillmentCount = 2

        coreDataService
            .observe(type: TestEntity.self, predicate: nil, sortDescriptors: [.init(key: "id", ascending: true)])
            .sink { _ in

            } receiveValue: { chars in
                observedEntities.append(chars)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        let context = coreDataService.newBackgroundContext()
        try context.performAndWait {
            _ = try StorableEntity(id: 10, name: "Hulk").update(context)
            try context.save()
        }

        wait(for: [expectation], timeout: 1)

        XCTAssertEqual(observedEntities.count, 2)
        XCTAssertEqual(observedEntities[0].count, 0)
        XCTAssertEqual(observedEntities[1].count, 1)
        XCTAssertEqual(observedEntities[1][0].name, "Hulk")
    }

    func testObserving_adding_onConstrainedEntity() throws {

        let coreDataService = CoreDataService(modelName: "TestModel", modelBundle: .module, destroyExistingStores: true)
        // Note: constrained properties don't work on memory only CoreData stacks.
        // So we create a real one and just destroy it every time on init.

        var observedEntities: [[TestEntity]] = []

        // prefill db with hulk
        let context = coreDataService.newBackgroundContext()
        try context.performAndWait {
            _ = try StorableEntity(id: 10, name: "Hulk").update(context)
            try context.save()
        }

        let expectation1 = expectation(description: "get values 1")
        let expectation2 = expectation(description: "get values 2")

        // start observing
        coreDataService
            .observe(type: TestEntity.self, predicate: nil, sortDescriptors: [.init(key: "id", ascending: true)])
            .sink { _ in } receiveValue: { chars in
                observedEntities.append(chars)
                switch observedEntities.count {
                case 1: expectation1.fulfill()
                case 2: expectation2.fulfill()
                default: break
                }
            }
            .store(in: &cancellables)

        // wait for first values
        wait(for: [expectation1], timeout: 1)

        // only the hulk
        XCTAssertEqual(observedEntities.count, 1)
        XCTAssertEqual(observedEntities[0].count, 1)
        XCTAssertEqual(observedEntities[0][0].name, "Hulk")

        // add another entity with the same id (which is constrained on the model), but with a different name.
        // this should trump the previous value

        let context2 = coreDataService.newBackgroundContext()
        try context2.performAndWait {
            _ = try StorableEntity(id: 10, name: "New Hulk").update(context2)
            try context2.save()
        }

        // wait for the change to propagate
        wait(for: [expectation2], timeout: 1)

        // check the hulk's new name
        XCTAssertEqual(observedEntities.count, 2)
        XCTAssertEqual(observedEntities[1].count, 1)
        XCTAssertEqual(observedEntities[1][0].name, "New Hulk")
    }

    func testObserving_removing() throws {

        let coreDataService = CoreDataService(modelName: "TestModel", modelBundle: .module, inMemoryStore: true)

        var observedEntities: [[TestEntity]] = []

        let context = coreDataService.newBackgroundContext()
        try context.performAndWait {
            _ = try StorableEntity(id: 10, name: "Hulk").update(context)
            try context.save()
        }

        let expectation1 = expectation(description: "get values 1")
        let expectation2 = expectation(description: "get values 2")

        coreDataService
            .observe(type: TestEntity.self, predicate: nil, sortDescriptors: [.init(key: "id", ascending: true)])
            .sink { _ in

            } receiveValue: { chars in
                observedEntities.append(chars)
                switch observedEntities.count {
                case 1: expectation1.fulfill()
                case 2: expectation2.fulfill()
                default: break
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation1], timeout: 1)
        XCTAssertEqual(observedEntities.count, 1)
        XCTAssertEqual(observedEntities[0].count, 1)
        XCTAssertEqual(observedEntities[0][0].name, "Hulk")

        let context2 = coreDataService.newBackgroundContext()
        try context2.performAndWait {
            let request = TestEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %d", 10)
            let entity = try XCTUnwrap(try request.execute().first)
            context2.delete(entity)
            try context2.save()
        }

        wait(for: [expectation2], timeout: 1)
        XCTAssertEqual(observedEntities.count, 2)
        XCTAssertEqual(observedEntities[1].count, 0)
    }

    func testResetingDB() throws {

        let coreDataService = CoreDataService(modelName: "TestModel", modelBundle: .module, destroyExistingStores: true)

        // prefill
        let context = coreDataService.newBackgroundContext()
        try context.performAndWait {
            _ = try StorableEntity(id: 10, name: "Hulk").update(context)
            try context.save()
        }

        // fetch
        let entities = try coreDataService.fetch(type: TestEntity.self)

        // contains prefilled stuff
        XCTAssertEqual(entities.count, 1)

        // RESET
        coreDataService.resetDatabase()

        // fetch again
        let entities2 = try coreDataService.fetch(type: TestEntity.self)

        // Should be empty
        XCTAssertEqual(entities2.count, 0)
    }
}

struct StorableEntity: Storable {
    var id: Int64
    var name: String

    func update(_ context: NSManagedObjectContext) throws -> NSManagedObject {

        let entity = TestEntity(context: context)
        entity.id = id
        entity.name = name
        return entity
    }
}
