import APIService
import Combine
import CoreDataService
import Foundation

/// Live implementation of APIService using URLSession.
final public class MarvelServiceLive: MarvelService {

    let apiService: APIService
    let apiKey: String
    let privateKey: String
    let coreDataService: CoreDataService

    public init(
        apiService: APIService? = nil,
        apiKey: String = "4420276507578e660b38c6a7eda4bf90", // TODO: remove this from here. lol
        privateKey: String = "f5618b627a48681180bede7b47742e988bd659d8",
        coreDataService: CoreDataService? = nil
    ) {
        self.apiService = apiService ?? URLSessionAPIService()
        self.apiKey = apiKey
        self.privateKey = privateKey
        self.coreDataService = coreDataService ?? .init(modelName: "Model", modelBundle: .marvelServiceBundle)
    }

    public func searchCharacters(name: String?) -> Future<[Character], Error> {
        return apiService
            .dataPublisher(
                for: .marvel.characters(apiKey: apiKey, privateKey: privateKey, name: name)
            )
            .decode(type: Response<CharacterRemote>.self, decoder: JSONDecoder.marvel)
            .map { $0.data.results }
            .store(in: coreDataService.newBackgroundContext())
            .existing(CharacterMO.self, onViewContext: coreDataService.viewContext)
            .tryMap { characterMOs throws -> [Character] in
                return try characterMOs.map { try $0.domain }
            }
            .eraseToFuture()
    }

    public func character(id: Int64, refreshData: Bool) -> AnyPublisher<Character, Error> {

        let predicate = NSPredicate(format: "id == %d", id)
        let sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: false)
        ]

        let localPublisher = coreDataService
                .observe(
                    type: CharacterMO.self,
                    predicate: predicate,
                    sortDescriptors: sortDescriptors
                )
                .map { characterMOs in
                    return characterMOs.compactMap { mo -> Character? in
                        return try? mo.domain
                    }
                }
                .compactMap { $0.first }

        let cachedCharacter = (
            try? coreDataService.fetch(
                type: CharacterMO.self,
                predicate: predicate,
                sortDescriptors: sortDescriptors
            )
        )?.count ?? 0

        guard refreshData || cachedCharacter == 0 else { return localPublisher.eraseToAnyPublisher() }

        let remotePublisher = apiService
            .dataPublisher(
                for: .marvel.character(apiKey: apiKey, privateKey: privateKey, id: id)
            )
            .decode(type: Response<CharacterRemote>.self, decoder: JSONDecoder.marvel)
            .map { r -> [CharacterRemote] in r.data.results }
            .store(in: coreDataService.newBackgroundContext())
            .compactMap { _ -> Character? in nil }
        //  ^ ignore this data from now on and change the signature to match the local publisher

        return localPublisher.merge(with: remotePublisher)
            .eraseToAnyPublisher()
    }

    public func favoriteCharacters() -> AnyPublisher<[Character], Error> {
        coreDataService
            .observe(
                type: CharacterMO.self,
                predicate: NSPredicate(format: "isFavorite == %d", true),
                sortDescriptors: [
                    NSSortDescriptor(key: "name", ascending: true)
                ]
            )
            .map { characterMOs in
                return characterMOs.compactMap { mo -> Character? in
                    return try? mo.domain
                }
            }
            .eraseToAnyPublisher()
    }

    public func makeCharacter(id: Int64, favorite: Bool) -> Future<(), Error> {
        Just(id)
            .tryMap { [coreDataService] id -> Void in
                let context = coreDataService.newBackgroundContext()
                try context.performAndWait {
                    guard let character = try coreDataService
                        .fetch(
                            type: CharacterMO.self,
                            predicate: NSPredicate(format: "id == %d", id),
                            context: context
                        )
                        .first
                    else { throw MarvelServiceLiveError.characterNotFound }
                    character.isFavorite = favorite
                    try context.save()
                }
            }
            .eraseToFuture()
    }

    enum MarvelServiceLiveError: Error {
        case characterNotFound
    }

    public func events(named: String?) -> Future<[Event], Error> {
        apiService
            .dataPublisher(
                for: .marvel.events(apiKey: apiKey, privateKey: privateKey, name: named)
            )
            .decode(type: Response<EventRemote>.self, decoder: JSONDecoder.marvel)
            .onError({ error in
                print("WAT \(error)")
            })
            .map { r -> [Event] in r.data.results.map { $0.domain } }
            .eraseToFuture()
    }
}
