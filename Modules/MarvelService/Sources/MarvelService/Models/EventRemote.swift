import Foundation

// MARK: - EventRemote
struct EventRemote: Codable, Hashable {
    let id: Int64
    let title, eventDescription: String
    let resourceURI: String
    let urls: [URLElement]
    let modified: Date
    let start, end: String?
    let thumbnail: Thumbnail
    let creators: List<CreatorSummary>
    let characters: List<CharacterSummary>
    let stories: List<StorySummary>
    let comics: List<ComicSummary>
    let series: List<SeriesSummary>
    let next, previous: EventSummary?

    enum CodingKeys: String, CodingKey {
        case id, title
        case eventDescription = "description"
        case resourceURI, urls, modified, start, end, thumbnail, creators, characters, stories, comics, series, next, previous
    }
}

extension EventRemote {

    var domain: Event {
        return Event(
            id: id,
            title: title,
            eventDescription: eventDescription,
            characters: characters,
            comics: comics,
            modified: modified,
            thumbnail: thumbnail
        )
    }
}
