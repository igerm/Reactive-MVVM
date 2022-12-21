import Combine
import Foundation
import MarvelService

final public class CharacterPushNotificationViewModel: ObservableObject {

    @Published var avatarURL: URL?
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var isLoading: Bool = false

    public let characterID: Int64

    private let marvelService: MarvelService
    @Published private var character: Character?
    private var cancellables: Set<AnyCancellable> = []

    public init(characterID: Int64, marvelService: MarvelService) {
        self.characterID = characterID
        self.marvelService = marvelService
        setupBindings()
    }

    func favoriteTapped() {
        guard let character = character else { return } // no character was loaded yet. don't do anything.
        marvelService
            .makeCharacter(id: characterID, favorite: !(character.isFavorite))
            .sink { _ in } receiveValue: { }
            .store(in: &cancellables)
    }

    private func setupBindings() {
        marvelService
            .character(id: characterID, refreshData: true)
            .receive(on: OperationQueue.main)
            .trackLoading(to: &$isLoading)
            .handleEvents(receiveCompletion: { completion in
                guard case .failure = completion else { return }
                // TODO: handle error
            })
            .map { $0 as Character? }
            .replaceError(with: nil as Character?)
            .assign(to: &$character)

        $character
            .map { $0?.thumbnail.url }
            .assign(to: &$avatarURL)
        $character
            .compactMap { $0?.name }
            .assign(to: &$title)
        $character
            .compactMap { $0?.characterDescription }
            .assign(to: &$description)
    }
}
