import CoreData
import Combine

// Service that knows of CoreData initialization, operations, etc.
public final class CoreDataService {

    /// To prevent the model for being loaded more than once.
    static var models: [String: NSManagedObjectModel] = [String: NSManagedObjectModel]()
    static func model(named: String, bundle: Bundle) -> NSManagedObjectModel {
        if let model = models[named] {
            return model
        }
        guard
            let url = bundle.url(forResource: named, withExtension: "momd"),
            let model = NSManagedObjectModel(contentsOf: url)
        else {
            fatalError("Couldn't load core data model named \(named)")
        }
        models[named] = model
        return model
    }

    let modelName: String
    let modelBundle: Bundle
    let inMemoryStore: Bool

    private lazy var persistentContainer: NSPersistentContainer = initPersistentContainer()

    private func initPersistentContainer() -> NSPersistentContainer {
        let model = Self.model(named: modelName, bundle: modelBundle)
        let container = NSPersistentContainer(name: modelName, managedObjectModel: model)
        container.persistentStoreDescriptions.forEach {
            $0.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            $0.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
            $0.shouldMigrateStoreAutomatically = true
            $0.shouldInferMappingModelAutomatically = true
            if inMemoryStore {
                $0.type = NSInMemoryStoreType
            }

            destroyStore(withDescription: $0, ifMetadataIsNotCompatibleWith: model, container: container)
        }

        print("[CoreData] loading persistent stores...")
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            print("[CoreData] loaded persistent stores...")
        })
        print("[CoreData] configuring viewContext...")
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }

    private func destroyStore(
        withDescription description: NSPersistentStoreDescription,
        ifMetadataIsNotCompatibleWith model: NSManagedObjectModel,
        container: NSPersistentContainer) {
        guard
            let url = description.url,
            let metadata = try? NSPersistentStoreCoordinator
                .metadataForPersistentStore(ofType: description.type, at: url),
            model.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata) == false
        else { return }
        do {
            try container.persistentStoreCoordinator.destroyPersistentStore(at: url, ofType: description.type)
        } catch {
            fatalError("Couldn't destroy incompatible persistent store: \(error.localizedDescription)")
        }
    }

    public var viewContext: NSManagedObjectContext { persistentContainer.viewContext }

    public func newBackgroundContext() -> NSManagedObjectContext {
        let managedObjectContext = persistentContainer.newBackgroundContext()
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return managedObjectContext
    }

    public init(
        modelName: String,
        modelBundle: Bundle,
        inMemoryStore: Bool = false,
        destroyExistingStores: Bool = false
    ) {
        self.modelName = modelName
        self.modelBundle = modelBundle
        self.inMemoryStore = inMemoryStore
        if destroyExistingStores {
            self.destroyExistingStores()
        }
    }

    public func observe<T: NSManagedObject>(
        type: T.Type,
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor]?
    ) -> AnyPublisher<[T], Error> {

        let fetchRequest = NSFetchRequest<T>(entityName: String(describing: T.self))
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        return viewContext
            .changesPublisher(for: fetchRequest)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }

    public func fetch<T: NSManagedObject>(
        type: T.Type,
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil,
        context: NSManagedObjectContext? = nil
    ) throws -> [T] {

        let context = context ?? viewContext
        let request = NSFetchRequest<T>(entityName: String(describing: T.self))
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors ?? []
        return try context.fetch(request)
    }

    public func save(context: NSManagedObjectContext) throws {
        guard context.hasChanges else { return }
        try context.save()
    }

    private func destroyExistingStores() {
        let container = NSPersistentContainer(
            name: modelName,
            managedObjectModel: Self.model(named: modelName, bundle: modelBundle)
        )
        container.persistentStoreDescriptions.forEach { descriptors in
            guard let url = descriptors.url else { return }
            do {
                try container.persistentStoreCoordinator.destroyPersistentStore(at: url, ofType: descriptors.type)
            } catch {
                fatalError("Error deleting all objects: \(error.localizedDescription)")
            }
        }
    }

    public func resetDatabase() {
        persistentContainer.persistentStoreCoordinator.persistentStores.forEach { store in
            guard let url = store.url else { return }
            do {
                try persistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: url, ofType: store.type)
            } catch {
                fatalError("Error deleting all objects: \(error.localizedDescription)")
            }
        }
        persistentContainer = initPersistentContainer()
    }
}
