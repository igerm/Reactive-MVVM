import Foundation

// MARK: - Event
public struct Event: Hashable {

    public let id: Int64
    public let title: String
    public let eventDescription: String
    public let characters: List<CharacterSummary>
    public let comics: List<ComicSummary>
    public let modified: Date
    public let thumbnail: Thumbnail

    public static var empty: Self {
        .init(id: 0, title: "", eventDescription: "", characters: .empty, comics: .empty, modified: .now, thumbnail: .empty)
    }

    public init(
        id: Int64,
        title: String,
        eventDescription: String,
        characters: List<CharacterSummary>,
        comics: List<ComicSummary>,
        modified: Date,
        thumbnail: Thumbnail
    ) {
        self.id = id
        self.title = title
        self.eventDescription = eventDescription
        self.characters = characters
        self.comics = comics
        self.modified = modified
        self.thumbnail = thumbnail
    }
}
