import Combine
import Foundation
import MarvelService

public final class MarvelServiceMock: MarvelService {

    public init() {}

    public var characterByIDSubject = CurrentValueSubject<Character?, Error>(nil)

    public func character(id: Int64, refreshData: Bool) -> AnyPublisher<Character, Error> {
        characterByIDSubject
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }

    public var searchCharactersByNameSubject = CurrentValueSubject<[Character]?, Error>(nil)
    public func searchCharacters(name: String?) -> Future<[Character], Error> {
        searchCharactersByNameSubject
            .compactMap { $0 }
            .eraseToFuture()
    }

    public var favoriteCharactersSubject = CurrentValueSubject<[Character]?, Error>(nil)
    public func favoriteCharacters() -> AnyPublisher<[Character], Error> {
        favoriteCharactersSubject
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }

    public var makeCharacterIDFavoriteSubject = CurrentValueSubject<Void?, Error>(nil)
    public func makeCharacter(id: Int64, favorite: Bool) -> Future<(), Error> {
        makeCharacterIDFavoriteSubject
            .compactMap { $0 }
            .eraseToFuture()
    }

    public var eventsByNameSubject = CurrentValueSubject<[Event]?, Error>(nil)
    public func events(named: String?) -> Future<[Event], Error> {
        eventsByNameSubject
            .compactMap { $0 }
            .eraseToFuture()
    }
}

public extension MarvelServiceMock {

    /// **Important:**  Don't use for writing tests. Only for dev.
    static var dev: Self {
        let service = Self()
        service.characterByIDSubject.value = MarvelServiceMockedData.hulk
        service.searchCharactersByNameSubject.value = [MarvelServiceMockedData.hulk, MarvelServiceMockedData.deadpool]
        service.favoriteCharactersSubject.value = [MarvelServiceMockedData.deadpool]
        service.makeCharacterIDFavoriteSubject.value = ()
        return service
    }
}

public enum MarvelServiceMockedData {

    /// **Important:**  Don't use for writing tests. Only for dev.
    public static var deadpool: Character {
        .init(
            id: 1009268,
            name: "Deadpool",
            characterDescription: "",
            modified: DateFormatter.marvel.date(from: "2020-04-04T19:02:15-0400")!,
            stories: List<StorySummary>(
                available: 1097,
                returned: 2,
                collectionURI: "http://gateway.marvel.com/v1/public/characters/1009268/stories",
                items: [
                    .init(
                        resourceURI: "http://gateway.marvel.com/v1/public/stories/1135",
                        name: "AGENT X (2002) #15",
                        type: "cover"
                    ),
                    .init(
                        resourceURI: "http://gateway.marvel.com/v1/public/stories/1619",
                        name: "Interior #1619",
                        type: "interiorStory"
                    ),
                ]
            ),
            events: .init(
                available: 15,
                returned: 2,
                collectionURI: "http://gateway.marvel.com/v1/public/characters/1009268/events",
                items: [
                    .init(
                        resourceURI: "http://gateway.marvel.com/v1/public/events/320",
                        name: "Axis"
                    ),
                    .init(
                        resourceURI: "http://gateway.marvel.com/v1/public/events/238",
                        name: "Civil War"
                    )
                ]
            ),
            thumbnail: .init(
                path: "http://i.annihil.us/u/prod/marvel/i/mg/9/90/5261a86cacb99",
                fileExtension: "jpg"
            ),
            isFavorite: true
        )
    }

    /// **Important:**  Don't use for writing tests. Only for dev.
    public static var hulk: Character {
        .init(
            id: 1009351,
            name: "Hulk",
            characterDescription: "Caught in a gamma bomb explosion while trying to save the life of a teenager, Dr. Bruce Banner was transformed into the incredibly powerful creature called the Hulk. An all too often misunderstood hero, the angrier the Hulk gets, the stronger the Hulk gets.",
            modified: DateFormatter.marvel.date(from: "2020-07-21T10:35:15-0400")!,
            stories: List<StorySummary>(
                available: 2619,
                returned: 2,
                collectionURI: "http://gateway.marvel.com/v1/public/characters/1009351/stories",
                items: [
                    .init(
                        resourceURI: "http://gateway.marvel.com/v1/public/stories/702",
                        name: "INCREDIBLE HULK (1999) #62",
                        type: "cover"
                    ),
                    .init(
                        resourceURI: "http://gateway.marvel.com/v1/public/stories/703",
                        name: "Interior #703",
                        type: "interiorStory"
                    ),
                ]
            ),
            events: .init(
                available: 26,
                returned: 2,
                collectionURI: "http://gateway.marvel.com/v1/public/characters/1009351/events",
                items: [
                    .init(
                        resourceURI: "http://gateway.marvel.com/v1/public/events/116",
                        name: "Acts of Vengeance!"
                    ),
                    .init(
                        resourceURI: "http://gateway.marvel.com/v1/public/events/303",
                        name: "Age of X"
                    )
                ]
            ),
            thumbnail: .init(
                path: "http://i.annihil.us/u/prod/marvel/i/mg/5/a0/538615ca33ab0",
                fileExtension: "jpg"
            ),
            isFavorite: false
        )
    }

    public static var event: Event {
        .init(
            id: 116,
            title: "Acts of Vengeance!",
            eventDescription: "Loki sets about convincing the super-villains of Earth to attack heroes other than those they normally fight in an attempt to destroy the Avengers to absolve his guilt over inadvertently creating the team in the first place.",
            characters: .init(
                available: 108,
                returned: 2,
                collectionURI: "http://gateway.marvel.com/v1/public/events/116/characters",
                items: [
                    .init(resourceURI: "http://gateway.marvel.com/v1/public/characters/1009435", name: "Alicia Masters")
                ]
            ),
            comics: .init(
                available: 53,
                returned: 2,
                collectionURI: "http://gateway.marvel.com/v1/public/events/116/comics",
                items: [
                    .init(resourceURI: "http://gateway.marvel.com/v1/public/comics/12744", name: "Alpha Flight (1983) #79"),
                    .init(resourceURI: "http://gateway.marvel.com/v1/public/comics/12746", name: "Alpha Flight (1983) #80"),
                ]
            ),
            modified: DateFormatter.marvel.date(from: "2013-06-28T16:31:24-0400")!,
            thumbnail: .init(path: "http://i.annihil.us/u/prod/marvel/i/mg/9/40/51ca10d996b8b", fileExtension: "jpg")
        )
    }
}
