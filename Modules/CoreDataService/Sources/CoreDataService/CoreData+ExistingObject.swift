import Foundation
import CoreData
import Combine

// MARK: - Moving ManagedObjects between contexts

public extension Publisher where Output == [NSManagedObjectID] {

    func existingObjects(onViewContext context: NSManagedObjectContext) -> AnyPublisher<[NSManagedObject], Error> {

        return mapError { $0 as Error }
            .flatMap { objectIDs in
                Deferred {
                    Future<[NSManagedObject], Error> { promise in

                        context.perform {
                            let models = objectIDs.compactMap {
                                try? context.existingObject(with: $0)
                            }
                            promise(.success(models))
                        }
                    }
                    .receive(on: DispatchQueue.main)
                }
            }
            .eraseToAnyPublisher()
    }

    func existing<MO: NSManagedObject>(
        _ type: MO.Type = MO.self,
        onViewContext context: NSManagedObjectContext
    ) -> AnyPublisher<[MO], Error> {

        return mapError { $0 as Error }
            .flatMap { objectIDs in
                Deferred {
                    Future<[MO], Error> { promise in

                        context.perform {
                            let models = objectIDs.compactMap {
                                try? context.existingObject(with: $0)
                            }
                            let typedModels = models.compactMap { $0 as? MO }
                            promise(.success(typedModels))
                        }
                    }
                    .receive(on: DispatchQueue.main)
                }
            }
            .eraseToAnyPublisher()
    }
}
