import Combine
import Foundation
import MarvelService
import MarvelLocalization

final class FavoritesViewModel: ObservableObject {

    @Published public private(set) var title: String = L10n.Favorites.title
    @Published public private(set) var rowViewModels: [FavoriteRowViewModel] = []
    @Published public var dialogViewModel: DialogViewModel? = nil

    public var showCharacter: ((Int64) -> Void)?

    private let marvelService: MarvelService
    private var cancellables: Set<AnyCancellable> = []

    init(marvelService: MarvelService) {
        self.marvelService = marvelService

        loadFavorites()
    }

    private func loadFavorites() {
        marvelService
            .favoriteCharacters()
            .receive(on: DispatchQueue.main)
            .map { [weak self, marvelService] characters in
                return characters.map { character in
                    return FavoriteRowViewModel(
                        characterID: character.id,
                        tapped: { [weak self] in
                            self?.showCharacter?(character.id)
                        },
                        marvelService: marvelService
                    )
                }
            }
            .onError { [weak self] error in
                self?.dialogViewModel = .error()
            }
            .sink { completion in } receiveValue: { [weak self] rowVMs in
                self?.rowViewModels = rowVMs
            }
            .store(in: &cancellables)
    }
}
