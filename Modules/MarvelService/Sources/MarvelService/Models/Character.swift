import Foundation

// MARK: - Character
public struct Character: Hashable {

    public let id: Int64
    public let name: String
    public let characterDescription: String
    public let modified: Date
    public let stories: List<StorySummary>
    public let events: List<EventSummary>
    public let thumbnail: Thumbnail
    public let isFavorite: Bool

    static var empty: Self {
        .init(id: 0,
              name: "",
              characterDescription: "",
              modified: Date(timeIntervalSince1970: 0),
              stories: .empty,
              events: .empty,
              thumbnail: .empty,
              isFavorite: false)
    }

    public init(
        id: Int64,
        name: String,
        characterDescription: String,
        modified: Date,
        stories: List<StorySummary>,
        events: List<EventSummary>,
        thumbnail: Thumbnail,
        isFavorite: Bool
    ) {
        self.id = id
        self.name = name
        self.characterDescription = characterDescription
        self.modified = modified
        self.stories = stories
        self.events = events
        self.thumbnail = thumbnail
        self.isFavorite = isFavorite
    }
}
