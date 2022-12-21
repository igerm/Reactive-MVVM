import CoreData
import Foundation

// MARK: - Storage

/// Describes a (Remote) model that can be stored in CoreData.
public protocol Storable {

    /// Updates the context with the models information. It will update an existing `NSManagedObject` or insert a
    /// new one if necessary.
    /// **Important**: It should NOT save the context. It must be called from the context's queue.
    /// **Important**: Even if you set up constrained properties on an Entity so it doesn't create a duplicated record,
    /// a new internal record is created and the other one might be deleted. To avoid that, fetch the current entity
    /// on the context and update it instead of blindly creating a new one.
    /// ```
    /// let request = YourEntity.fetchRequest()
    /// request.predicate = NSPredicate(format: "id == %d", id)
    /// let entity = (try context.fetch(request).first) ?? YourEntity(context: context)
    /// ```
    @discardableResult func update(_ context: NSManagedObjectContext) throws -> NSManagedObject
}

import Combine

public extension Publisher where Output == [Storable] {

    func store(in context: NSManagedObjectContext) -> AnyPublisher<[NSManagedObjectID], Error> {
        return mapError { $0 as Error } // Erase to error because CoreData might through Error
            .flatMap { storables in
                Deferred { Future<[NSManagedObjectID], Error> { promise in

                    context.perform {
                        do {
                            let managedObjects = storables.compactMap { try? $0.update(context) }
                            try context.save()
                            promise(.success(managedObjects.map { $0.objectID }))
                        } catch {
                            promise(.failure(error))
                        }
                    }
                }}
            }
            .eraseToAnyPublisher()
    }
}

