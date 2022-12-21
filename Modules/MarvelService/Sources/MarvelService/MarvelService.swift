import Foundation
import Combine

/// Describes a service for making API calls through the network.
public protocol MarvelService: AnyObject {

    /// Observes a character (and it's future changes) given an id.
    /// - parameter id: the character id.
    /// - parameter refreshData: indicate true if you want new data fetched from the backend.
    /// - return: A publisher that will issue Characters updates as the character is updated.
    func character(id: Int64, refreshData: Bool) -> AnyPublisher<Character, Error>

    /// Searches for characters
    /// - parameter name: tha name the character should have. Send nil to not filter by name.
    /// - return: A publisher that will issue an array of Characters from the backend.
    func searchCharacters(name: String?) -> Future<[Character], Error>

    /// Observes favorite characters.
    /// - return: A publisher that will issue updates as the data is updated.
    func favoriteCharacters() -> AnyPublisher<[Character], Error>

    /// Favorite/unfavorites a character.
    /// - parameter id: the character id.
    /// - parameter favorite: true if you want to make it favorite, false if you want to unfavorite it.
    /// - return: A publisher with an error if any.
    func makeCharacter(id: Int64, favorite: Bool) -> Future<(), Error>

    /// Retrieves a list of events by name.
    /// - parameter name: tha name the event should have. Send nil to not filter by name.
    /// - return: A publisher that will issue an array of Events from the backend.
    func events(named: String?) -> Future<[Event], Error>
}
