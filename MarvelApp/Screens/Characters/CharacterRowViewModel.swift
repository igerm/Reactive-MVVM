import Combine
import Foundation
import MarvelService
import MarvelLocalization

final class CharacterRowViewModel: Hashable, ObservableObject {

    @Published private(set) var imageURL: URL?
    @Published private(set) var characterName: String = ""
    @Published private(set) var characterDescription: String = ""
    @Published private(set) var storiesCount: String = ""
    @Published private(set) var lastModified: String = ""
    @Published private(set) var isFavorite: Bool = false

    let characterID: Int64
    private let marvelService: MarvelService
    private var cancellables: Set<AnyCancellable> = []
    @Published private var character: Character?

    init(characterID: Int64, marvelService: MarvelService) {
        self.characterID = characterID
        self.marvelService = marvelService

        setupBindings()
    }

    func setupBindings() {
        marvelService
            .character(id: characterID, refreshData: false)
            .map { character -> Character? in
                character
            }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .assign(to: &$character)

        $character
            .compactMap { $0 }
            .map { $0.thumbnail.url }
            .assign(to: &$imageURL)

        $character
            .compactMap { $0 }
            .map { $0.name }
            .assign(to: &$characterName)

        $character
            .compactMap { $0 }
            .map { $0.characterDescription }
            .assign(to: &$characterDescription)

        $character
            .compactMap { $0 }
            .map { L10n.Characters.Cell.StoriesLabel.count(Int($0.stories.available)) }
            .assign(to: &$storiesCount)

        $character
            .compactMap { $0 }
            .map { $0.isFavorite }
            .assign(to: &$isFavorite)

        let formatter = dateFormatter
        $character
            .compactMap { $0 }
            .map {
                L10n.Characters.Cell.DateLabel.lastModified(
                    formatter.string(from: $0.modified)
                )
            }
            .assign(to: &$lastModified)
    }

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()

    // MARK: - Hashable
    /// We use hashable to detect id changes only and have the diffable data source pick up on
    /// those changes. But the internal stuff is tracked by the viewModel itself.

    static func == (lhs: CharacterRowViewModel, rhs: CharacterRowViewModel) -> Bool {
        lhs.characterID == rhs.characterID
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(characterID)
    }
}
