import Foundation

// MARK: - Character
// TODO: Make internal
public struct CharacterRemote: Codable, Hashable {

    public let id: Int64
    public let name, characterDescription, resourceURI: String
    public let modified: Date
    public let urls: [URLElement]
    public let thumbnail: Thumbnail
    public let comics: List<ComicSummary>
    public let stories: List<StorySummary>
    public let events: List<EventSummary>
    public let series: List<SeriesSummary>

    public enum CodingKeys: String, CodingKey {
        case id, name
        case characterDescription = "description"
        case modified, resourceURI, urls, thumbnail, comics, stories, events, series
    }

    public init(
        id: Int64,
        name: String,
        characterDescription: String,
        resourceURI: String,
        modified: Date,
        urls: [URLElement],
        thumbnail: Thumbnail,
        comics: List<ComicSummary>,
        stories: List<StorySummary>,
        events: List<EventSummary>,
        series: List<SeriesSummary>
    ) {
        self.id = id
        self.name = name
        self.characterDescription = characterDescription
        self.resourceURI = resourceURI
        self.modified = modified
        self.urls = urls
        self.thumbnail = thumbnail
        self.comics = comics
        self.stories = stories
        self.events = events
        self.series = series
    }
}

// MARK: - CharacterRemote + Storable

import CoreData
import CoreDataService

extension CharacterRemote: Storable {

    @discardableResult public func update(_ context: NSManagedObjectContext) throws -> NSManagedObject {

        let request = CharacterMO.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        let character = (try context.fetch(request).first) ?? CharacterMO(context: context)

        character.id = id
        character.remote = self

        return character
    }
}
