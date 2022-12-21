import Combine
import Foundation
import MarvelService
import MarvelLocalization

final class FavoriteRowViewModel: Identifiable, Hashable, ObservableObject {

    @Published private(set) var imageURL: URL?
    @Published private(set) var characterName: String = ""

    var tapped: (() -> Void)? = nil

    let id: Int64
    private let marvelService: MarvelService
    private var cancellables: Set<AnyCancellable> = []
    @Published private var character: Character?

    init(characterID: Int64, tapped: (() -> Void)? = nil, marvelService: MarvelService) {
        self.id = characterID
        self.tapped = tapped
        self.marvelService = marvelService

        setupBindings()
    }

    func setupBindings() {
        marvelService
            .character(id: id, refreshData: false)
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
    }

    // MARK: - Hashable
    /// We use hashable to detect id changes only and have the diffable data source pick up on
    /// those changes. But the internal stuff is tracked by the viewModel itself.

    static func == (lhs: FavoriteRowViewModel, rhs: FavoriteRowViewModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
