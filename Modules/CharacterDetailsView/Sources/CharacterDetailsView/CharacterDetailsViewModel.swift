import Combine
import Foundation
import MarvelLocalization
import MarvelService

final public class CharacterDetailsViewModel: ObservableObject {

    @Published var avatarURL: URL?
    @Published var title: String = ""
    @Published var lastUpdated: String = ""
    @Published var description: String = ""
    @Published var isFavorite: Bool = false
    @Published var isLoading: Bool = false
    @Published var eventsTitle: String = ""
    @Published var eventsDescription: String = ""

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
            .onError { _ in
                // TODO: handle error. Show?
            }
            .map { $0 as Character? }
            .replaceError(with: nil as Character?)
            .assign(to: &$character)

        $character
            .map { $0?.thumbnail.url }
            .assign(to: &$avatarURL)
        $character
            .compactMap { $0?.modified }
            .map { date in
                let formatter = DateFormatter()
                formatter.timeStyle = .none
                formatter.dateStyle = .medium
                formatter.doesRelativeDateFormatting = true
                return L10n.CharacterDetails.DateLabel.lastModified(formatter.string(from: date))
            }
            .assign(to: &$lastUpdated)
        $character
            .compactMap { $0?.name }
            .assign(to: &$title)
        $character
            .compactMap { $0?.characterDescription }
            .assign(to: &$description)
        $character
            .compactMap { $0?.events }
            .map { L10n.CharacterDetails.EventsLabel.count($0.items.count) }
            .assign(to: &$eventsTitle)
        $character
            .compactMap { $0?.events }
            .map { events in
                let eventNames = events.items.map { $0.name }
                return ListFormatter.localizedString(byJoining: eventNames)
            }
            .assign(to: &$eventsDescription)
        $character
            .compactMap { $0?.isFavorite }
            .assign(to: &$isFavorite)
    }
}
