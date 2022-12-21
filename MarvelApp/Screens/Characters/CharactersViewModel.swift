import Combine
import Foundation
import MarvelLocalization
import MarvelService

final class CharactersViewModel: ObservableObject {

    @Published private(set) var title: String = L10n.Characters.title
    @Published private(set) var sections: [CharactersSection] = []
    @Published private(set) var dialogViewModel: DialogViewModel? = nil
    @Published private(set) var isLoading: Bool = false

    @Published var sortBySelection = CharactersSortBy.name
    @Published private(set) var sortBy = CharactersSortBy.allCases

    public var showCharacter: ((Int64) -> Void)?

    @Published private var allCharacters: [Character] = []

    func onAppear() {
        guard allCharacters.isEmpty && !isLoading else { return }
        loadCharacters()
    }

    func pulledToRefresh() {
        loadCharacters()
    }

    func didSelect(_ cellViewModel: CharacterRowViewModel) {
        showCharacter?(cellViewModel.characterID)
    }

    private let marvelService: MarvelService

    init(marvelService: MarvelService) {
        self.marvelService = marvelService
        handleSortBySelection()
    }

    private func handleSortBySelection() {
        Publishers
            .CombineLatest($allCharacters, $sortBySelection)
            .map { characters, selection in
                switch selection {
                case .name:
                    return characters
                        .sorted { $0.name.compare($1.name, options: .caseInsensitive) == .orderedAscending }
                case .recent:
                    return characters
                        .sorted { $0.modified > $1.modified }
                }
            }
            .map { [marvelService] (sortedCharacters: [Character]) -> [CharacterRowViewModel] in
                sortedCharacters.map { CharacterRowViewModel(characterID: $0.id, marvelService: marvelService)}
            }
            .map { [CharactersSection(rowViewModels: $0)] }
            .assign(to: &$sections)
    }

    private func loadCharacters() {
        marvelService
            .searchCharacters(name: nil)
            .receive(on: OperationQueue.main)
            .trackLoading(to: \.isLoading, onWeak: self)
            //.trackLoading(to: &$isLoading)
            .handleEvents(receiveCompletion: { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                self?.dialogViewModel = DialogViewModel(
                    title: "Oops",
                    message: "Please try again later.\n" + error.localizedDescription,
                    buttons: [
                        .init(text: "OK", style: .cancel, action: nil)
                    ])
            })
            .replaceError(with: [])
            .assign(to: &$allCharacters)
    }
}

struct CharactersSection: Hashable {
    var id: Int = 0
    var rowViewModels: [CharacterRowViewModel]
}

enum CharactersSortBy: String, CaseIterable {
    case name
    case recent

    var title: String {
        switch self {
        case .name: return L10n.Characters.Filter.name
        case .recent: return L10n.Characters.Filter.recents
        }
    }
}
